module uim.podman.library.structs.config;

import uim.podman.library;

mixin(ShowModule!());

@safe:

// Podman daemon connection configuration
struct PodmanConfig {
  string endpoint;  // e.g., "unix:///run/podman/podman.sock" or "http://127.0.0.1:8080"
  string apiVersion = "v4.0.0";
  bool insecureSkipVerify = false;
  string caCertPath = "";
  bool useUserSocket = true;  // Use user socket by default
}