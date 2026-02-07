/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.interfaces.client;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Interface for Podman API client implementations
interface IPodmanClient {
  /// Lists all containers
  Container[] listContainers(bool all = false);

  /// Gets a single container by ID or name
  Container getContainer(string idOrName);

  /// Creates a new container
  string createContainer(string name, Json config);

  /// Starts a container
  void startContainer(string idOrName);

  /// Stops a container
  void stopContainer(string idOrName, int timeout = 10);

  /// Removes a container
  void removeContainer(string idOrName, bool force = false, bool removeVolumes = false);

  /// Gets container logs
  string getContainerLogs(string idOrName, bool stdout = true, bool stderr = false);

  /// Pauses a container
  void pauseContainer(string idOrName);

  /// Unpauses a container
  void unpauseContainer(string idOrName);

  /// Lists all images
  PodmanImage[] listImages();

  /// Pulls an image from a registry
  void pullImage(string fromImage, string tag = "latest");

  /// Removes an image
  void removeImage(string image, bool force = false);

  /// Lists all pods
  Pod[] listPods();

  /// Gets a pod by name or ID
  Pod getPod(string nameOrId);

  /// Creates a new pod
  string createPod(string name, Json config);

  /// Starts a pod
  void startPod(string nameOrId);

  /// Stops a pod
  void stopPod(string nameOrId, int timeout = 10);

  /// Removes a pod
  void removePod(string nameOrId, bool force = false);

  /// Lists all volumes
  Volume[] listVolumes();

  /// Creates a volume
  string createVolume(string name, string driver = "local", string[string] options = null);

  /// Removes a volume
  void removeVolume(string name, bool force = false);

  /// Lists all networks
  Network[] listNetworks();

  /// Creates a network
  string createNetwork(string name, string driver = "bridge");

  /// Removes a network
  void removeNetwork(string name);
}

/// Interface for HTTP client implementations
interface IHttpClient {
  /// Performs a GET request
  HttpResponse get(string path, string[string] headers = null);

  /// Performs a POST request
  HttpResponse post(string path, Json body_, string[string] headers = null);

  /// Performs a PUT request
  HttpResponse put(string path, Json body_, string[string] headers = null);

  /// Performs a DELETE request
  HttpResponse delete_(string path, string[string] headers = null);

  /// Closes the client
  void close();

  /// Check if client is closed
  bool isClosed() const;
}

/// Interface for cache implementations
interface ICache {
  /// Get value from cache
  Json get(string key);

  /// Check if key exists and is valid
  bool has(string key);

  /// Set value in cache
  void set(string key, Json data, uint ttlSeconds);

  /// Invalidate cache entry
  void invalidate(string key);

  /// Clear all cache
  void clear();

  /// Get cache statistics
  CacheStats getStats() const;
}
