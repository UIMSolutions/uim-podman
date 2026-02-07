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
