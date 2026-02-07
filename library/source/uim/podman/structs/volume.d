module uim.podman.structs.volume;

import uim.podman;

mixin(ShowModule!());

@safe:

/// Represents a Podman volume.
struct Volume {
  string name;
  string driver;
  string mountPoint;
  string[string] labels;
  Json options;

  this(Json data) {
    if (data.hasKey("Name")) {
      this.name = data["Name"].toString;
    }
    if (data.hasKey("Driver")) {
      this.driver = data["Driver"].toString;
    }
    if (data.hasKey("Mountpoint")) {
      this.mountPoint = data["Mountpoint"].toString;
    }
    if (data.hasKey("Options")) {
      this.options = data["Options"];
    }
  }
}
