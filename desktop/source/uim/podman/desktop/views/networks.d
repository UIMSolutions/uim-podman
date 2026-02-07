/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.views.networks;

import uim.podman.desktop;
import gtk.TreeSelection;


alias NetworkSelectionHandler = void delegate(Network);

/// Network list view with tree view
class NetworkListView : ScrolledWindow {
    private PodmanClient client;
    private TreeView treeView;
    private ListStore listStore;
    private Network selectedNetwork;
    
    NetworkSelectionHandler onSelectionChanged;
    
    // Column indices
    enum {
        COL_NAME,
        COL_ID,
        COL_DRIVER,
        COL_SCOPE,
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
            GType.STRING,  // Driver
            GType.STRING   // Scope
        ]);
        
        // Create tree view
        treeView = new TreeView(listStore);
        treeView.setHeadersVisible(true);
        treeView.setEnableSearch(true);
        treeView.setSearchColumn(COL_NAME);
        
        // Add columns
        addColumn("Name", COL_NAME);
        addColumn("ID", COL_ID);
        addColumn("Driver", COL_DRIVER);
        addColumn("Scope", COL_SCOPE);
        
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
        TreeIter iter = selection.getSelected();
        if (iter !is null) {
            string name = listStore.getValueString(iter, COL_NAME);
            string id = listStore.getValueString(iter, COL_ID);
            string driver = listStore.getValueString(iter, COL_DRIVER);
            
            selectedNetwork = Network();
            selectedNetwork.name = name;
            selectedNetwork.id = id;
            selectedNetwork.driver = driver;
            
            if (onSelectionChanged !is null) {
                onSelectionChanged(selectedNetwork);
            }
        }
    }
    
    void refresh() {
        listStore.clear();
        
        try {
            auto networks = client.listNetworks();
            
            foreach (network; networks) {
                auto iter = listStore.createIter();
                listStore.setValue(iter, COL_NAME, network.name);
                listStore.setValue(iter, COL_ID, network.id.length > 12 ? network.id[0..12] : network.id);
                listStore.setValue(iter, COL_DRIVER, network.driver);
                listStore.setValue(iter, COL_SCOPE, network.scope_);
            }
        } catch (Exception ex) {
            // Handle error silently for now
        }
    }
    
    Network getSelected() {
        return selectedNetwork;
    }
}
