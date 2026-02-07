module uim.podman.structs.log;

import uim.podman;

mixin(ShowModule!());

@safe:

/// Represents container logs response.
struct LogsResponse {
  string output;
  bool isError;

  this(string output, bool isError = false) {
    this.output = output;
    this.isError = isError;
  }
}
