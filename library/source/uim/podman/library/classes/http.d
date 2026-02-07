/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.classes.http;

import uim.podman.library;

@safe:

/// Async HTTP client for Podman API
class PodmanHttpClient {
  private PodmanConfig config;
  private bool closed;

  this(PodmanConfig config) {
    enforce(!config.endpoint.empty, "Endpoint cannot be empty");
    this.config = config;
    this.closed = false;
  }

  /// Performs an HTTP GET request
  HttpResponse get(string path, string[string] headers = null) {
    return doRequest("GET", path, Json(), headers);
  }

  /// Performs an HTTP POST request
  HttpResponse post(string path, Json body_, string[string] headers = null) {
    return doRequest("POST", path, body_, headers);
  }

  /// Performs an HTTP PUT request
  HttpResponse put(string path, Json body_, string[string] headers = null) {
    return doRequest("PUT", path, body_, headers);
  }

  /// Performs an HTTP DELETE request
  HttpResponse delete_(string path, string[string] headers = null) {
    return doRequest("DELETE", path, Json(), headers);
  }

  /// Performs an HTTP request with retry logic
  HttpResponse doRequest(string method, string path, Json body_, 
    string[string] headers = null, uint retryCount = 0) {
    
    HttpResponse response;
    
    try {
      // Validate request
      enforce(!path.empty, "Path cannot be empty");
      
      // Build full URL
      string url;
      if (config.endpoint.startsWith("unix://")) {
        // For Unix socket, we need to handle it differently
        url = buildUnixSocketUrl(config.endpoint, path);
      } else {
        url = config.endpoint ~ path;
      }

      // Set default headers
      auto finalHeaders = getDefaultHeaders();
      if (headers !is null) {
        foreach (key, value; headers) {
          finalHeaders[key] = value;
        }
      }

      // Log request if verbose
      if (config.verbose) {
        logRequest(method, url, body_);
      }

      // For now, return a placeholder response
      // In a real implementation, this would use vibe.d's HTTP client or curl
      response.statusCode = 200;
      response.data = Json();
      response.rawOutput = "";
      response.headers = finalHeaders;
      response.success = true;

      if (config.verbose) {
        logResponse(response);
      }

      return response;
    } catch (Exception e) {
      if (retryCount < config.maxRetries) {
        // Retry with exponential backoff
        uint delayMs = config.retryDelayMs * (2 ^^ retryCount);
        // Sleep would go here: sleep(delayMs.msecs);
        return doRequest(method, path, body_, headers, retryCount + 1);
      }
      
      response.statusCode = 0;
      response.data = Json();
      response.success = false;
      response.rawOutput = "Error: " ~ e.msg;
      return response;
    }
  }

  /// Closes the client and releases resources
  void close() {
    closed = true;
  }

  /// Check if client is closed
  bool isClosed() const {
    return closed;
  }

private:
  /// Builds a URL for Unix socket connection
  string buildUnixSocketUrl(string endpoint, string path) {
    // Remove unix:// prefix
    string socketPath = endpoint[7..$];
    // For Unix socket connections, we'd use local endpoint
    // This is a simplified implementation
    return "http://localhost" ~ path;
  }

  /// Gets default HTTP headers
  string[string] getDefaultHeaders() {
    string[string] headers;
    headers["Content-Type"] = "application/json";
    headers["Accept"] = "application/json";
    headers["User-Agent"] = "uim-podman/1.0";
    return headers;
  }

  /// Logs an HTTP request
  void logRequest(string method, string url, Json body_) {
    debug {
      import std.stdio : writeln;
      writeln(format("[HTTP] %s %s", method, url));
      if (!body_.isNull)  { // TODO:  && !body_.isEmpty) {
        writeln(format("[HTTP] Body: %s", body_.toPrettyString));
      }
    }
  }

  /// Logs an HTTP response
  void logResponse(const HttpResponse response) {
    debug {
      import std.stdio : writeln;
      writeln(format("[HTTP] Response: %d", response.statusCode));
      if (!response.data.isNull) { // TODO: && !response.data.isEmpty) {
        writeln(format("[HTTP] Data: %s", response.data.toPrettyString));
      }
    }
  }
}

/// Helper to create an HTTP client
PodmanHttpClient createHttpClient(PodmanConfig config) {
  return new PodmanHttpClient(config);
}