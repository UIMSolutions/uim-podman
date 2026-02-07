module uim.podman.server.serialization;

import uim.podman.server;
@safe:;

Json containerToJson(PodmanContainer container) {
  Json obj = Json([
    "id": Json(container.id),
    "name": Json(container.name),
    "image": Json(container.image),
    "state": Json(container.state),
    "status": Json(container.status),
    "created": Json(container.created),
    "started": Json(container.started),
    "finished": Json(container.finished),
    "exitCode": Json(container.exitCode)
  ]);

  obj["ports"] = stringArrayToJSON(container.ports);
  obj["labels"] = stringMapToJSON(container.labels);

  return obj;
}

Json imageToJson(PodmanImage image) {
  Json obj = Json([
    "id": Json(image.id),
    "repoTags": stringArrayToJSON(image.repoTags),
    "created": Json(image.created),
    "size": Json(image.size),
    "virtualSize": Json(image.virtualSize)
  ]);

  obj["labels"] = stringMapToJSON(image.labels);

  return obj;
}

Json podToJson(Pod pod) {
  Json obj = Json([
    "id": Json(pod.id),
    "name": Json(pod.name),
    "status": Json(pod.status),
    "created": Json(pod.created),
    "started": Json(pod.started),
    "containers": Json(cast(long)pod.numberOfContainers)
  ]);

  obj["containerIds"] = stringArrayToJSON(pod.containerIds);
  obj["labels"] = stringMapToJSON(pod.labels);

  return obj;
}

Json volumeToJson(Volume volume) {
  Json obj = Json([
    "name": Json(volume.name),
    "driver": Json(volume.driver),
    "mountPoint": Json(volume.mountPoint)
  ]);

  if (!volume.options.isNull) {
    obj["options"] = volume.options;
  }

  obj["labels"] = stringMapToJSON(volume.labels);

  return obj;
}

Json networkToJson(Network network) {
  Json obj = Json([
    "id": Json(network.id),
    "name": Json(network.name),
    "driver": Json(network.driver),
    "scope": Json(network.scope_)
  ]);

  return obj;
}

Json listContainersToJson(PodmanContainer[] containers) {
  Json[] items;
  foreach (container; containers) {
    items ~= containerToJson(container);
  }
  return Json(items);
}

Json listImagesToJson(PodmanImage[] images) {
  Json[] items;
  foreach (image; images) {
    items ~= imageToJson(image);
  }
  return Json(items);
}

Json listPodsToJson(Pod[] pods) {
  Json[] items;
  foreach (pod; pods) {
    items ~= podToJson(pod);
  }
  return Json(items);
}

Json listVolumesToJson(Volume[] volumes) {
  Json[] items;
  foreach (volume; volumes) {
    items ~= volumeToJson(volume);
  }
  return Json(items);
}

Json listNetworksToJson(Network[] networks) {
  Json[] items;
  foreach (network; networks) {
    items ~= networkToJson(network);
  }
  return Json(items);
}
