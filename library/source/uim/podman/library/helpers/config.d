module uim.podman.library.helpers.config;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Creates a config for local Unix socket connection (default).
PodmanConfig defaultConfig() @safe {
  return PodmanConfig("unix:///run/podman/podman.sock", "v4.0.0", false, "", true);
}

/// Creates a config for system-wide Unix socket connection.
PodmanConfig systemConfig() @safe {
  return PodmanConfig("unix:///run/podman/podman.sock", "v4.0.0", false, "", false);
}

/// Creates a config for TCP connection.
PodmanConfig tcpConfig(string host = "127.0.0.1", ushort port = 8080) @safe {
  return PodmanConfig("http://" ~ host ~ ":" ~ to!string(port), "v4.0.0", false, "", false);
}

/// Creates a config for secure TCP connection.
PodmanConfig secureTcpConfig(string host, ushort port = 8081, string caCertPath = "") @safe {
  return PodmanConfig("https://" ~ host ~ ":" ~ to!string(port), "v4.0.0", false, caCertPath, false);
}