/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.structs.pod;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Represents a Podman pod.
struct Pod {
  string id;
  string name;
  string status;
  long created;
  long started;
  size_t numberOfContainers;
  string[] containerIds;
  string[string] labels;

  this(Json data) {
    if (data.isString("Id")) {
      this.id = data["Id"].toString;
    }
    if (data.isString("Name")) {
      this.name = data["Name"].toString;
    }
    if (data.isString("Status")) {
      this.status = data["Status"].toString;
    }
    if (data.isInteger("Created")) {
      this.created = data["Created"].getInteger;
    }
    if (data.hasKey("Containers") && data["Containers"].isArray) {
      this.numberOfContainers = data["Containers"].toArray.length;
    }
    if (data.hasKey("Labels") && data["Labels"].isObject) {
      foreach (key, value; data["Labels"].toMap) {
        this.labels[key] = value.toString;
      }
    }
  }
}