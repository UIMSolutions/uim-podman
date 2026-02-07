module uim.podman.client.dtos;

import std.json : Json;

@safe:

struct RestContainer {
  string id;
  string name;
  string image;
  string state;
  string status;
  long created;
  long started;
  long finished;
  string exitCode;
  string[] ports;
  string[string] labels;

  static RestContainer fromJson(Json data) {
    RestContainer result;
    if (data.hasKey("id")) result.id = data["id"].getString;
    if (data.hasKey("name")) result.name = data["name"].getString;
    if (data.hasKey("image")) result.image = data["image"].getString;
    if (data.hasKey("state")) result.state = data["state"].getString;
    if (data.hasKey("status")) result.status = data["status"].getString;
    if (data.hasKey("created")) result.created = data["created"].getInteger;
    if (data.hasKey("started")) result.started = data["started"].getInteger;
    if (data.hasKey("finished")) result.finished = data["finished"].getInteger;
    if (data.hasKey("exitCode")) result.exitCode = data["exitCode"].getString;

    if (data.hasKey("ports") && data["ports"].isArray) {
      foreach (item; data["ports"].toArray) {
        result.ports ~= item.getString;
      }
    }

    if (data.hasKey("labels") && data["labels"].isObject) {
      foreach (key, value; data["labels"].toMap) {
        result.labels[key] = value.getString;
      }
    }

    return result;
  }
}

struct RestImage {
  string id;
  string[] repoTags;
  long created;
  long size;
  long virtualSize;
  string[string] labels;

  static RestImage fromJson(Json data) {
    RestImage result;
    if (data.hasKey("id")) result.id = data["id"].getString;
    if (data.hasKey("created")) result.created = data["created"].getInteger;
    if (data.hasKey("size")) result.size = data["size"].getInteger;
    if (data.hasKey("virtualSize")) result.virtualSize = data["virtualSize"].getInteger;

    if (data.hasKey("repoTags") && data["repoTags"].isArray) {
      foreach (item; data["repoTags"].toArray) {
        result.repoTags ~= item.getString;
      }
    }

    if (data.hasKey("labels") && data["labels"].isObject) {
      foreach (key, value; data["labels"].toMap) {
        result.labels[key] = value.getString;
      }
    }

    return result;
  }
}

struct RestPod {
  string id;
  string name;
  string status;
  long created;
  long started;
  size_t containers;
  string[] containerIds;
  string[string] labels;

  static RestPod fromJson(Json data) {
    RestPod result;
    if (data.hasKey("id")) result.id = data["id"].getString;
    if (data.hasKey("name")) result.name = data["name"].getString;
    if (data.hasKey("status")) result.status = data["status"].getString;
    if (data.hasKey("created")) result.created = data["created"].getInteger;
    if (data.hasKey("started")) result.started = data["started"].getInteger;
    if (data.hasKey("containers")) result.containers = cast(size_t)data["containers"].getInteger;

    if (data.hasKey("containerIds") && data["containerIds"].isArray) {
      foreach (item; data["containerIds"].toArray) {
        result.containerIds ~= item.getString;
      }
    }

    if (data.hasKey("labels") && data["labels"].isObject) {
      foreach (key, value; data["labels"].toMap) {
        result.labels[key] = value.getString;
      }
    }

    return result;
  }
}

struct RestVolume {
  string name;
  string driver;
  string mountPoint;
  Json options;
  string[string] labels;

  static RestVolume fromJson(Json data) {
    RestVolume result;
    if (data.hasKey("name")) result.name = data["name"].getString;
    if (data.hasKey("driver")) result.driver = data["driver"].getString;
    if (data.hasKey("mountPoint")) result.mountPoint = data["mountPoint"].getString;
    if (data.hasKey("options")) result.options = data["options"];

    if (data.hasKey("labels") && data["labels"].isObject) {
      foreach (key, value; data["labels"].toMap) {
        result.labels[key] = value.getString;
      }
    }

    return result;
  }
}

struct RestNetwork {
  string id;
  string name;
  string driver;
  string scope_;

  static RestNetwork fromJson(Json data) {
    RestNetwork result;
    if (data.hasKey("id")) result.id = data["id"].getString;
    if (data.hasKey("name")) result.name = data["name"].getString;
    if (data.hasKey("driver")) result.driver = data["driver"].getString;
    if (data.hasKey("scope")) result.scope_ = data["scope"].getString;

    return result;
  }
}
