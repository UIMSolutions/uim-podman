module uim.podman.client.config;

import std.conv : to;
import std.process : environment;

@safe:

/// Configuration for the Podman REST web client.
struct PodmanWebClientConfig {
  string baseUrl = "http://127.0.0.1:8080/api/v1";
  string token;
  uint timeoutSeconds = 30;
}

/// Loads default configuration from environment variables.
PodmanWebClientConfig defaultWebClientConfig() {
  PodmanWebClientConfig config;

  config.token = environment.get("UIM_PODMAN_API_TOKEN", "");

  auto baseUrl = environment.get("UIM_PODMAN_BASE_URL", "");
  if (baseUrl.length) {
    config.baseUrl = baseUrl;
  }

  auto timeout = environment.get("UIM_PODMAN_TIMEOUT", "");
  if (timeout.length) {
    try {
      config.timeoutSeconds = to!uint(timeout);
    } catch (Exception) {
      // Keep default timeout on parse errors.
    }
  }

  return config;
}

unittest {
  auto config = PodmanWebClientConfig();
  assert(config.baseUrl.length > 0);
  assert(config.timeoutSeconds > 0);
}
