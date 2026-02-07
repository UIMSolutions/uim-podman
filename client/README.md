# UIM Podman Web Client

REST web client for the UIM Podman server.

## Usage

```d
import uim.podman.client;
import std.json : Json;

void main() {
  auto config = defaultWebClientConfig();
  config.baseUrl = "http://127.0.0.1:8080/api/v1";
  config.token = "devtoken";

  auto client = new PodmanWebClient(config);
  auto containers = client.listContainers(true);

  Json containerConfig = Json([
    "Image": Json("alpine:latest"),
    "Cmd": Json(["sleep", "60"])
  ]);

  auto id = client.createContainer("demo", containerConfig);
  client.startContainer(id);
}
```

## Configuration

Environment variables:

- UIM_PODMAN_API_TOKEN
- UIM_PODMAN_BASE_URL
- UIM_PODMAN_TIMEOUT
