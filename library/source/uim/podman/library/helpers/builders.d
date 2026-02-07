/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.helpers.builders;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Fluent builder for container creation
class ContainerBuilder {
  private Json config;
  private string name = "";

  /// Sets container name
  ContainerBuilder withName(string name) {
    this.name = name;
    return this;
  }

  /// Sets container image
  ContainerBuilder withImage(string image) {
    config["Image"] = Json(image);
    return this;
  }

  /// Sets container environment variables
  ContainerBuilder withEnv(string[string] env) {
    Json[] envArray;
    foreach (key, value; env) {
      envArray ~= Json(key ~ "=" ~ value);
    }
    config["Env"] = Json(envArray);
    return this;
  }

  /// Sets container working directory
  ContainerBuilder withWorkDir(string dir) {
    config["WorkingDir"] = Json(dir);
    return this;
  }

  /// Sets container entrypoint
  ContainerBuilder withEntrypoint(string[] cmd) {
    config["Entrypoint"] = cmd.toJson;
    return this;
  }

  /// Sets container command
  ContainerBuilder withCommand(string[] cmd) {
    config["Cmd"] = cmd.toJson;
    return this;
  }

  /// Exposes a port
  ContainerBuilder exposePort(ushort port) {
    Json[string] exposed;
    if (config.hasKey("ExposedPorts")) {
      exposed = config["ExposedPorts"].toMap;
    }
    exposed[format("%d/tcp", port)] = Json();
    config["ExposedPorts"] = Json(exposed);
    return this;
  }

  /// Mounts a volume
  ContainerBuilder mountVolume(string src, string dest, string mode = "rw") {
    Json[] binds;
    if (config.hasKey("HostConfig") && config["HostConfig"].hasKey("Binds")) {
      binds = config["HostConfig"]["Binds"].toArray;
    }
    binds ~= Json(format("%s:%s:%s", src, dest, mode));
    
    if (!config.hasKey("HostConfig")) {
      config["HostConfig"] = Json.emptyObject();
    }
    config["HostConfig"]["Binds"] = Json(binds);
    return this;
  }

  /// Sets resource limits
  ContainerBuilder withMemoryLimit(ulong bytes) {
    if (!config.hasKey("HostConfig")) {
      config["HostConfig"] = Json.emptyObject();
    }
    config["HostConfig"]["Memory"] = Json(cast(long)bytes);
    return this;
  }

  /// Sets CPU limit
  ContainerBuilder withCpuLimit(double cpus) {
    if (!config.hasKey("HostConfig")) {
      config["HostConfig"] = Json.emptyObject();
    }
    config["HostConfig"]["CpuPeriod"] = Json(100000L);
    config["HostConfig"]["CpuQuota"] = Json(cast(long)(cpus * 100000));
    return this;
  }

  /// Adds a label
  ContainerBuilder withLabel(string key, string value) {
    Json[string] labels;
    if (config.hasKey("Labels")) {
      labels = config["Labels"].toMap;
    }
    labels[key] = Json(value);
    config["Labels"] = Json(labels);
    return this;
  }

  /// Gets the configuration JSON
  Json build() {
    if (!name.empty) {
      config["name"] = Json(name);
    }
    return config;
  }

  /// Gets the configuration JSON and name as tuple
  auto buildWithName() {
    return tuple(name, build());
  }
}

/// Fluent builder for pod creation
class PodBuilder {
  private Json config;
  private string name = "";

  this() {
    config = Json();
  }

  /// Sets pod name
  PodBuilder withName(string name) {
    this.name = name;
    return this;
  }

  /// Sets pod infra image
  PodBuilder withInfraImage(string image) {
    config["InfraImage"] = Json(image);
    return this;
  }

  /// Adds a label
  PodBuilder withLabel(string key, string value) {
    Json[string] labels;
    if (config.hasKey("Labels")) {
      labels = config["Labels"].toMap;
    }
    labels[key] = Json(value);
    config["Labels"] = Json(labels);
    return this;
  }

  /// Publishes a port
  PodBuilder publishPort(ushort containerPort, ushort hostPort = 0) {
    // Port publication configuration
    return this;
  }

  /// Gets the configuration JSON
  Json build() {
    if (!name.empty) {
      config["name"] = Json(name);
    }
    return config;
  }

  /// Gets the configuration JSON and name as tuple
  auto buildWithName() {
    return tuple(name, build());
  }
}

/// Create a new container builder
ContainerBuilder containerBuilder() {
  return new ContainerBuilder();
}

/// Create a new pod builder
PodBuilder podBuilder() {
  return new PodBuilder();
}
