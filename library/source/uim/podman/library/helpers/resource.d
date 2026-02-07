module uim.podman.library.helpers.resource;

import uim.podman.library;

mixin(ShowModule!());

@safe:

/// Creates resource limits for container.
Json createResourceLimits(long memoryBytes = 0, long cpuNanos = 0, long cpuShares = 1024) {
  Json limits = Json([
    "MemorySwap": Json(-1),
    "CpuShares": Json(cpuShares)
  ]);
  
  if (memoryBytes > 0) {
    limits["Memory"] = Json(memoryBytes);
  }
  
  if (cpuNanos > 0) {
    limits["CpuNano"] = Json(cpuNanos);
  }
  
  return limits;
}