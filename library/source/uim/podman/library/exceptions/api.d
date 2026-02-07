/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.exceptions.api;

import uim.podman.library;

mixin(ShowModule!());

@safe:





/// Exception thrown for HTTP 400 Bad Request errors
class PodmanBadRequestException : PodmanException {
  this(string msg, string path = "") @safe {
    super(msg, 400, "", path);
  }
}

/// Exception thrown for HTTP 404 Not Found errors
class PodmanNotFoundException : PodmanException {
  this(string msg, string resource = "") @safe {
    super(msg, 404, "", resource);
  }
}

/// Exception thrown for HTTP 500 Server errors
class PodmanServerException : PodmanException {
  this(string msg, string path = "") @safe {
    super(msg, 500, "", path);
  }
}

/// Exception thrown for timeout errors
class PodmanTimeoutException : PodmanException {
  uint timeoutSeconds;

  this(string msg, uint timeout = 0) @safe {
    super(msg, 0);
    this.timeoutSeconds = timeout;
  }
}

/// Exception thrown for invalid configuration
class PodmanConfigException : PodmanException {
  this(string msg) @safe {
    super(msg, 0);
  }
}

/// Exception thrown for authentication errors
class PodmanAuthException : PodmanException {
  this(string msg) @safe {
    super(msg, 401);
  }
}

/// Creates appropriate exception from HTTP response
PodmanException createException(int statusCode, string msg, string endpoint = "", string path = "") @safe {
  switch (statusCode) {
    case 400:
      return new PodmanBadRequestException(msg, path);
    case 404:
      return new PodmanNotFoundException(msg, path);
    case 401:
      return new PodmanAuthException(msg);
    case 500:
    case 502:
    case 503:
      return new PodmanServerException(msg, path);
    default:
      return new PodmanException(msg, statusCode, endpoint, path);
  }
}
