/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.controllers.containers;

import uim.podman.desktop;

/// Controller for container view + model.
class ContainerController {
    private ContainerModel model;
    private ContainerListView view;

    this(ContainerModel model, ContainerListView view) {
        this.model = model;
        this.view = view;
    }

    void refresh() {
        model.refresh(true);
        view.refresh();
    }
}
