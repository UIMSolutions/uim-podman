/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
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
