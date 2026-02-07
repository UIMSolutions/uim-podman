/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.client;

import uim.podman.library;

@trusted:

/// Podman API HTTP client.
class PodmanClient {
  private string endpoint;
  private string apiVersion;
  private bool insecureSkipVerify;
  private string caCertPath;

  this(string endpoint, string apiVersion = "v4.0.0", bool insecureSkipVerify = false, string caCertPath = "") {
    this.endpoint = endpoint;
    this.apiVersion = apiVersion;
    this.insecureSkipVerify = insecureSkipVerify;
    this.caCertPath = caCertPath;
  }

  this(PodmanConfig config) {
    this.endpoint = config.endpoint;
    this.apiVersion = config.apiVersion;
    this.insecureSkipVerify = config.insecureSkipVerify;
    this.caCertPath = config.caCertPath;
  }

  /// Lists all containers.
  Container[] listContainers(bool all = false) {
    string path = "/" ~ apiVersion ~ "/containers/json";
    if (all) {
      path ~= "?all=true";
    }
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list containers: %d", response.statusCode));

    Container[] results;
    if (response.data.isArray) {
      foreach (item; response.data.array) {
        results ~= Container(item);
      }
    }
    return results;
  }

  /// Gets a single container by ID or name.
  Container getContainer(string idOrName) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "/json";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get container %s: %d", idOrName, response
        .statusCode));
    return Container(response.data);
  }

  /// Creates a new container.
  string createContainer(string name, Json config) {
    string path = "/" ~ apiVersion ~ "/containers/create?name=" ~ name;
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 201, format("Failed to create container: %d", response
        .statusCode));
    return response.data.isString("Id") ? response.data.getString("Id") : "";
  }

  /// Starts a container.
  void startContainer(string idOrName) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "/start";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 204 || response.statusCode == 304, format(
        "Failed to start container: %d", response.statusCode));
  }

  /// Stops a container.
  void stopContainer(string idOrName, int timeout = 10) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "/stop?t=" ~ format("%d", timeout);
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 204, format("Failed to stop container: %d", response.statusCode));
  }

  /// Removes a container.
  void removeContainer(string idOrName, bool force = false, bool removeVolumes = false) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "?force=" ~ (force ? "true"
        : "false") ~ "&v=" ~ (removeVolumes ? "true" : "false");
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 204, format("Failed to remove container: %d", response
        .statusCode));
  }

  /// Gets container logs.
  LogsResponse getContainerLogs(string idOrName, bool stdout = true, bool stderr = false) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "/logs?stdout=" ~ (stdout ? "true"
        : "false") ~ "&stderr=" ~ (stderr ? "true" : "false");
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get container logs: %d", response
        .statusCode));
    return LogsResponse(response.rawOutput);
  }

  /// Pauses a container.
  void pauseContainer(string idOrName) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "/pause";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 204, format("Failed to pause container: %d", response.statusCode));
  }

  /// Unpauses a container.
  void unpauseContainer(string idOrName) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "/unpause";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 204, format("Failed to unpause container: %d", response
        .statusCode));
  }

  // Image operations

  /// Lists all images.
  Image[] listImages() {
    string path = "/" ~ apiVersion ~ "/images/json";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list images: %d", response.statusCode));

    Image[] results;
    if (response.data.isArray) {
      foreach (item; response.data.array) {
        results ~= Image(item);
      }
    }
    return results;
  }

  /// Pulls an image from a registry.
  void pullImage(string fromImage, string tag = "latest") {
    string path = "/" ~ apiVersion ~ "/images/pull?fromImage=" ~ fromImage ~ "&tag=" ~ tag;
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 200, format("Failed to pull image: %d", response.statusCode));
  }

  /// Removes an image.
  void removeImage(string image, bool force = false) {
    string path = "/" ~ apiVersion ~ "/images/" ~ image ~ "?force=" ~ (force ? "true" : "false");
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 200, format("Failed to remove image: %d", response.statusCode));
  }

  // Pod operations

  /// Lists all pods.
  Pod[] listPods() {
    string path = "/" ~ apiVersion ~ "/pods/json";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list pods: %d", response.statusCode));

    Pod[] results;
    if (response.data.isArray) {
      foreach (item; response.data.array) {
        results ~= Pod(item);
      }
    }
    return results;
  }

  /// Gets a pod by name or ID.
  Pod getPod(string nameOrId) {
    string path = "/" ~ apiVersion ~ "/pods/" ~ nameOrId ~ "/json";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get pod %s: %d", nameOrId, response
        .statusCode));
    return Pod(response.data);
  }

  /// Creates a new pod.
  string createPod(string name, Json config) {
    string path = "/" ~ apiVersion ~ "/pods/create?name=" ~ name;
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 201, format("Failed to create pod: %d", response.statusCode));
    return response.data.isString("Id") ? response.data.getString("Id") : "";
  }

  /// Starts a pod.
  void startPod(string nameOrId) {
    string path = "/" ~ apiVersion ~ "/pods/" ~ nameOrId ~ "/start";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 200, format("Failed to start pod: %d", response.statusCode));
  }

  /// Stops a pod.
  void stopPod(string nameOrId, int timeout = 10) {
    string path = "/" ~ apiVersion ~ "/pods/" ~ nameOrId ~ "/stop?t=" ~ format("%d", timeout);
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 200, format("Failed to stop pod: %d", response.statusCode));
  }

  /// Removes a pod.
  void removePod(string nameOrId, bool force = false) {
    string path = "/" ~ apiVersion ~ "/pods/" ~ nameOrId ~ "?force=" ~ (force ? "true" : "false");
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 200, format("Failed to remove pod: %d", response.statusCode));
  }

  // Volume operations

  /// Lists all volumes.
  Volume[] listVolumes() {
    string path = "/" ~ apiVersion ~ "/volumes";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list volumes: %d", response.statusCode));

    Volume[] results;
    if (response.data.isArray("Volumes")) {
      foreach (item; response.data.getArray("Volumes")) {
        results ~= Volume(item);
      }
    }
    return results;
  }

  /// Creates a volume.
  string createVolume(string name, string driver = "local", string[string] options = null) {
    Json config = Json([
        "Name": Json(name),
        "Driver": Json(driver)
      ]);

    if (options.length > 0) {
      Json[string] opts;
      foreach (key, value; options) {
        opts[key] = Json(value);
      }
      config["Options"] = Json(opts);
    }
    
    string path = "/" ~ apiVersion ~ "/volumes/create";
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 201, format("Failed to create volume: %d", response.statusCode));
    return response.data.isString("Name") ? response.data.getString("Name") : "";
  }

  /// Removes a volume.
  void removeVolume(string name, bool force = false) {
    string path = "/" ~ apiVersion ~ "/volumes/" ~ name ~ "?force=" ~ (force ? "true" : "false");
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 204, format("Failed to remove volume: %d", response.statusCode));
  }

  // Network operations

  /// Lists all networks.
  Network[] listNetworks() {
    string path = "/" ~ apiVersion ~ "/networks";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list networks: %d", response.statusCode));

    Network[] results;
    if (response.data.isArray) {
      foreach (item; response.data.array) {
        results ~= Network(item);
      }
    }
    return results;
  }

  /// Creates a network.
  string createNetwork(string name, string driver = "bridge") {
    Json config = Json([
        "Name": Json(name),
        "Driver": Json(driver)
      ]);
    string path = "/" ~ apiVersion ~ "/networks/create";
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 201, format("Failed to create network: %d", response.statusCode));
    return response.data.isString("Id") ? response.data.getString("Id") : "";
  }

  /// Removes a network.
  void removeNetwork(string name) {
    string path = "/" ~ apiVersion ~ "/networks/" ~ name;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 204, format("Failed to remove network: %d", response.statusCode));
  }

  // Private helper methods

  private struct HttpResponse {
    int statusCode;
    Json data;
    string rawOutput;
  }

  private HttpResponse doRequest(string method, string path, Json body_) @system {
    // This would be implemented with actual HTTP calls
    // For now, this is a placeholder that shows the structure
    HttpResponse response;
    response.statusCode = 200;
    response.data = Json();
    response.rawOutput = "";
    return response;
  }
}
