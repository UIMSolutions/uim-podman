/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.helpers.general;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Converts string array to Json array.
Json stringArrayToJSON(string[] array) {
  Json[] result;
  foreach (item; array) {
    result ~= Json(item);
  }
  return Json(result);
}

/// Converts string map to Json object.
Json stringMapToJSON(string[string] map) {
  Json[string] result;
  foreach (key, value; map) {
    result[key] = Json(value);
  }
  return Json(result);
}







