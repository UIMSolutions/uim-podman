/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.library.helpers.cache;

import uim.podman.library;
import core.time;

mixin(ShowModule!());

@safe:

/// Cache entry with timestamp
struct CacheEntry {
  Json data;
  long timestamp;
  uint ttlSeconds;

  /// Check if cache entry is still valid
  bool isValid(uint currentTime) const {
    return (currentTime - timestamp) < ttlSeconds;
  }

  /// Get age of cache entry in seconds
  uint getAge(uint currentTime) const {
    return cast(uint)(currentTime - timestamp);
  }
}

/// Simple in-memory cache for API responses
class ResponseCache {
  private CacheEntry[string] cache;
  private uint maxSize = 1000;
  private bool enabled = true;

  this(uint maxSize = 1000, bool enabled = true) {
    this.maxSize = maxSize;
    this.enabled = enabled;
  }

  /// Get value from cache
  Json get(string key) {
    if (!enabled || key !in cache) {
      return Json();
    }

    auto entry = cache[key];
    if (!entry.isValid(getCurrentTime())) {
      cache.remove(key);
      return Json();
    }

    return entry.data;
  }

  /// Check if key exists in cache and is valid
  bool has(string key) {
    if (!enabled || key !in cache) {
      return false;
    }

    auto entry = cache[key];
    if (!entry.isValid(getCurrentTime())) {
      cache.remove(key);
      return false;
    }

    return true;
  }

  /// Set value in cache
  void set(string key, Json data, uint ttlSeconds) {
    if (!enabled) return;

    // Evict oldest entry if cache is full
    if (cache.length >= maxSize) {
      evictOldest();
    }

    cache[key] = CacheEntry(data, getCurrentTime(), ttlSeconds);
  }

  /// Clear specific cache entry
  void invalidate(string key) {
    cache.remove(key);
  }

  /// Clear all cache entries
  void clear() {
    cache.clear();
  }

  /// Get cache statistics
  CacheStats getStats() const {
    return CacheStats(cache.length, maxSize, enabled);
  }

  /// Enable/disable cache
  void setEnabled(bool value) {
    enabled = value;
    if (!value) {
      cache.clear();
    }
  }

private:
  /// Evict oldest entry from cache
  void evictOldest() {
    uint currentTime = getCurrentTime();
    string oldestKey = "";
    uint oldestAge = 0;

    foreach (key, entry; cache) {
      uint age = entry.getAge(currentTime);
      if (age > oldestAge) {
        oldestAge = age;
        oldestKey = key;
      }
    }

    if (!oldestKey.empty) {
      cache.remove(oldestKey);
    }
  }

  /// Get current time in seconds
  uint getCurrentTime() const {
    // Would use core.time in real implementation
    // For now, return a placeholder
    return 0;
  }
}

/// Cache statistics
struct CacheStats {
  size_t size;
  size_t maxSize;
  bool enabled;

  double hitRate() const {
    return (cast(double)size / cast(double)maxSize) * 100.0;
  }

  string toString() const {
    return format("CacheStats(size=%d, maxSize=%d, enabled=%s, usage=%.1f%%)", 
      size, maxSize, enabled ? "true" : "false", hitRate());
  }
}

/// Create a new response cache
ResponseCache createCache(uint maxSize = 1000, bool enabled = true) {
  return new ResponseCache(maxSize, enabled);
}
