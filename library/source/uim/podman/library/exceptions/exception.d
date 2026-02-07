module uim.podman.library.exceptions.exception;

import uim.podman.library;
@safe:

/// Base exception for Podman API errors
class PodmanException : Exception {
  int statusCode;
  string endpoint;
  string requestPath;
  Json errorData;

  this(string msg, int statusCode = 0, string endpoint = "", string requestPath = "") 
    {
    super(msg);
    this.statusCode = statusCode;
    this.endpoint = endpoint;
    this.requestPath = requestPath;
  }

  override string toString() {
    if (statusCode == 0) {
      return ""; // TODO: super.toString();
    }
    return format("PodmanException[%d]: %s (endpoint: %s, path: %s)", 
      statusCode, msg, endpoint, requestPath);
  }
}