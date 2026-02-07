/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.models.images;

import uim.podman.desktop;

/// Image model for data management.
class ImageModel {
    private PodmanClient client;
    private uim.podman.Image[] items;

    this(PodmanClient client) {
        this.client = client;
    }

    void refresh() {
        try {
            items = client.listImages();
        } catch (Exception ex) {
            // Keep the last known state on error.
        }
    }

    uim.podman.Image[] getItems() {
        return items;
    }
}
