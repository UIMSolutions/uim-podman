/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.controllers.volumes;

import uim.podman.desktop;

/// Controller for volume view + model.
class VolumeController {
    private VolumeModel model;
    private VolumeListView view;

    this(VolumeModel model, VolumeListView view) {
        this.model = model;
        this.view = view;
    }

    void refresh() {
        model.refresh();
        view.refresh();
    }
}
