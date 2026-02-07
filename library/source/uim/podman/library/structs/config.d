/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.structs.config;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Podman daemon connection configuration with builder pattern
struct PodmanConfig {
  string endpoint = "unix:///run/podman/podman.sock";  // Default endpoint
  string apiVersion = "v4.0.0";                        // Default API version
  bool insecureSkipVerify = false;                     // Skip TLS verification
  string caCertPath = "";                              // Path to CA certificate
  bool useUserSocket = true;                           // Use user socket by default
  uint connectionTimeout = 30;                         // Connection timeout in seconds
  uint requestTimeout = 60;                            // Request timeout in seconds
  uint maxRetries = 3;                                 // Max retries for failed requests
  uint retryDelayMs = 100;                             // Delay between retries in milliseconds
  uint poolSize = 10;                                  // Connection pool size
  bool enableCaching = true;                           // Enable response caching
  uint cacheTtlSeconds = 300;                          // Cache TTL in seconds
  bool verbose = false;                                // Enable verbose logging

  /// Creates a config builder
  static ConfigBuilder builder() @safe {
    return ConfigBuilder();
  }

  /// Validates the configuration
  bool validate() const @safe {
    if (endpoint.empty) return false;
    if (apiVersion.empty) return false;
    if (connectionTimeout == 0 || requestTimeout == 0) return false;
    if (poolSize == 0) return false;
    return true;
  }

  /// Returns a string representation
  string toString() const @safe {
    return format("PodmanConfig(endpoint=%s, apiVersion=%s, poolSize=%d)", 
      endpoint, apiVersion, poolSize);
  }
}

/// Builder for fluent configuration of PodmanConfig
struct ConfigBuilder {
  private PodmanConfig config;

  /// Sets the endpoint
  ref ConfigBuilder withEndpoint(string endpoint) return @safe {
    config.endpoint = endpoint;
    return this;
  }

  /// Sets the API version
  ref ConfigBuilder withApiVersion(string version_) return @safe {
    config.apiVersion = version_;
    return this;
  }

  /// Sets insecure skip verify
  ref ConfigBuilder withInsecureSkipVerify(bool value) return @safe {
    config.insecureSkipVerify = value;
    return this;
  }

  /// Sets CA cert path
  ref ConfigBuilder withCaCertPath(string path) return @safe {
    config.caCertPath = path;
    return this;
  }

  /// Sets use user socket flag
  ref ConfigBuilder withUserSocket(bool value) return @safe {
    config.useUserSocket = value;
    return this;
  }

  /// Sets connection timeout
  ref ConfigBuilder withConnectionTimeout(uint seconds) return @safe {
    config.connectionTimeout = seconds;
    return this;
  }

  /// Sets request timeout
  ref ConfigBuilder withRequestTimeout(uint seconds) return @safe {
    config.requestTimeout = seconds;
    return this;
  }

  /// Sets max retries
  ref ConfigBuilder withMaxRetries(uint retries) return @safe {
    config.maxRetries = retries;
    return this;
  }

  /// Sets pool size
  ref ConfigBuilder withPoolSize(uint size) return @safe {
    config.poolSize = size;
    return this;
  }

  /// Sets caching enabled
  ref ConfigBuilder withCaching(bool enabled) return @safe {
    config.enableCaching = enabled;
    return this;
  }

  /// Sets cache TTL
  ref ConfigBuilder withCacheTtl(uint seconds) return @safe {
    config.cacheTtlSeconds = seconds;
    return this;
  }

  /// Sets verbose logging
  ref ConfigBuilder withVerbose(bool verbose) return @safe {
    config.verbose = verbose;
    return this;
  }

  /// Builds and returns the config
  PodmanConfig build() @safe {
    enforce(config.validate(), "Invalid configuration: validation failed");
    return config;
  }
}
