/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
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

