module uim.podman.helpers.container;

import uim.podman;

mixin(ShowModule!());

@safe:

/// Creates a container config for a simple image run.
Json createContainerConfig(string image, string[] cmd = [], string[] env = []) {
  Json[] cmdArray = cmd.map!(c => Json(c)).array;
  Json[] envArray = env.map!(e => Json(e)).array;

  Json config = Json([
    "Image": image.toJson,
    "Cmd": cmdArray.toJson,
    "Env": envArray.toJson
  ]);

  return config;
}
/// 
unittest {
  mixin(ShowTest!"Test createContainerConfig");

  string image = "nginx:latest";
  string[] cmd = ["nginx", "-g", "daemon off;"];
  string[] env = ["ENV=production", "DEBUG=false"];

  Json config = createContainerConfig(image, cmd, env);

  assert(config["Image"] == image.toJson);
  assert(config["Cmd"] == cmd.toJson);
  assert(config["Env"] == env.toJson);
}
