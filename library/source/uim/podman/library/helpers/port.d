/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.helpers.port;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Creates port bindings for container.
Json createPortBindings(string[string] portMap) {
  Json[string] bindings;
  foreach (containerPort, hostPort; portMap) {
    bindings[containerPort] = createPortBinding(hostPort);
  }
  return bindings.toJson;
}

Json createPortBinding(string hostPort) {
  return [
    [
      "HostPort": hostPort.toJson
    ].toJson
  ].toJson;
}
