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
  ref ContainerBuilder withName(string name) return @safe {
    this.name = name;
    return this;
  }

  /// Sets container image
  ref ContainerBuilder withImage(string image) return @safe {
    config["Image"] = Json(image);
    return this;
  }

  /// Sets container environment variables
  ref ContainerBuilder withEnv(string[string] env) return @safe {
    Json[] envArray;
    foreach (key, value; env) {
      envArray ~= Json(key ~ "=" ~ value);
    }
    config["Env"] = Json(envArray);
    return this;
  }

  /// Sets container working directory
  ref ContainerBuilder withWorkDir(string dir) return @safe {
    config["WorkingDir"] = Json(dir);
    return this;
  }

  /// Sets container entrypoint
  ref ContainerBuilder withEntrypoint(string[] cmd) return @safe {
    config["Entrypoint"] = Json(cmd);
    return this;
  }

  /// Sets container command
  ref ContainerBuilder withCommand(string[] cmd) return @safe {
    config["Cmd"] = Json(cmd);
    return this;
  }

  /// Exposes a port
  ref ContainerBuilder exposePort(ushort port) return @safe {
    Json[string] exposed;
    if (config.hasKey("ExposedPorts")) {
      exposed = config["ExposedPorts"].toMap;
    }
    exposed[format("%d/tcp", port)] = Json();
    config["ExposedPorts"] = Json(exposed);
    return this;
  }

  /// Mounts a volume
  ref ContainerBuilder mountVolume(string src, string dest, string mode = "rw") return @safe {
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
  ref ContainerBuilder withMemoryLimit(ulong bytes) return @safe {
    if (!config.hasKey("HostConfig")) {
      config["HostConfig"] = Json.emptyObject();
    }
    config["HostConfig"]["Memory"] = Json(cast(long)bytes);
    return this;
  }

  /// Sets CPU limit
  ref ContainerBuilder withCpuLimit(double cpus) return @safe {
    if (!config.hasKey("HostConfig")) {
      config["HostConfig"] = Json.emptyObject();
    }
    config["HostConfig"]["CpuPeriod"] = Json(100000L);
    config["HostConfig"]["CpuQuota"] = Json(cast(long)(cpus * 100000));
    return this;
  }

  /// Adds a label
  ref ContainerBuilder withLabel(string key, string value) return @safe {
    Json[string] labels;
    if (config.hasKey("Labels")) {
      labels = config["Labels"].toMap;
    }
    labels[key] = Json(value);
    config["Labels"] = Json(labels);
    return this;
  }

  /// Gets the configuration JSON
  Json build() @safe {
    if (!name.empty) {
      config["name"] = Json(name);
    }
    return config;
  }

  /// Gets the configuration JSON and name as tuple
  auto buildWithName() @safe {
    return tuple(name, build());
  }
}

/// Fluent builder for pod creation
class PodBuilder {
  private Json config;
  private string name = "";

  this() @safe {
    config = Json();
  }

  /// Sets pod name
  ref PodBuilder withName(string name) return @safe {
    this.name = name;
    return this;
  }

  /// Sets pod infra image
  ref PodBuilder withInfraImage(string image) return @safe {
    config["InfraImage"] = Json(image);
    return this;
  }

  /// Adds a label
  ref PodBuilder withLabel(string key, string value) return @safe {
    Json[string] labels;
    if (config.hasKey("Labels")) {
      labels = config["Labels"].toMap;
    }
    labels[key] = Json(value);
    config["Labels"] = Json(labels);
    return this;
  }

  /// Publishes a port
  ref PodBuilder publishPort(ushort containerPort, ushort hostPort = 0) return @safe {
    // Port publication configuration
    return this;
  }

  /// Gets the configuration JSON
  Json build() @safe {
    if (!name.empty) {
      config["name"] = Json(name);
    }
    return config;
  }

  /// Gets the configuration JSON and name as tuple
  auto buildWithName() @safe {
    return tuple(name, build());
  }
}

/// Create a new container builder
ContainerBuilder containerBuilder() @safe {
  return new ContainerBuilder();
}

/// Create a new pod builder
PodBuilder podBuilder() @safe {
  return new PodBuilder();
}
