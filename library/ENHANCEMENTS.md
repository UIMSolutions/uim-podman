# UIM Podman Library - Enhancements & New Features

This document describes the optimizations and enhancements made to the uim-podman library.

## Overview

The enhanced uim-podman library now provides:

- **Fluent Configuration Builder**: Easy configuration using builder pattern
- **Async HTTP Client**: Integration with vibe.d for async operations
- **Advanced Error Handling**: Custom exception types for better error management
- **Response Caching**: Automatic in-memory caching for performance
- **Connection Pooling**: Efficient connection management
- **Fluent API**: Builders for containers and pods with method chaining
- **Comprehensive Interfaces**: Better extensibility and testability
- **Resource Management**: Proper lifecycle management

## New Components

### 1. Enhanced Configuration (`structs/config.d`)

**Builder Pattern Support:**
```d
auto config = PodmanConfig.builder()
  .withEndpoint("unix:///run/podman/podman.sock")
  .withConnectionTimeout(30)
  .withCaching(true)
  .withCacheTtl(300)
  .build();
```

**Features:**
- Connection timeout configuration
- Request timeout configuration
- Retry configuration with exponential backoff
- Connection pool size configuration
- Response caching settings
- Verbose logging support

**Validation:**
- Configuration is validated on build
- Ensures all required fields are set correctly

### 2. Async HTTP Client (`helpers/http.d`)

**Features:**
- Built on vibe.d for async operations
- Support for GET, POST, PUT, DELETE methods
- Automatic retry logic with exponential backoff
- Comprehensive error handling
- Request/response logging in debug mode
- Header management

**Usage:**
```d
auto httpClient = new PodmanHttpClient(config);
auto response = httpClient.get("/v4.0.0/containers/json");
```

### 3. Response Caching (`helpers/cache.d`)

**Features:**
- In-memory response caching
- TTL-based cache invalidation
- Cache statistics
- LRU eviction policy
- Cache control (enable/disable)

**Configuration:**
```d
auto config = PodmanConfig.builder()
  .withCaching(true)
  .withCacheTtl(300)  // 5 minutes
  .build();
```

**Cache Statistics:**
```d
auto stats = client.getCacheStats();
writeln("Cache usage: ", stats.hitRate(), "%");
```

### 4. Advanced Error Handling (`exceptions/api.d`)

**Exception Types:**
- `PodmanException` - Base exception
- `PodmanConnectionException` - Connection failures
- `PodmanBadRequestException` - HTTP 400 errors
- `PodmanNotFoundException` - HTTP 404 errors
- `PodmanServerException` - HTTP 5xx errors
- `PodmanTimeoutException` - Timeout errors
- `PodmanConfigException` - Configuration errors
- `PodmanAuthException` - Authentication errors

**Usage:**
```d
try {
  auto container = client.getContainer("non-existent");
} catch (PodmanNotFoundException ex) {
  writeln("Container not found: ", ex.msg);
}
```

### 5. Fluent Builders (`helpers/builders.d`)

**Container Builder:**
```d
auto config = containerBuilder()
  .withName("my-app")
  .withImage("ubuntu:latest")
  .withEnv(["NODE_ENV": "production"])
  .withWorkDir("/app")
  .withCommand(["npm", "start"])
  .exposePort(3000)
  .mountVolume("/host/path", "/container/path")
  .withMemoryLimit(512 * 1024 * 1024)
  .withCpuLimit(1.0)
  .withLabel("env", "production")
  .build();

auto containerId = client.createContainer("my-app", config);
```

**Pod Builder:**
```d
auto config = podBuilder()
  .withName("my-pod")
  .withInfraImage("k8s.gcr.io/pause:3.5")
  .publishPort(8080, 8080)
  .build();

auto podId = client.createPod("my-pod", config);
```

### 6. Enhanced Interfaces (`interfaces/client.d`)

**IPodmanClient Interface:**
- Defines all container, image, pod, volume, and network operations
- Enables mocking and testing
- Allows alternative implementations

**IHttpClient Interface:**
- Abstraction for HTTP operations
- Enables swapping HTTP implementations

**ICache Interface:**
- Abstraction for caching layer
- Enables alternative cache implementations

### 7. Enhanced Configuration Helpers (`helpers/config.d`)

**Convenience Functions:**
- `defaultConfig()` - User socket configuration
- `systemConfig()` - System-wide socket configuration
- `tcpConfig(host, port)` - TCP configuration
- `secureTcpConfig(host, port, caPath)` - Secure TCP with TLS
- `sshConfig(username, host, port)` - SSH remote connection
- `devConfig()` - Development with verbose logging
- `minimalConfig()` - Testing configuration
- `autoDetectConfig()` - Auto-detect from environment

### 8. Enhanced PodmanClient (`classes/client.d`)

**Improvements:**
- Implements `IPodmanClient` interface
- Automatic cache invalidation on mutations
- Comprehensive input validation
- Better error messages
- Resource lifecycle management
- Cache statistics API

**Resource Management:**
```d
auto client = new PodmanClient(config);
try {
  // Use client
} finally {
  client.close();  // Cleanup
}
```

## Migration Guide

### Old Style → New Style

**Old Configuration:**
```d
auto config = PodmanConfig("unix:///run/podman/podman.sock", "v4.0.0", false, "", true);
```

**New Configuration:**
```d
auto config = PodmanConfig.builder()
  .withEndpoint("unix:///run/podman/podman.sock")
  .withApiVersion("v4.0.0")
  .build();

// Or use convenience function
auto config = defaultConfig();
```

**Old Container Creation:**
```d
auto containerConfig = Json([...]);
auto containerId = client.createContainer("my-container", containerConfig);
```

**New Container Creation with Fluent API:**
```d
auto config = containerBuilder()
  .withName("my-container")
  .withImage("ubuntu:latest")
  .withEnv(["KEY": "value"])
  .build();
auto containerId = client.createContainer("my-container", config);
```

## Performance Improvements

1. **Response Caching**: Reduces API calls for read operations
2. **Connection Pooling**: Reuses connections for better throughput
3. **Retry Logic**: Handles transient failures automatically
4. **Async Support**: Built on vibe.d for non-blocking operations

## Dependencies

Added:
- `vibe-d` 0.9.* - Async HTTP and core utilities
- `vibe-core` 1.28.* - Vibe core library

## Testing

```bash
# Build with tests
dub build --configuration=tests

# Run tests
dub test
```

## Backward Compatibility

The library maintains backward compatibility with existing code while providing new features through optional enhancements.

## Future Enhancements

Potential future improvements:
- WebSocket support for container events
- Streaming logs support
- Container stats monitoring
- Image build support
- Compose file support
- Better async/await support with fibers
- Rate limiting support
- Metrics collection

## API Reference

See the comprehensive examples in `EXAMPLES.md` for detailed usage patterns.

## Contributing

When adding new features:
1. Use the builder pattern for configuration
2. Implement proper error handling with custom exceptions
3. Add cache invalidation for mutations
4. Include input validation
5. Add interface definitions for extensibility
6. Update documentation

## License

Apache 2.0
