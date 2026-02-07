/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.classes.client;

import uim.podman.library;

@safe:

/// Podman API HTTP client with advanced features.
class PodmanClient : IPodmanClient {
  private PodmanConfig config;
  private PodmanHttpClient httpClient;
  private ResponseCache cache;
  private bool closed;

  /// Initialize with configuration
  this(PodmanConfig config) {
    enforce(config.validate(), "Invalid configuration");
    this.config = config;
    this.httpClient = new PodmanHttpClient(config);
    this.cache = new ResponseCache(100, config.enableCaching);
    this.closed = false;
  }

  /// Initialize with endpoint string
  this(string endpoint, string apiVersion = "v4.0.0") {
    this(PodmanConfig.builder()
        .withEndpoint(endpoint)
        .withApiVersion(apiVersion)
        .build());
  }

  // Container operations

  /// Lists all containers.
  Container[] listContainers(bool all = false) {
    enforce(!closed, "Client is closed");

    string cacheKey = "containers:" ~ (all ? "all" : "running");
    if (cache.has(cacheKey)) {
      Json cached = cache.get(cacheKey);
      Container[] results;
      if (cached.isArray) {
        results = cached.toArray.map!(item => Container(item)).array;
      }
      return results;
    }

    string path = "/" ~ config.apiVersion ~ "/containers/json";
    if (all) {
      path ~= "?all=true";
    }

    auto response = httpClient.get(path);
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to list containers", config.endpoint, path));

    Container[] results;
    if (response.data.isArray) {
      results = response.data.toArray.map!(item => Container(item)).array;
      cache.set(cacheKey, response.data, config.cacheTtlSeconds);
    }
    return results;
  }

  /// Gets a single container by ID or name.
  Container getContainer(string idOrName) {
    enforce(!closed, "Client is closed");
    enforce(!idOrName.empty, "Container ID or name cannot be empty");

    string cacheKey = "container:" ~ idOrName;
    if (cache.has(cacheKey)) {
      return Container(cache.get(cacheKey));
    }

    string path = "/" ~ config.apiVersion ~ "/containers/" ~ idOrName ~ "/json";
    auto response = httpClient.get(path);

    if (response.statusCode == 404) {
      throw new PodmanNotFoundException("Container not found: " ~ idOrName, path);
    }
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to get container", config.endpoint, path));

    cache.set(cacheKey, response.data, config.cacheTtlSeconds);
    return Container(response.data);
  }

