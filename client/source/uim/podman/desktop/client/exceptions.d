module uim.podman.desktop.client.exceptions;

@safe:

/// Exception raised when the REST client receives an error response.
class PodmanWebClientException : Exception {
  int statusCode;
  string responseBody;

  this(string message, int statusCode, string responseBody = "") {
    super(message);
    this.statusCode = statusCode;
    this.responseBody = responseBody;
  }
}
