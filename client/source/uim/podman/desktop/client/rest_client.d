module uim.podman.desktop.client.rest_client;

import std.json : Json, parseJsonString;
import std.string : endsWith, startsWith;
import vibe.http.client : requestHTTP, HTTPClientRequest, HTTPClientResponse;
import vibe.http.common : HTTPMethod;
import vibe.data.url : URL;

import uim.podman.desktop.client.config;
import uim.podman.desktop.client.dtos;
import uim.podman.desktop.client.exceptions;

@safe:

struct RestResponse {
  int statusCode;
  Json data;
  string rawBody;
}

/// Web client for the Podman REST server.
class PodmanWebClient {
  private PodmanWebClientConfig config;

  this(PodmanWebClientConfig config = defaultWebClientConfig()) {
    this.config = config;
  }

  RestContainer[] listContainers(bool all = false) {
    string path = "/containers";
    if (all) {
      path ~= "?all=true";
    }
    auto response = requestJson(HTTPMethod.get, path);
    RestContainer[] results;
    if (response.data.isArray) {
      foreach (item; response.data.toArray) {
        results ~= RestContainer.fromJson(item);
      }
    }
    return results;
  }

  RestContainer getContainer(string idOrName) {
    auto response = requestJson(HTTPMethod.get, "/containers/" ~ idOrName);
    return RestContainer.fromJson(response.data);
  }

  string createContainer(string name, Json configJson) {
    Json payload = Json([
      "name": Json(name),
      "config": configJson
    ]);
    auto response = requestJson(HTTPMethod.post, "/containers", payload);
    return response.data.hasKey("id") ? response.data["id"].toString : "";
  }

  void startContainer(string idOrName) {
    requestJson(HTTPMethod.post, "/containers/" ~ idOrName ~ "/start");
  }

  void stopContainer(string idOrName, int timeout = 10) {
    requestJson(HTTPMethod.post, "/containers/" ~ idOrName ~ "/stop?timeout=" ~ timeout.toString);
  }

  void removeContainer(string idOrName, bool force = false, bool removeVolumes = false) {
    string path = "/containers/" ~ idOrName ~ "?force=" ~ (force ? "true" : "false") ~ "&volumes="
      ~ (removeVolumes ? "true" : "false");
    requestJson(HTTPMethod.del, path);
  }

  string getContainerLogs(string idOrName, bool stdout = true, bool stderr = false) {
    string path = "/containers/" ~ idOrName ~ "/logs?stdout=" ~ (stdout ? "true" : "false")
      ~ "&stderr=" ~ (stderr ? "true" : "false");
    auto response = requestJson(HTTPMethod.get, path);
    return response.data.hasKey("logs") ? response.data["logs"].toString : "";
  }

  void pauseContainer(string idOrName) {
    requestJson(HTTPMethod.post, "/containers/" ~ idOrName ~ "/pause");
  }

  void unpauseContainer(string idOrName) {
    requestJson(HTTPMethod.post, "/containers/" ~ idOrName ~ "/unpause");
  }

  RestImage[] listImages() {
    auto response = requestJson(HTTPMethod.get, "/images");
    RestImage[] results;
    if (response.data.isArray) {
      foreach (item; response.data.toArray) {
        results ~= RestImage.fromJson(item);
      }
    }
    return results;
  }

  void pullImage(string image, string tag = "latest") {
    Json payload = Json([
      "image": Json(image),
      "tag": Json(tag)
    ]);
    requestJson(HTTPMethod.post, "/images/pull", payload);
  }

  void removeImage(string image, bool force = false) {
    requestJson(HTTPMethod.del, "/images/" ~ image ~ "?force=" ~ (force ? "true" : "false"));
  }

  RestPod[] listPods() {
    auto response = requestJson(HTTPMethod.get, "/pods");
    RestPod[] results;
    if (response.data.isArray) {
      foreach (item; response.data.toArray) {
        results ~= RestPod.fromJson(item);
      }
    }
    return results;
  }

