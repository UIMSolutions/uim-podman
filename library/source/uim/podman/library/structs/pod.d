module uim.podman.structs.pod;

import uim.podman;

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