/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.views.images;

import uim.podman.desktop;
import std.datetime.systime : SysTime;
import std.string : lastIndexOf;

alias ImageSelectionHandler = void delegate(Image);

/// Image list view with tree view
class ImageListView : ScrolledWindow {
    private PodmanClient client;
    private TreeView treeView;
    private ListStore listStore;
    private Image selectedImage;
    
    ImageSelectionHandler onSelectionChanged;
    
    // Column indices
    enum {
        COL_REPOSITORY,
        COL_TAG,
        COL_ID,
        COL_SIZE,
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
            GType.STRING,  // Repository
            GType.STRING,  // Tag
            GType.STRING,  // ID
            GType.STRING,  // Size
            GType.STRING   // Created
        ]);
        
        // Create tree view
        treeView = new TreeView(listStore);
        treeView.setHeadersVisible(true);
        treeView.setEnableSearch(true);
        treeView.setSearchColumn(COL_REPOSITORY);
        
        // Add columns
        addColumn("Repository", COL_REPOSITORY);
        addColumn("Tag", COL_TAG);
        addColumn("ID", COL_ID);
        addColumn("Size", COL_SIZE);
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
            string repository = listStore.getValueString(iter, COL_REPOSITORY);
            string tag = listStore.getValueString(iter, COL_TAG);
            string imageId = listStore.getValueString(iter, COL_ID);
            
            // Store minimal image info
            selectedImage = Image();
            selectedImage.id = imageId;
            selectedImage.repoTags = [repository ~ ":" ~ tag];
            
            if (onSelectionChanged !is null) {
                onSelectionChanged(selectedImage);
            }
        }
    }
    
    void refresh() {
        listStore.clear();
        
        try {
            auto images = client.listImages();
            
            foreach (image; images) {
                // Handle multiple repo tags
                if (image.repoTags.length > 0) {
                    foreach (repoTag; image.repoTags) {
                        auto iter = listStore.createIter();
                        string repo = repoTag;
                        string tag = "latest";
                        
                        // Split repository:tag
                        auto colonIdx = repoTag.lastIndexOf(':');
                        if (colonIdx > 0) {
                            repo = repoTag[0..colonIdx];
                            tag = repoTag[colonIdx+1..$];
                        }
                        
                        listStore.setValue(iter, COL_REPOSITORY, repo);
                        listStore.setValue(iter, COL_TAG, tag);
                        listStore.setValue(iter, COL_ID, image.id.length > 12 ? image.id[0..12] : image.id);
                        listStore.setValue(iter, COL_SIZE, formatSize(image.size));
                        
                        auto createdTime = SysTime.fromUnixTime(image.created);
                        listStore.setValue(iter, COL_CREATED, createdTime.toISOExtString());
                    }
                } else {
                    // Image with no tags
                    auto iter = listStore.createIter();
                    listStore.setValue(iter, COL_REPOSITORY, "<none>");
                    listStore.setValue(iter, COL_TAG, "<none>");
                    listStore.setValue(iter, COL_ID, image.id.length > 12 ? image.id[0..12] : image.id);
                    listStore.setValue(iter, COL_SIZE, formatSize(image.size));
                    
                    auto createdTime = SysTime.fromUnixTime(image.created);
                    listStore.setValue(iter, COL_CREATED, createdTime.toISOExtString());
                }
            }
        } catch (Exception ex) {
            // Handle error silently for now
        }
    }
    
    Image getSelected() {
        return selectedImage;
    }
    
    private string formatSize(long size) {
        import std.format : format;
        
        if (size < 1024) return format("%d B", size);
        if (size < 1024 * 1024) return format("%.1f KB", size / 1024.0);
        if (size < 1024 * 1024 * 1024) return format("%.1f MB", size / (1024.0 * 1024));
        return format("%.1f GB", size / (1024.0 * 1024 * 1024));
    }
}