  RestPod getPod(string nameOrId) {
    auto response = requestJson(HTTPMethod.get, "/pods/" ~ nameOrId);
    return RestPod.fromJson(response.data);
  }

  string createPod(string name, Json configJson) {
    Json payload = Json([
      "name": Json(name),
      "config": configJson
    ]);
    auto response = requestJson(HTTPMethod.post, "/pods", payload);
    return response.data.hasKey("id") ? response.data["id"].toString : "";
  }

  void startPod(string nameOrId) {
    requestJson(HTTPMethod.post, "/pods/" ~ nameOrId ~ "/start");
  }

  void stopPod(string nameOrId, int timeout = 10) {
    requestJson(HTTPMethod.post, "/pods/" ~ nameOrId ~ "/stop?timeout=" ~ timeout.toString);
  }

  void removePod(string nameOrId, bool force = false) {
    requestJson(HTTPMethod.del, "/pods/" ~ nameOrId ~ "?force=" ~ (force ? "true" : "false"));
  }

  RestVolume[] listVolumes() {
    auto response = requestJson(HTTPMethod.get, "/volumes");
    RestVolume[] results;
    if (response.data.isArray) {
      foreach (item; response.data.toArray) {
        results ~= RestVolume.fromJson(item);
      }
    }
    return results;
  }

  string createVolume(string name, string driver = "local", string[string] options = null) {
    Json payload = Json([
      "name": Json(name),
      "driver": Json(driver)
    ]);

    if (options !is null) {
      Json[string] optJson;
      foreach (key, value; options) {
        optJson[key] = Json(value);
      }
      payload["options"] = Json(optJson);
    }

    auto response = requestJson(HTTPMethod.post, "/volumes", payload);
    return response.data.hasKey("id") ? response.data["id"].toString : "";
  }

  void removeVolume(string name, bool force = false) {
    requestJson(HTTPMethod.del, "/volumes/" ~ name ~ "?force=" ~ (force ? "true" : "false"));
  }

  RestNetwork[] listNetworks() {
    auto response = requestJson(HTTPMethod.get, "/networks");
    RestNetwork[] results;
    if (response.data.isArray) {
      foreach (item; response.data.toArray) {
        results ~= RestNetwork.fromJson(item);
      }
    }
    return results;
  }

  string createNetwork(string name, string driver = "bridge") {
    Json payload = Json([
      "name": Json(name),
      "driver": Json(driver)
    ]);
    auto response = requestJson(HTTPMethod.post, "/networks", payload);
    return response.data.hasKey("id") ? response.data["id"].toString : "";
  }

  void removeNetwork(string name) {
    requestJson(HTTPMethod.del, "/networks/" ~ name);
  }

  private RestResponse requestJson(HTTPMethod method, string path, Json body = Json()) {
    RestResponse result;
    auto url = URL(buildUrl(path));

    requestHTTP(url, (scope HTTPClientRequest req) {
      req.method = method;
      req.headers["Accept"] = "application/json";
      req.headers["Content-Type"] = "application/json";
      if (config.token.length) {
        req.headers["Authorization"] = "Bearer " ~ config.token;
      }
      if (!body.isNull) {
        req.writeJsonBody(body);
      }
    }, (scope HTTPClientResponse res) {
      result.statusCode = res.statusCode;
      result.rawBody = res.bodyReader.readAllUTF8();
    });

    if (result.rawBody.length) {
      try {
        result.data = parseJsonString(result.rawBody);
      } catch (Exception) {
        result.data = Json();
      }
    } else {
      result.data = Json();
    }

    if (result.statusCode >= 400) {
      throw new PodmanWebClientException("REST request failed", result.statusCode, result.rawBody);
    }

    return result;
  }

  private string buildUrl(string path) {
    string baseUrl = config.baseUrl;
    if (baseUrl.endsWith("/")) {
      baseUrl = baseUrl[0 .. $ - 1];
    }

    if (!path.length) {
      return baseUrl;
    }

    if (!path.startsWith("/")) {
      return baseUrl ~ "/" ~ path;
    }

    return baseUrl ~ path;
  }
}
