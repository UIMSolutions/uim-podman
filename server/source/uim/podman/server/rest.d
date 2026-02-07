module uim.podman.server.rest;

import std.conv : to;
import std.exception : enforce;
import std.json : Json, parseJsonString;
import std.string : strip, toLower;
import vibe.vibe;

import uim.podman.library;
import uim.podman.server.config;
import uim.podman.server.serialization;

@safe:

/// Convenience entry point for starting the REST server.
void runRestServer(PodmanServerConfig config = defaultServerConfig(), IPodmanClient client = null) {
  auto service = new PodmanRestService(config, client);
  service.run();
}

/// REST API service that exposes Podman operations.
class PodmanRestService {
  private PodmanServerConfig config;
  private IPodmanClient client;

  this(PodmanServerConfig config, IPodmanClient client = null) {
    this.config = config;
    this.client = client is null ? new PodmanClient(config.podmanEndpoint, config.apiVersion) : client;
  }

  /// Registers routes on the provided router.
  void registerRoutes(URLRouter router) {
    string basePath = config.basePath.length ? config.basePath : "/api/v1";

    router.options(basePath, &handleOptions);
    router.options(basePath ~ "/*", &handleOptions);

    router.get(basePath ~ "/health", &handleHealth);

    router.get(basePath ~ "/containers", &handleListContainers);
    router.get(basePath ~ "/containers/*", &handleGetContainer);
    router.post(basePath ~ "/containers", &handleCreateContainer);
    router.post(basePath ~ "/containers/*/start", &handleStartContainer);
    router.post(basePath ~ "/containers/*/stop", &handleStopContainer);
    router.delete_(basePath ~ "/containers/*", &handleRemoveContainer);
    router.get(basePath ~ "/containers/*/logs", &handleContainerLogs);
    router.post(basePath ~ "/containers/*/pause", &handlePauseContainer);
    router.post(basePath ~ "/containers/*/unpause", &handleUnpauseContainer);

    router.get(basePath ~ "/images", &handleListImages);
    router.post(basePath ~ "/images/pull", &handlePullImage);
    router.delete_(basePath ~ "/images/*", &handleRemoveImage);

    router.get(basePath ~ "/pods", &handleListPods);
    router.get(basePath ~ "/pods/*", &handleGetPod);
    router.post(basePath ~ "/pods", &handleCreatePod);
    router.post(basePath ~ "/pods/*/start", &handleStartPod);
    router.post(basePath ~ "/pods/*/stop", &handleStopPod);
    router.delete_(basePath ~ "/pods/*", &handleRemovePod);

    router.get(basePath ~ "/volumes", &handleListVolumes);
    router.post(basePath ~ "/volumes", &handleCreateVolume);
    router.delete_(basePath ~ "/volumes/*", &handleRemoveVolume);

    router.get(basePath ~ "/networks", &handleListNetworks);
    router.post(basePath ~ "/networks", &handleCreateNetwork);
    router.delete_(basePath ~ "/networks/*", &handleRemoveNetwork);
  }

  /// Starts the HTTP server and runs the vibe.d event loop.
  void run() {
    enforce(!config.token.empty, "UIM_PODMAN_API_TOKEN is required");
    auto router = new URLRouter();
    registerRoutes(router);
    listenHTTP(config.host, config.port, router);
    runApplication();
  }

  private bool ensureAuthorized(HTTPServerRequest req, HTTPServerResponse res) {
    applyCors(req, res);
    auto authHeader = req.headers.get("Authorization", "");
    string expected = "Bearer " ~ config.token;
    if (authHeader != expected) {
      res.statusCode = HTTPStatus.unauthorized;
      res.writeJsonBody(Json([
        "error": Json("unauthorized")
      ]));
      return false;
    }
    return true;
  }

