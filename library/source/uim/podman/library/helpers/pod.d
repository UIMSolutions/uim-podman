module uim.podman.library.helpers.pod;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Creates a pod config for a simple pod creation.
Json createPodConfig(string name, string[] portBindings = []) {
  Json[] ports = portBindings.map!(port => port.toJson).array;

  Json config = Json([
    "Name": name.toJson,
    "Share": ["pid", "ipc", "uts"].toJson
  ]);
  
  if (ports.length > 0) {
    config["PortMappings"] = ports.toJson;
  }
  
  return config;
}
