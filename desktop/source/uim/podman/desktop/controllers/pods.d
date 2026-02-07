/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.controllers.pods;

import uim.podman.desktop;

/// Controller for pod view + model.
class PodController {
    private PodModel model;
    private PodListView view;

    this(PodModel model, PodListView view) {
        this.model = model;
        this.view = view;
    }

    void refresh() {
        model.refresh();
        view.refresh();
    }
}
