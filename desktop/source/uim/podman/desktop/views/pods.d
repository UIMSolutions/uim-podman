/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.views.pods;

import uim.podman.desktop;
import std.datetime.systime : SysTime;

alias PodSelectionHandler = void delegate(Pod);

/// Pod list view with tree view
class PodListView : ScrolledWindow {
    private PodmanClient client;
    private TreeView treeView;
    private ListStore listStore;
    private Pod selectedPod;
    
    PodSelectionHandler onSelectionChanged;
    
    // Column indices
    enum {
        COL_NAME,
        COL_ID,
        COL_STATUS,
        COL_CONTAINERS,
        COL_CREATED,
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
            GType.STRING,  // Status
            GType.STRING,  // Containers
            GType.STRING   // Created
        ]);
        
        // Create tree view
        treeView = new TreeView(listStore);
        treeView.setHeadersVisible(true);
        treeView.setEnableSearch(true);
        treeView.setSearchColumn(COL_NAME);
        
        // Add columns
        addColumn("Name", COL_NAME);
        addColumn("ID", COL_ID);
        addColumn("Status", COL_STATUS);
        addColumn("Containers", COL_CONTAINERS);
        addColumn("Created", COL_CREATED);
        
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
            string status = listStore.getValueString(iter, COL_STATUS);
            
            selectedPod = Pod();
            selectedPod.name = name;
            selectedPod.id = id;
            selectedPod.status = status;
            
            if (onSelectionChanged !is null) {
                onSelectionChanged(selectedPod);
            }
        }
    }
    
    void refresh() {
        listStore.clear();
        
        try {
            auto pods = client.listPods();
            
            foreach (pod; pods) {
                auto iter = listStore.createIter();
                listStore.setValue(iter, COL_NAME, pod.name);
                listStore.setValue(iter, COL_ID, pod.id.length > 12 ? pod.id[0..12] : pod.id);
                listStore.setValue(iter, COL_STATUS, pod.status);
                listStore.setValue(iter, COL_CONTAINERS, formatContainerCount(pod.numberOfContainers));
                
                auto createdTime = SysTime.fromUnixTime(pod.created);
                listStore.setValue(iter, COL_CREATED, createdTime.toISOExtString());
            }
        } catch (Exception ex) {
            // Handle error silently for now
        }
    }
    
    Pod getSelected() {
        return selectedPod;
    }
    
    private string formatContainerCount(size_t count) {
        import std.format : format;
        return format("%d", count);
    }
}
