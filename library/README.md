# UIM Podman Library

A D language library for working with Podman container runtime using the uim-framework.

## Features

- Podman API client with vibe.d
- Container management (list, create, start, stop, remove)
- Image operations (list, pull, remove)
- Pod management
- Volume operations
- Network management

## Dependencies

- `uim-framework:core` - Core UIM framework
- `uim-framework:logging` - Logging support
- `vibe-d` - HTTP client and async I/O

## Building

```bash
dub build
```

## Testing

```bash
dub build --configuration=tests
```

## Usage

```d
import uim.podman.library;

void main() {
  auto config = defaultConfig();
  auto client = new PodmanClient(config);
  
  auto containers = client.listContainers();
  foreach(container; containers) {
    writeln(container.name);
  }
}
```

## API Version

Default Podman API version: v4.0.0

Podman maintains API compatibility with Docker API, so many operations are compatible.

## License

Apache 2.0
