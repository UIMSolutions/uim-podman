/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module app;

import gtk.Application : Application, GtkApplication = Application;
import gtk.ApplicationWindow;
import gio.Application : GioApplication = Application;

import uim.podman.desktop;

void main(string[] args) {
    auto application = new PodmanDesktopApp();
    application.run(args);
}

/// Main GTK Application
class PodmanDesktopApp : Application {
    private MainWindow mainWindow;
    
    this() {
        super("de.uim.podman.desktop", GApplicationFlags.FLAGS_NONE);
        addOnActivate(&onActivate);
        initialize();;
    }

    void initialize() {
        uim.podman.desktop.windows.application = this;
    }
    
    private void onActivate(GioApplication app) {
        mainWindow = new MainWindow(this);
        mainWindow.showAll();
    }
}
