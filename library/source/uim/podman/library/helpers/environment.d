module uim.podman.helpers.environment;

import uim.podman;

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