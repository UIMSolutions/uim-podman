/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.models.containers;

import uim.podman.desktop;

/// Container model for data management.
class ContainerModel {
    private PodmanClient client;
    private Container[] items;

    this(PodmanClient client) {
        this.client = client;
    }

    void refresh(bool all = true) {
        try {
            items = client.listContainers(all);
        } catch (Exception ex) {
            // Keep the last known state on error.
        }
    }

    Container[] getItems() {
        return items;
    }
}