  /// Creates a new container.
  string createContainer(string name, Json config_) {
    enforce(!closed, "Client is closed");
    enforce(!name.empty, "Container name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/containers/create?name=" ~ name;
    auto response = httpClient.post(path, config_);
    enforce(response.success && response.statusCode == 201,
      createException(response.statusCode, "Failed to create container", config.endpoint, path));

    cache.invalidate("containers:running");
    cache.invalidate("containers:all");

    return response.data.isString("Id") ? response.data.getString("Id") : "";
  }

  /// Starts a container.
  void startContainer(string idOrName) {
    enforce(!closed, "Client is closed");
    enforce(!idOrName.empty, "Container ID or name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/containers/" ~ idOrName ~ "/start";
    auto response = httpClient.post(path, Json());
    enforce(response.success && (response.statusCode == 204 || response.statusCode == 304),
      createException(response.statusCode, "Failed to start container", config.endpoint, path));

    cache.invalidate("container:" ~ idOrName);
    cache.invalidate("containers:running");
  }

  /// Stops a container.
  void stopContainer(string idOrName, int timeout = 10) {
    enforce(!closed, "Client is closed");
    enforce(!idOrName.empty, "Container ID or name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/containers/" ~ idOrName ~ "/stop?t=" ~ format("%d", timeout);
    auto response = httpClient.post(path, Json());
    enforce(response.success && response.statusCode == 204,
      createException(response.statusCode, "Failed to stop container", config.endpoint, path));

    cache.invalidate("container:" ~ idOrName);
    cache.invalidate("containers:running");
  }

  /// Removes a container.
  void removeContainer(string idOrName, bool force = false, bool removeVolumes = false) {
    enforce(!closed, "Client is closed");
    enforce(!idOrName.empty, "Container ID or name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/containers/" ~ idOrName ~ "?force=" ~ (force ? "true"
        : "false") ~ "&v=" ~ (removeVolumes ? "true" : "false");
    auto response = httpClient.delete_(path);
    enforce(response.success && response.statusCode == 204,
      createException(response.statusCode, "Failed to remove container", config.endpoint, path));

    cache.invalidate("container:" ~ idOrName);
    cache.invalidate("containers:running");
    cache.invalidate("containers:all");
  }

  /// Gets container logs.
  string getContainerLogs(string idOrName, bool stdout = true, bool stderr = false) {
    enforce(!closed, "Client is closed");
    enforce(!idOrName.empty, "Container ID or name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/containers/" ~ idOrName ~ "/logs?stdout=" ~ (stdout ? "true"
        : "false") ~ "&stderr=" ~ (stderr ? "true" : "false");
    auto response = httpClient.get(path);
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to get container logs", config.endpoint, path));

    return response.rawOutput;
  }

  /// Pauses a container.
  void pauseContainer(string idOrName) {
    enforce(!closed, "Client is closed");
    enforce(!idOrName.empty, "Container ID or name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/containers/" ~ idOrName ~ "/pause";
    auto response = httpClient.post(path, Json());
    enforce(response.success && response.statusCode == 204,
      createException(response.statusCode, "Failed to pause container", config.endpoint, path));

    cache.invalidate("container:" ~ idOrName);
  }

  /// Unpauses a container.
  void unpauseContainer(string idOrName) {
    enforce(!closed, "Client is closed");
    enforce(!idOrName.empty, "Container ID or name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/containers/" ~ idOrName ~ "/unpause";
    auto response = httpClient.post(path, Json());
    enforce(response.success && response.statusCode == 204,
      createException(response.statusCode, "Failed to unpause container", config.endpoint, path));

    cache.invalidate("container:" ~ idOrName);
  }

  // Image operations

  /// Lists all images.
  override Image[] listImages() {
    enforce(!closed, "Client is closed");

    if (cache.has("images:all")) {
      Json cached = cache.get("images:all");
      Image[] results;
      if (cached.isArray) {
        results = cached.toArray.map!(item => Image(item)).array;
      }
      return results;
    }

    string path = "/" ~ config.apiVersion ~ "/images/json";
    auto response = httpClient.get(path);
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to list images", config.endpoint, path));

    Image[] results;
    if (response.data.isArray) {
      results = response.data.toArray.map!(item => Image(item)).array;
      cache.set("images:all", response.data, config.cacheTtlSeconds);
    }
    return results;
  }

  /// Pulls an image from a registry.
  void pullImage(string fromImage, string tag = "latest") {
    enforce(!closed, "Client is closed");
    enforce(!fromImage.empty, "Image name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/images/pull?fromImage=" ~ fromImage ~ "&tag=" ~ tag;
    auto response = httpClient.post(path, Json());
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to pull image", config.endpoint, path));

    cache.invalidate("images:all");
  }

  /// Removes an image.
  void removeImage(string image, bool force = false) {
    enforce(!closed, "Client is closed");
    enforce(!image.empty, "Image name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/images/" ~ image ~ "?force=" ~ (force ? "true"
        : "false");
    auto response = httpClient.delete_(path);
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to remove image", config.endpoint, path));

    cache.invalidate("images:all");
  }

  // Pod operations

  /// Lists all pods.
  override Pod[] listPods() {
    enforce(!closed, "Client is closed");

    if (cache.has("pods:all")) {
      Json cached = cache.get("pods:all");
      Pod[] results;
      if (cached.isArray) {
        results = cached.toArray.map!(item => Pod(item)).array;
      }
      return results;
    }

    string path = "/" ~ config.apiVersion ~ "/pods/json";
    auto response = httpClient.get(path);
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to list pods", config.endpoint, path));

    Pod[] results;
    if (response.data.isArray) {
      results = response.data.toArray.map!(item => Pod(item)).array;
      cache.set("pods:all", response.data, config.cacheTtlSeconds);
    }
    return results;
  }

  /// Gets a pod by name or ID.
  override Pod getPod(string nameOrId) {
    enforce(!closed, "Client is closed");
    enforce(!nameOrId.empty, "Pod name or ID cannot be empty");

    string cacheKey = "pod:" ~ nameOrId;
    if (cache.has(cacheKey)) {
      return Pod(cache.get(cacheKey));
    }

    string path = "/" ~ config.apiVersion ~ "/pods/" ~ nameOrId ~ "/json";
    auto response = httpClient.get(path);

    if (response.statusCode == 404) {
      throw new PodmanNotFoundException("Pod not found: " ~ nameOrId, path);
    }
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to get pod", config.endpoint, path));

    cache.set(cacheKey, response.data, config.cacheTtlSeconds);
    return Pod(response.data);
  }

  /// Creates a new pod.
  string createPod(string name, Json config_) {
    enforce(!closed, "Client is closed");
    enforce(!name.empty, "Pod name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/pods/create?name=" ~ name;
    auto response = httpClient.post(path, config_);
    enforce(response.success && response.statusCode == 201,
      createException(response.statusCode, "Failed to create pod", config.endpoint, path));

    cache.invalidate("pods:all");
    return response.data.isString("Id") ? response.data.getString("Id") : "";
  }

  /// Starts a pod.
  void startPod(string nameOrId) {
    enforce(!closed, "Client is closed");
    enforce(!nameOrId.empty, "Pod name or ID cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/pods/" ~ nameOrId ~ "/start";
    auto response = httpClient.post(path, Json());
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to start pod", config.endpoint, path));

    cache.invalidate("pod:" ~ nameOrId);
    cache.invalidate("pods:all");
  }

  /// Stops a pod.
  void stopPod(string nameOrId, int timeout = 10) {
    enforce(!closed, "Client is closed");
    enforce(!nameOrId.empty, "Pod name or ID cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/pods/" ~ nameOrId ~ "/stop?t=" ~ format("%d", timeout);
    auto response = httpClient.post(path, Json());
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to stop pod", config.endpoint, path));

    cache.invalidate("pod:" ~ nameOrId);
    cache.invalidate("pods:all");
  }

  /// Removes a pod.
  void removePod(string nameOrId, bool force = false) {
    enforce(!closed, "Client is closed");
    enforce(!nameOrId.empty, "Pod name or ID cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/pods/" ~ nameOrId ~ "?force=" ~ (force ? "true"
        : "false");
    auto response = httpClient.delete_(path);
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to remove pod", config.endpoint, path));

    cache.invalidate("pod:" ~ nameOrId);
    cache.invalidate("pods:all");
  }

  // Volume operations

  /// Lists all volumes.
  override Volume[] listVolumes() {
    enforce(!closed, "Client is closed");

    if (cache.has("volumes:all")) {
      Json cached = cache.get("volumes:all");
      Volume[] results;
      if (cached.hasKey("Volumes") && cached["Volumes"].isArray) {
        results = cached["Volumes"].toArray.map!(item => Volume(item)).array;
      }
      return results;
    }

    string path = "/" ~ config.apiVersion ~ "/volumes";
    auto response = httpClient.get(path);
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to list volumes", config.endpoint, path));

    Volume[] results;
    if (response.data.isArray("Volumes")) {
      results = response.data["Volumes"].toArray.map!(item => Volume(item)).array;
      cache.set("volumes:all", response.data, config.cacheTtlSeconds);
    }
    return results;
  }

  /// Creates a volume.
  string createVolume(string name, string driver = "local", string[string] options = null) {
    enforce(!closed, "Client is closed");
    enforce(!name.empty, "Volume name cannot be empty");

    Json config_ = Json([
        "Name": Json(name),
        "Driver": Json(driver)
      ]);

    if (options.length > 0) {
      Json[string] opts;
      foreach (key, value; options) {
        opts[key] = Json(value);
      }
      config_["Options"] = Json(opts);
    }

    string path = "/" ~ config.apiVersion ~ "/volumes/create";
    auto response = httpClient.post(path, config_);
    enforce(response.success && response.statusCode == 201,
      createException(response.statusCode, "Failed to create volume", config.endpoint, path));

    cache.invalidate("volumes:all");
    return response.data.isString("Name") ? response.data.getString("Name") : "";
  }

  /// Removes a volume.
  void removeVolume(string name, bool force = false) {
    enforce(!closed, "Client is closed");
    enforce(!name.empty, "Volume name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/volumes/" ~ name ~ "?force=" ~ (force ? "true"
        : "false");
    auto response = httpClient.delete_(path);
    enforce(response.success && response.statusCode == 204,
      createException(response.statusCode, "Failed to remove volume", config.endpoint, path));

    cache.invalidate("volumes:all");
  }

  // Network operations

  /// Lists all networks.
  override Network[] listNetworks() {
    enforce(!closed, "Client is closed");

    if (cache.has("networks:all")) {
      Json cached = cache.get("networks:all");
      Network[] results;
      if (cached.isArray) {
        results = cached.toArray.map!(item => Network(item)).array;
      }
      return results;
    }

    string path = "/" ~ config.apiVersion ~ "/networks";
    auto response = httpClient.get(path);
    enforce(response.success && response.statusCode == 200,
      createException(response.statusCode, "Failed to list networks", config.endpoint, path));

    Network[] results;
    if (response.data.isArray) {
      results = response.data.toArray.map!(item => Network(item)).array;
      cache.set("networks:all", response.data, config.cacheTtlSeconds);
    }
    return results;
  }

  /// Creates a network.
  string createNetwork(string name, string driver = "bridge") {
    enforce(!closed, "Client is closed");
    enforce(!name.empty, "Network name cannot be empty");

    Json config_ = Json([
        "Name": Json(name),
        "Driver": Json(driver)
      ]);
    string path = "/" ~ config.apiVersion ~ "/networks/create";
    auto response = httpClient.post(path, config_);
    enforce(response.success && response.statusCode == 201,
      createException(response.statusCode, "Failed to create network", config.endpoint, path));

    cache.invalidate("networks:all");
    return response.data.isString("Id") ? response.data.getString("Id") : "";
  }

  /// Removes a network.
  void removeNetwork(string name) {
    enforce(!closed, "Client is closed");
    enforce(!name.empty, "Network name cannot be empty");

    string path = "/" ~ config.apiVersion ~ "/networks/" ~ name;
    auto response = httpClient.delete_(path);
    enforce(response.success && response.statusCode == 204,
      createException(response.statusCode, "Failed to remove network", config.endpoint, path));

    cache.invalidate("networks:all");
  }

  // Resource management

  /// Close the client and release resources
  void close() {
    if (!closed) {
      httpClient.close();
      cache.clear();
      closed = true;
    }
  }

  /// Check if client is closed
  bool isClosed() const {
    return closed;
  }

  /// Get cache statistics
  CacheStats getCacheStats() const {
    return cache.getStats();
  }

  /// Clear cache
  void clearCache() {
    cache.clear();
  }

  /// Get configuration
}
