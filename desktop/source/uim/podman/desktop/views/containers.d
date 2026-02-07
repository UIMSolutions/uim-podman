/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.views.containers;

import uim.podman.desktop;
import std.algorithm : joiner;
import std.conv : to;

alias SelectionHandler = void delegate(Container);

/// Container list view with tree view
class ContainerListView : ScrolledWindow {
    private PodmanClient client;
    private TreeView treeView;
    private ListStore listStore;
    private Container selectedContainer;
    
    SelectionHandler onSelectionChanged;
    
    // Column indices
    enum {
        COL_NAME,
        COL_ID,
        COL_IMAGE,
        COL_STATUS,
        COL_STATE,
        COL_PORTS,
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
            GType.STRING,  // ID
            GType.STRING,  // Image
            GType.STRING,  // Status
            GType.STRING,  // State
            GType.STRING   // Ports
        ]);
        
        // Create tree view
        treeView = new TreeView(listStore);
        treeView.setHeadersVisible(true);
        treeView.setEnableSearch(true);
        treeView.setSearchColumn(COL_NAME);
        
        // Add columns
        addColumn("Name", COL_NAME);
        addColumn("ID", COL_ID);
        addColumn("Image", COL_IMAGE);
        addColumn("Status", COL_STATUS);
        addColumn("State", COL_STATE);
        addColumn("Ports", COL_PORTS);
        
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
            string id = listStore.getValueString(iter, COL_ID);
            string image = listStore.getValueString(iter, COL_IMAGE);
            string status = listStore.getValueString(iter, COL_STATUS);
            string state = listStore.getValueString(iter, COL_STATE);
            
            // Create a minimal Container struct with the displayed data
            selectedContainer = Container();
            selectedContainer.name = name;
            selectedContainer.id = id;
            selectedContainer.image = image;
            selectedContainer.status = status;
            selectedContainer.state = state;
            
            if (onSelectionChanged !is null) {
                onSelectionChanged(selectedContainer);
            }
        }
    }
    
    void refresh() {
        listStore.clear();
        
        try {
            auto containers = client.listContainers(true);
            
            foreach (container; containers) {
                auto iter = listStore.createIter();
                listStore.setValue(iter, COL_NAME, container.name);
                listStore.setValue(iter, COL_ID, container.id.length > 12 ? container.id[0..12] : container.id);
                listStore.setValue(iter, COL_IMAGE, container.image);
                listStore.setValue(iter, COL_STATUS, container.status);
                listStore.setValue(iter, COL_STATE, container.state);
                listStore.setValue(iter, COL_PORTS, formatPorts(container.ports));
            }
        } catch (Exception ex) {
            // Handle error silently for now
        }
    }
    
    Container getSelected() {
        return selectedContainer;
    }
    
    private string formatPorts(string[] ports) {
        if (ports.length == 0) return "";
        return ports.joiner(", ").to!string;
    }
}
