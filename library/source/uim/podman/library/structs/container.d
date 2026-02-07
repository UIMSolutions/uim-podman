/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.structs.container;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Represents a Podman container.
struct PodmanContainer {
  string id;
  string name;
  string image;
  string state;
  string status;
  long created;
  long started;
  long finished;
  string[] ports;
  string[string] labels;
  string exitCode;

  this(Json data) {
    if (data.hasKey("Id")) id = data["Id"].getString;
    if (data["Names"].isArray && data["Names"].toArray.length > 0) {
      name = data["Names"].toArray[0].getString;
    }
    if (data.hasKey("Image")) {
      this.image = data["Image"].getString;
    }
    if (data.hasKey("State")) {
      this.state = data["State"].getString;
    }
    if (data.hasKey("Status")) {
      this.status = data["Status"].getString;
    }
    if (data.hasKey("Created")) {
      this.created = data["Created"].getInteger;
    }
    if (data.hasKey("Labels") && data["Labels"].isObject) {
      foreach (key, value; data["Labels"].toMap) {
        this.labels[key] = value.getString;
      }
    }
  }
}






