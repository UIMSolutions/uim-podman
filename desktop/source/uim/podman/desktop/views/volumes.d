/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.views.volumes;

import uim.podman.desktop;
import std.algorithm : joiner;
import std.conv : to;
import gtk.TreeSelection;


alias VolumeSelectionHandler = void delegate(Volume);

/// Volume list view with tree view
class VolumeListView : ScrolledWindow {
    private PodmanClient client;
    private TreeView treeView;
    private ListStore listStore;
    private Volume selectedVolume;
    
    VolumeSelectionHandler onSelectionChanged;
    
    // Column indices
    enum {
        COL_NAME,
        COL_DRIVER,
        COL_MOUNTPOINT,
        COL_OPTIONS,
        NUM_COLS
    }
    
    this(PodmanClient client) {
        super();
        this.client = client;
        
        setupTreeView();
        refresh();
    }
    
    private void setupTreeView() {
        // Create list store
        listStore = new ListStore([
            GType.STRING,  // Name
            GType.STRING,  // Driver
            GType.STRING,  // Mountpoint
            GType.STRING   // Options
        ]);
        
        // Create tree view
        treeView = new TreeView(listStore);
        treeView.setHeadersVisible(true);
        treeView.setEnableSearch(true);
        treeView.setSearchColumn(COL_NAME);
        
        // Add columns
        addColumn("Name", COL_NAME);
        addColumn("Driver", COL_DRIVER);
        addColumn("Mountpoint", COL_MOUNTPOINT);
        addColumn("Options", COL_OPTIONS);
        
        // Selection handler
        auto selection = treeView.getSelection();
        selection.addOnChanged(&onTreeSelectionChanged);
        
        add(treeView);
    }
    
    private void addColumn(string title, int colNum) {
        auto renderer = new CellRendererText();
        auto column = new TreeViewColumn(title, renderer, "text", colNum);
        column.setResizable(true);
        column.setSortColumnId(colNum);
        treeView.appendColumn(column);
    }
    
    private void onTreeSelectionChanged(TreeSelection selection) {
        TreeIter iter;
        if (selection.getSelected(iter)) {
            string name = listStore.getValueString(iter, COL_NAME);
            string driver = listStore.getValueString(iter, COL_DRIVER);
            string mountpoint = listStore.getValueString(iter, COL_MOUNTPOINT);
            
            selectedVolume = Volume();
            selectedVolume.name = name;
            selectedVolume.driver = driver;
            selectedVolume.mountPoint = mountpoint;
            
            if (onSelectionChanged !is null) {
                onSelectionChanged(selectedVolume);
            }
        }
    }
    
    void refresh() {
        listStore.clear();
        
        try {
            auto volumes = client.listVolumes();
            
            foreach (volume; volumes) {
                auto iter = listStore.createIter();
                listStore.setValue(iter, COL_NAME, volume.name);
                listStore.setValue(iter, COL_DRIVER, volume.driver);
                listStore.setValue(iter, COL_MOUNTPOINT, volume.mountPoint);
                listStore.setValue(iter, COL_OPTIONS, formatOptions(volume.options));
            }
        } catch (Exception ex) {
            // Handle error silently for now
        }
    }
    
    Volume getSelected() {
        return selectedVolume;
    }
    
    private string formatOptions(Json options) {
        if (options.isNull) return "";
        if (options.isObject) {
            string[] parts;
            foreach (key, value; options.toMap) {
                parts ~= key ~ "=" ~ value.toString;
            }
            return parts.length > 0 ? parts.joiner(", ").to!string : "";
        }
        return options.toString;
    }
}
