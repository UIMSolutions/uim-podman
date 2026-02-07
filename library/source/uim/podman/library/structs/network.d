module uim.podman.library.structs.network;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Represents a Podman network.
struct Network {
  string id;
  string name;
  string driver;
  string scope_;
  string ipam;

  this(Json data) {
    if (data.hasKey("Id")) {
      this.id = data["Id"].toString;
    }
    if (data.hasKey("Name")) {
      this.name = data["Name"].toString;
    }
    if (data.hasKey("Driver")) {
      this.driver = data["Driver"].toString;
    }
    if (data.hasKey("Scope")) {
      this.scope_ = data["Scope"].toString;
    }
  }
}