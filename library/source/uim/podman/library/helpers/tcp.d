module uim.podman.library.helpers.tcp;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Checks if endpoint is TCP.
bool isTcpEndpoint(string endpoint) @safe {
  return endpoint.startsWith("http://") || endpoint.startsWith("https://");
}

/// Extracts TCP URL from endpoint.
string getTcpUrl(string endpoint) @safe {
  return isTcpEndpoint(endpoint) ? endpoint : "";
}

