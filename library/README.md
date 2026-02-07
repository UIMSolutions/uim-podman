# UIM Podman Library

A modern D language library for working with Podman container runtime, powered by uim-framework and vibe.d.

## Features

### Core Features
- **Podman API Client** - Complete async HTTP client with vibe.d
- **Container Management** - List, create, start, stop, remove containers
- **Image Operations** - Pull, list, remove images
- **Pod Management** - Full pod lifecycle management
- **Volume Operations** - Create, list, remove volumes
- **Network Management** - Create, list, remove networks

### Advanced Features
- **Fluent Configuration Builder** - Easy setup with builder pattern
- **Response Caching** - Automatic in-memory caching for performance
- **Connection Pooling** - Efficient connection management
- **Advanced Error Handling** - Custom exception types for better error management
- **Fluent API Builders** - Method chaining for container and pod configuration
- **Comprehensive Interfaces** - Better extensibility and testability
- **Resource Management** - Proper lifecycle management
- **Retry Logic** - Automatic retry with exponential backoff
- **Verbose Logging** - Debug support for troubleshooting

## Quick Start

### Basic Usage

```d
import uim.podman;

void main() {
  auto client = new PodmanClient(defaultConfig());
  
  auto containers = client.listContainers();
  foreach(container; containers) {
    writeln(container.name);
  }
  
  client.close();
}
```

### Configuration with Builder

```d
import uim.podman;

void main() {
  auto config = PodmanConfig.builder()
    .withEndpoint("unix:///run/podman/podman.sock")
    .withCaching(true)
    .withCacheTtl(300)
    .build();
    
  auto client = new PodmanClient(config);
  // ... use client
  client.close();
}
```

## Building

```bash
dub build
```

## Testing

```bash
dub build --configuration=tests
dub test
```

## Server (REST API)

```bash
UIM_PODMAN_API_TOKEN=devtoken \
dub run :server --config=app
```

Optional CORS:

```bash
UIM_PODMAN_API_TOKEN=devtoken \
UIM_PODMAN_CORS_ORIGINS=http://localhost:5173 \
dub run :server --config=app
```

Curl example:

```bash
curl -H "Authorization: Bearer devtoken" \
  http://127.0.0.1:8080/api/v1/containers
```

Create container:

```bash
curl -X POST \
  -H "Authorization: Bearer devtoken" \
  -H "Content-Type: application/json" \
  -d '{"name":"demo","config":{"Image":"alpine:latest","Cmd":["sleep","60"]}}' \
  http://127.0.0.1:8080/api/v1/containers
```

Start container:

```bash
curl -X POST \
  -H "Authorization: Bearer devtoken" \
  http://127.0.0.1:8080/api/v1/containers/demo/start
```

## Dependencies

- `uim-framework` - Core UIM framework
- `vibe-d` (0.9.*) - Async HTTP and utilities
- `vibe-core` (1.28.*) - Core async library

## Usage

```d
import uim.podman;

void main() {
  auto config = defaultConfig();
  auto client = new PodmanClient(config);
  
  auto containers = client.listContainers();
  foreach(container; containers) {
    writeln(container.name);
  }
  
  client.close();
}
```

## Configuration Options

- `defaultConfig()` - User socket (rootless)
- `systemConfig()` - System socket
- `tcpConfig(host, port)` - TCP connection
- `secureTcpConfig(host, port, caPath)` - Secure TCP
- `sshConfig(user, host, port)` - SSH tunnel
- `devConfig()` - Development mode with logging
- `minimalConfig()` - Testing configuration
- `autoDetectConfig()` - Auto-detect from environment

## API Version

Default Podman API version: v4.0.0

Podman maintains API compatibility with Docker API, so many operations are compatible.

## Error Handling

Custom exception types for better error management:
- `PodmanNotFoundException`
- `PodmanConnectionException`
- `PodmanBadRequestException`
- `PodmanServerException`
- And more...

## Performance Features

- Response caching with configurable TTL
- Connection pooling
- Automatic retry with exponential backoff
- Verbose logging for debugging

## Resource Management

Always close clients:

```d
auto client = new PodmanClient(config);
try {
  // use client
} finally {
  client.close();
}
```

## Documentation

- [ENHANCEMENTS.md](ENHANCEMENTS.md) - Detailed enhancements
- [EXAMPLES.md](EXAMPLES.md) - Comprehensive examples

## Tested Versions

- Podman 4.0+
- Podman 5.0+

## License

Apache 2.0
