/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.controllers.images;

import uim.podman.desktop;

/// Controller for image view + model.
class ImageController {
    private ImageModel model;
    private ImageListView view;

    this(ImageModel model, ImageListView view) {
        this.model = model;
        this.view = view;
    }

    void refresh() {
        model.refresh();
        view.refresh();
    }
}