  private void applyCors(HTTPServerRequest req, HTTPServerResponse res) {
    if (config.corsOrigins.length == 0) {
      return;
    }

    auto origin = req.headers.get("Origin", "");
    if (!origin.length) {
      return;
    }

    bool allowAny = false;
    bool allowed = false;
    foreach (entry; config.corsOrigins) {
      if (entry == "*") {
        allowAny = true;
        allowed = true;
        break;
      }
      if (entry == origin) {
        allowed = true;
      }
    }

    if (!allowed) {
      return;
    }

    res.headers["Access-Control-Allow-Origin"] = allowAny ? "*" : origin;
    if (!allowAny) {
      res.headers["Vary"] = "Origin";
    }
    res.headers["Access-Control-Allow-Headers"] = config.corsAllowHeaders;
    res.headers["Access-Control-Allow-Methods"] = config.corsAllowMethods;
    res.headers["Access-Control-Max-Age"] = to!string(config.corsMaxAgeSeconds);
  }

  private void withErrorHandling(HTTPServerResponse res, void delegate() action) {
    try {
      action();
    } catch (PodmanException e) {
      int status = e.statusCode != 0 ? e.statusCode : 500;
      res.statusCode = cast(HTTPStatus)status;
      res.writeJsonBody(Json([
        "error": Json(e.msg),
        "status": Json(status)
      ]));
    } catch (Exception e) {
      res.statusCode = HTTPStatus.internalServerError;
      res.writeJsonBody(Json([
        "error": Json(e.msg),
        "status": Json(500)
      ]));
    }
  }

  private Json readJsonBody(HTTPServerRequest req) {
    auto raw = req.bodyReader.readAllUTF8();
    if (raw.length == 0) {
      return Json();
    }
    return parseJsonString(raw);
  }

  private string queryValue(HTTPServerRequest req, string key, string defaultValue) {
    auto value = req.query.get(key, "");
    return value.length ? value : defaultValue;
  }

  private bool queryBool(HTTPServerRequest req, string key, bool defaultValue) {
    auto value = queryValue(req, key, "");
    if (!value.length) {
      return defaultValue;
    }
    auto normalized = value.strip.toLower();
    return normalized == "1" || normalized == "true" || normalized == "yes";
  }

  private int queryInt(HTTPServerRequest req, string key, int defaultValue) {
    auto value = queryValue(req, key, "");
    if (!value.length) {
      return defaultValue;
    }
    try {
      return to!int(value);
    } catch (Exception) {
      return defaultValue;
    }
  }

  private string tailParam(HTTPServerRequest req) {
    return req.params["*"];
  }

  private void handleOptions(HTTPServerRequest req, HTTPServerResponse res) {
    applyCors(req, res);
    res.statusCode = HTTPStatus.noContent;
  }

