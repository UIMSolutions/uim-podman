/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.helpers.environment;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Creates environment variables array from key-value pairs.
Json createEnvironment(string[string] envMap) {
  Json[] envArray;
  foreach (key, value; envMap) {
    envArray ~= createEnvironment(key, value);
  }
  return Json(envArray);
}

Json createEnvironment(string key, string value) {
  return Json(key ~ "=" ~ value);
}