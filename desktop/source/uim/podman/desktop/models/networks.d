/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.models.networks;

import uim.podman.desktop;

/// Network model for data management.
class NetworkModel {
    private PodmanClient client;
    private Network[] items;

    this(PodmanClient client) {
        this.client = client;
    }

    void refresh() {
        try {
            items = client.listNetworks();
        } catch (Exception ex) {
            // Keep the last known state on error.
        }
    }

    Network[] getItems() {
        return items;
    }
}
