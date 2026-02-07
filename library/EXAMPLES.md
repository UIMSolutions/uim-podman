# Podman Library Examples

## Basic Container Operations

```d
import uim.podman.library;

void main() {
  // Create a client with default configuration (Unix socket)
  auto config = defaultConfig();
  auto client = new PodmanClient(config);
  
  // List all containers
  auto containers = client.listContainers(true);  // true = show all, including stopped
  foreach(container; containers) {
    writefln("Container: %s (ID: %s)", container.name, container.id);
  }
}
```

## Working with Images

```d
import uim.podman.library;

void main() {
  auto config = defaultConfig();
  auto client = new PodmanClient(config);
  
  // Pull an image
  client.pullImage("alpine", "latest");
  
  // List all images
  auto images = client.listImages();
  foreach(image; images) {
    writefln("Image: %s", image.repoTags[0]);
  }
}
```

## Creating and Running Containers

```d
import uim.podman.library;
import std.json : Json;

void main() {
  auto config = defaultConfig();
  auto client = new PodmanClient(config);
  
  // Create container config
  auto containerConfig = createContainerConfig(
    "alpine:latest",
    ["sleep", "3600"],
    ["LOG_LEVEL=debug"]
  );
  
  // Create container
  string containerId = client.createContainer("my-container", containerConfig);
  
  // Start container
  client.startContainer(containerId);
  
  // Get container info
  auto container = client.getContainer(containerId);
  writefln("Container %s is in state: %s", container.name, container.state);
  
  // Stop container
  client.stopContainer(containerId, 5);  // 5 seconds timeout
  
  // Remove container
  client.removeContainer(containerId, true);  // force=true
}
```

## Pod Operations

```d
import uim.podman.library;

void main() {
  auto config = defaultConfig();
  auto client = new PodmanClient(config);
  
  // Create a pod
  auto podConfig = createPodConfig("my-pod", ["8080:8080"]);
  string podId = client.createPod("my-pod", podConfig);
  
  // Start pod
  client.startPod(podId);
  
  // List pods
  auto pods = client.listPods();
  foreach(pod; pods) {
    writefln("Pod: %s (Containers: %d)", pod.name, pod.numContainers);
  }
  
  // Stop and remove pod
  client.stopPod(podId);
  client.removePod(podId);
}
```

## Volume Management

```d
import uim.podman.library;

void main() {
  auto config = defaultConfig();
  auto client = new PodmanClient(config);
  
  // Create a volume
  string volumeId = client.createVolume("my-data", "local");
  
  // List volumes
  auto volumes = client.listVolumes();
  foreach(volume; volumes) {
    writefln("Volume: %s at %s", volume.name, volume.mountPoint);
  }
  
  // Use volume with container
  auto mounts = createVolumeMounts(["my-data": "/data"]);
  
  // Remove volume
  client.removeVolume("my-data");
}
```

## Network Management

```d
import uim.podman.library;

void main() {
  auto config = defaultConfig();
  auto client = new PodmanClient(config);
  
  // Create a network
  string networkId = client.createNetwork("my-network", "bridge");
  
  // List networks
  auto networks = client.listNetworks();
  foreach(network; networks) {
    writefln("Network: %s (Driver: %s)", network.name, network.driver);
  }
  
  // Remove network
  client.removeNetwork("my-network");
}
```

## Container Logs

```d
import uim.podman.library;

void main() {
  auto config = defaultConfig();
  auto client = new PodmanClient(config);
  
  // Get container logs
  auto logs = client.getContainerLogs("my-container", true, true);
  writeln(logs.output);
}
```

## Advanced Container Configuration

```d
import uim.podman.library;
import std.json : Json;

void main() {
  auto config = defaultConfig();
  auto client = new PodmanClient(config);
  
  // Create environment variables
  auto env = createEnvironment([
    "APP_NAME": "myapp",
    "APP_PORT": "8080",
    "DEBUG": "true"
  ]);
  
  // Create resource limits
  auto limits = createResourceLimits(
    536_870_912,  // 512MB memory
    1_000_000_000,  // 1 CPU
    1024  // CPU shares
  );
  
  // Create health check
  auto healthCheck = createHealthCheck(
    ["CMD", "curl", "-f", "http://localhost:8080/health"],
    30,  // interval in seconds
    10,  // timeout in seconds
    3    // retries
  );
  
  writeln("Configuration created successfully");
}
```

## System-wide vs User Socket

```d
import uim.podman.library;

void main() {
  // Use system socket (requires root/sudo)
  auto systemConfig = systemConfig();
  
  // Use user socket (rootless mode)
  auto userConfig = defaultConfig();
  
  auto systemClient = new PodmanClient(systemConfig);
  auto userClient = new PodmanClient(userConfig);
}
```

## TCP Connection

```d
import uim.podman.library;

void main() {
  // For non-SSL connection
  auto tcpConfig = tcpConfig("192.168.1.100", 8080);
  
  // For SSL/TLS connection
  auto secureConfig = secureTcpConfig("192.168.1.100", 8081, "/path/to/ca.pem");
  
  auto client = new PodmanClient(secureConfig);
}
```
