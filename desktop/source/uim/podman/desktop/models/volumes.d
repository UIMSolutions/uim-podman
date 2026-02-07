/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.models.volumes;

import uim.podman.desktop;

/// Volume model for data management.
class VolumeModel {
    private PodmanClient client;
    private Volume[] items;

    this(PodmanClient client) {
        this.client = client;
    }

    void refresh() {
        try {
            items = client.listVolumes();
        } catch (Exception ex) {
            // Keep the last known state on error.
        }
    }

    Volume[] getItems() {
        return items;
    }
}
