module uim.podman.desktop.server.config;

import std.conv : to;
import std.process : environment;
import std.string : split, strip;
@safe:

/// Configuration for the Podman REST server.
struct PodmanServerConfig {
  string host = "127.0.0.1";
  ushort port = 8080;
  string basePath = "/api/v1";
  string token;
  string[] corsOrigins;
  string corsAllowHeaders = "Authorization, Content-Type";
  string corsAllowMethods = "GET, POST, DELETE, OPTIONS";
  uint corsMaxAgeSeconds = 600;
  string podmanEndpoint = "unix:///run/podman/podman.sock";
  string apiVersion = "v4.0.0";
}

/// Loads default configuration from environment variables.
PodmanServerConfig defaultServerConfig() {
  PodmanServerConfig config;

  config.token = environment.get("UIM_PODMAN_API_TOKEN", "");

  auto corsOrigins = environment.get("UIM_PODMAN_CORS_ORIGINS", "");
  if (corsOrigins.length) {
    foreach (origin; corsOrigins.split(",")) {
      auto trimmed = origin.strip;
      if (trimmed.length) {
        config.corsOrigins ~= trimmed;
      }
    }
  }

  auto corsHeaders = environment.get("UIM_PODMAN_CORS_HEADERS", "");
  if (corsHeaders.length) {
    config.corsAllowHeaders = corsHeaders;
  }

  auto corsMethods = environment.get("UIM_PODMAN_CORS_METHODS", "");
  if (corsMethods.length) {
    config.corsAllowMethods = corsMethods;
  }

  auto corsMaxAge = environment.get("UIM_PODMAN_CORS_MAX_AGE", "");
  if (corsMaxAge.length) {
    try {
      config.corsMaxAgeSeconds = to!uint(corsMaxAge);
    } catch (Exception) {
      // Keep default max age on parse errors.
    }
  }

  auto host = environment.get("UIM_PODMAN_HOST", "");
  if (host.length) {
    config.host = host;
  }

  auto port = environment.get("UIM_PODMAN_PORT", "");
  if (port.length) {
    try {
      config.port = to!ushort(port);
    } catch (Exception) {
      // Keep default port on parse errors.
    }
  }

  auto basePath = environment.get("UIM_PODMAN_BASE_PATH", "");
  if (basePath.length) {
    config.basePath = basePath;
  }

  auto endpoint = environment.get("UIM_PODMAN_ENDPOINT", "");
  if (endpoint.length) {
    config.podmanEndpoint = endpoint;
  }

  auto apiVersion = environment.get("UIM_PODMAN_API_VERSION", "");
  if (apiVersion.length) {
    config.apiVersion = apiVersion;
  }

  return config;
}
