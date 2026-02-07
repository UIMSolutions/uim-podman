/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop;

public {
    // Import UIM framework
    import uim.oop;
    
    // Import Podman library
    import uim.podman.library;
    
    // Import GTK
    import gtk.Main;
    import gtk.Widget;
    import gtk.Window;
    import gtk.ApplicationWindow;
    import gtk.Box;
    import gtk.Button;
    import gtk.Label;
    import gtk.Entry;
    import gtk.TreeView;
    import gtk.ListStore;
    import gtk.TreeIter;
    import gtk.CellRendererText;
    import gtk.TreeViewColumn;
    import gtk.ScrolledWindow;
    import gtk.Paned;
    import gtk.Notebook;
    import gtk.MessageDialog;
    import gtk.MenuBar;
    import gtk.Menu;
    import gtk.MenuItem;
    import gtk.Statusbar;
    import gtk.Toolbar;
    import gtk.ToolButton;
    import gtk.SeparatorToolItem;
    import gtk.Image;
    import gdk.Event;
    import glib.Timeout;
    import gio.Application : GioApplication = Application;
    import gio.c.types;;
}

public {
    // Desktop modules
    import uim.podman.desktop.windows;
    import uim.podman.desktop.views;
    import uim.podman.desktop.dialogs;
    import uim.podman.desktop.models;
    import uim.podman.desktop.controllers;
}
