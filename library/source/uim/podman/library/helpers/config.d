/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.helpers.config;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Creates a config for local Unix socket connection (default).
PodmanConfig defaultConfig() {
  return PodmanConfig.builder()
    .withEndpoint("unix:///run/podman/podman.sock")
    .withApiVersion("v4.0.0")
    .withUserSocket(true)
    .build();
}

/// Creates a config for system-wide Unix socket connection.
PodmanConfig systemConfig() {
  return PodmanConfig.builder()
    .withEndpoint("unix:///run/podman/podman.sock")
    .withApiVersion("v4.0.0")
    .withUserSocket(false)
    .withPoolSize(20)
    .build();
}

/// Creates a config for TCP connection.
PodmanConfig tcpConfig(string host = "127.0.0.1", ushort port = 8080) {
  return PodmanConfig.builder()
    .withEndpoint("http://" ~ host ~ ":" ~ to!string(port))
    .withApiVersion("v4.0.0")
    .withPoolSize(10)
    .build();
}

/// Creates a config for secure TCP connection.
PodmanConfig secureTcpConfig(string host, ushort port = 8081, string caCertPath = "") {
  return PodmanConfig.builder()
    .withEndpoint("https://" ~ host ~ ":" ~ to!string(port))
    .withApiVersion("v4.0.0")
    .withCaCertPath(caCertPath)
    .build();
}

/// Creates a config for remote SSH connection.
PodmanConfig sshConfig(string username, string host, ushort port = 22) {
  return PodmanConfig.builder()
    .withEndpoint(format("ssh://%s@%s:%d/run/podman/podman.sock", username, host, port))
    .withApiVersion("v4.0.0")
    .withConnectionTimeout(45)
    .build();
}

/// Detects and creates appropriate config from environment or defaults.
PodmanConfig autoDetectConfig() @trusted {
  import std.process : environment;
  
  // Check environment variables
  if (auto podmanHost = environment.get("PODMAN_HOST", null)) {
    return PodmanConfig.builder()
      .withEndpoint(podmanHost)
      .withApiVersion("v4.0.0")
      .build();
  }

  // Check for rootless socket
  if (auto home = environment.get("HOME", null)) {
    string userSocket = home ~ "/.local/share/podman/podman.sock";
    // In a real implementation, check if file exists
    return PodmanConfig.builder()
      .withEndpoint("unix:///" ~ userSocket)
      .withApiVersion("v4.0.0")
      .withUserSocket(true)
      .build();
  }

  // Fall back to default
  return defaultConfig();
}

/// Creates a minimal config for quick testing
PodmanConfig minimalConfig() {
  return PodmanConfig.builder()
    .withEndpoint("unix:///run/podman/podman.sock")
    .withApiVersion("v4.0.0")
    .withCaching(false)
    .withVerbose(false)
    .build();
}

/// Creates a development config with caching and verbose logging
PodmanConfig devConfig() {
  return PodmanConfig.builder()
    .withEndpoint("unix:///run/podman/podman.sock")
    .withApiVersion("v4.0.0")
    .withCaching(true)
    .withCacheTtl(60)
    .withVerbose(true)
    .withConnectionTimeout(45)
    .build();
}