/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.helpers.http;

import uim.podman.library;
import vibe.http.client;
import vibe.core.core;
import std.net.curl;

mixin(ShowModule!());

@safe:

/// HTTP response wrapper
struct HttpResponse {
  int statusCode;
  Json data;
  string rawOutput;
  string[string] headers;
  bool success;

  /// Check if response is successful (2xx status code)
  bool isSuccess() const {
    return statusCode >= 200 && statusCode < 300;
  }
}


