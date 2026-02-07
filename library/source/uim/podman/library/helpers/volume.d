module uim.podman.library.helpers.volume;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Creates volume mounts for container.
Json createVolumeMounts(string[string] mounts) {
  Json[] volumeList;
  foreach (containerPath, hostPath; mounts) {
    volumeList ~= createVolumeMount(containerPath, hostPath);
  }
  return Json(volumeList);
}

// Creates a single volume mount configuration.
Json createVolumeMount(string containerPath, string hostPath) {
  return [
      "Source": hostPath,
      "Target": containerPath,
      "Type": "bind"
    ].toJson;
}
