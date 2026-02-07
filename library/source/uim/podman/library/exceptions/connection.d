module uim.podman.library.exceptions.connection;

import uim.podman.library;
@safe:

/// Exception thrown when connection to Podman fails
class PodmanConnectionException : PodmanException {
  this(string msg, string endpoint = "") @safe {
    super(msg, 0, endpoint);
  }
}