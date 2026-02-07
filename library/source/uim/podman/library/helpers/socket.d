/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.helpers.socket;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Checks if endpoint is a Unix socket.
bool isUnixSocket(string endpoint) @safe {
  return endpoint.startsWith("unix://");
}

/// Extracts socket path from Unix endpoint.
string getUnixSocketPath(string endpoint) @safe {
  return isUnixSocket(endpoint) ? endpoint[7 .. $] : "";  // Strip "unix://"
}

/// Gets the user socket path.
string getUserSocketPath() @safe {
  return "unix:///run/user/1000/podman/podman.sock";
}

/// Gets the system socket path.
string getSystemSocketPath() @safe {
  return "unix:///run/podman/podman.sock";
}
