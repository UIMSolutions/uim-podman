module uim.podman.library.helpers.network;

import uim.podman.library;

mixin(ShowModule!());

@safe:
/** 
 * Creates a JSON object for network settings to be used in container creation or update.
 *
 * Params:
 *   networkName = The name of the network to connect the container to.
 *   ipAddress = (Optional) The static IP address to assign to the container within the network.
 *   gateway = (Optional) The gateway for the network (not currently used in this function).
 *
 * Returns:
 *   A Json object representing the network settings.
 */
Json createNetworkSettings(string networkName, string ipAddress = "", string gateway = "") {
  Json settings = Json([
    "EndpointsConfig": [
      networkName: [
        "IPAMConfig": Json(null)
      ].toJson
    ].toJson
  ]);

  if (ipAddress.length > 0) {
    settings["EndpointsConfig"][networkName]["IPAMConfig"] = [
      "IPv4Address": ipAddress
    ].toJson;
  }

  return settings;
}
///
unittest {
  mixin(ShowTest!"Testing createNetworkSettings");

  Json settings = createNetworkSettings("mynetwork", "192.168.1.100", "192.168.1.1");
  assert(
    settings["EndpointsConfig"]["mynetwork"]["IPAMConfig"]["IPv4Address"] == "192.168.1.100".toJson);
}
