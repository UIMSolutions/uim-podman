/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.models.pods;

import uim.podman.desktop;

/// Pod model for data management.
class PodModel {
    private PodmanClient client;
    private Pod[] items;

    this(PodmanClient client) {
        this.client = client;
    }

    void refresh() {
        try {
            items = client.listPods();
        } catch (Exception ex) {
            // Keep the last known state on error.
        }
    }

    Pod[] getItems() {
        return items;
    }
}