  private void handleHealth(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      res.writeJsonBody(Json([
        "status": Json("ok")
      ]));
    });
  }

  private void handleListContainers(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      bool all = queryBool(req, "all", false);
      auto containers = client.listContainers(all);
      res.writeJsonBody(listContainersToJson(containers));
    });
  }

  private void handleGetContainer(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      auto container = client.getContainer(tailParam(req));
      res.writeJsonBody(containerToJson(container));
    });
  }

  private void handleCreateContainer(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      auto body = readJsonBody(req);
      string name = body.hasKey("name") ? body["name"].toString : "";
      Json configJson = body.hasKey("config") ? body["config"] : Json();

      auto id = client.createContainer(name, configJson);
      res.statusCode = HTTPStatus.created;
      res.writeJsonBody(Json([
        "id": Json(id)
      ]));
    });
  }

  private void handleStartContainer(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      client.startContainer(tailParam(req));
      res.statusCode = HTTPStatus.noContent;
    });
  }

  private void handleStopContainer(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      int timeout = queryInt(req, "timeout", 10);
      client.stopContainer(tailParam(req), timeout);
      res.statusCode = HTTPStatus.noContent;
    });
  }

  private void handleRemoveContainer(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      bool force = queryBool(req, "force", false);
      bool removeVolumes = queryBool(req, "volumes", false);
      client.removeContainer(tailParam(req), force, removeVolumes);
      res.statusCode = HTTPStatus.noContent;
    });
  }

  private void handleContainerLogs(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      bool stdout = queryBool(req, "stdout", true);
      bool stderr = queryBool(req, "stderr", false);
      auto logs = client.getContainerLogs(tailParam(req), stdout, stderr);

      res.writeJsonBody(Json([
        "logs": Json(logs)
      ]));
    });
  }

  private void handlePauseContainer(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      client.pauseContainer(tailParam(req));
      res.statusCode = HTTPStatus.noContent;
    });
  }

  private void handleUnpauseContainer(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      client.unpauseContainer(tailParam(req));
      res.statusCode = HTTPStatus.noContent;
    });
  }

  private void handleListImages(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      auto images = client.listImages();
      res.writeJsonBody(listImagesToJson(images));
    });
  }

  private void handlePullImage(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      auto body = readJsonBody(req);
      string image = body.hasKey("image") ? body["image"].toString : "";
      string tag = body.hasKey("tag") ? body["tag"].toString : "latest";

      client.pullImage(image, tag);
      res.statusCode = HTTPStatus.accepted;
    });
  }

  private void handleRemoveImage(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      bool force = queryBool(req, "force", false);
      client.removeImage(tailParam(req), force);
      res.statusCode = HTTPStatus.noContent;
    });
  }

  private void handleListPods(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      auto pods = client.listPods();
      res.writeJsonBody(listPodsToJson(pods));
    });
  }

  private void handleGetPod(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      auto pod = client.getPod(tailParam(req));
      res.writeJsonBody(podToJson(pod));
    });
  }

  private void handleCreatePod(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      auto body = readJsonBody(req);
      string name = body.hasKey("name") ? body["name"].toString : "";
      Json configJson = body.hasKey("config") ? body["config"] : Json();

      auto id = client.createPod(name, configJson);
      res.statusCode = HTTPStatus.created;
      res.writeJsonBody(Json([
        "id": Json(id)
      ]));
    });
  }

  private void handleStartPod(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      client.startPod(tailParam(req));
      res.statusCode = HTTPStatus.noContent;
    });
  }

  private void handleStopPod(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      int timeout = queryInt(req, "timeout", 10);
      client.stopPod(tailParam(req), timeout);
      res.statusCode = HTTPStatus.noContent;
    });
  }

  private void handleRemovePod(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      bool force = queryBool(req, "force", false);
      client.removePod(tailParam(req), force);
      res.statusCode = HTTPStatus.noContent;
    });
  }

  private void handleListVolumes(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      auto volumes = client.listVolumes();
      res.writeJsonBody(listVolumesToJson(volumes));
    });
  }

  private void handleCreateVolume(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      auto body = readJsonBody(req);
      string name = body.hasKey("name") ? body["name"].toString : "";
      string driver = body.hasKey("driver") ? body["driver"].toString : "local";
      string[string] options;
      if (body.hasKey("options") && body["options"].isObject) {
        foreach (key, value; body["options"].toMap) {
          options[key] = value.toString;
        }
      }

      auto id = client.createVolume(name, driver, options);
      res.statusCode = HTTPStatus.created;
      res.writeJsonBody(Json([
        "id": Json(id)
      ]));
    });
  }

  private void handleRemoveVolume(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      bool force = queryBool(req, "force", false);
      client.removeVolume(tailParam(req), force);
      res.statusCode = HTTPStatus.noContent;
    });
  }

  private void handleListNetworks(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      auto networks = client.listNetworks();
      res.writeJsonBody(listNetworksToJson(networks));
    });
  }

  private void handleCreateNetwork(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      auto body = readJsonBody(req);
      string name = body.hasKey("name") ? body["name"].toString : "";
      string driver = body.hasKey("driver") ? body["driver"].toString : "bridge";

      auto id = client.createNetwork(name, driver);
      res.statusCode = HTTPStatus.created;
      res.writeJsonBody(Json([
        "id": Json(id)
      ]));
    });
  }

  private void handleRemoveNetwork(HTTPServerRequest req, HTTPServerResponse res) {
    if (!ensureAuthorized(req, res)) {
      return;
    }
    withErrorHandling(res, () {
      client.removeNetwork(tailParam(req));
      res.statusCode = HTTPStatus.noContent;
    });
  }
}
