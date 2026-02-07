/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.windows.main;

import uim.podman.desktop;
import gtk.Application;
import gtk.Toolbar;
import gtk.ToolItem;
import gtk.CheckButton;
import gtk.Statusbar;
import gtk.Label;
import gtk.Separator;

/// Main application window
class MainWindow : ApplicationWindow {
    private PodmanClient client;
    private ContainersView containersView;
    private ImagesView imagesView;
    private PodsView podsView;
    private VolumesView volumesView;
    private NetworksView networksView;

    private Notebook notebook;
    private Statusbar statusbar;
    private Toolbar toolbar;

    private uint contextId;
    private Timeout refreshTimeout;

    this(Application app) {
        super(app);

        setTitle("UIM Podman Desktop Manager");
        setDefaultSize(1200, 800);

        // Initialize Podman client
        try {
            auto config = autoDetectConfig();
            client = new PodmanClient(config);
            // statusbar.push(contextId, "Connected to Podman daemon");
        } catch (Exception ex) {
            // statusbar.push(contextId, "Failed to connect: " ~ ex.msg);
        }

        setupUI();
        setupAutoRefresh();

        addOnDelete(&onDelete);
    }

    private void setupUI() {
        auto mainBox = new Box(Orientation.VERTICAL, 0);

        // Menu bar
        auto menuBar = createMenuBar();
        mainBox.packStart(menuBar, false, false, 0);

        // Toolbar
        toolbar = createToolbar();
        mainBox.packStart(toolbar, false, false, 0);

        // Notebook with tabs
        notebook = new Notebook();

        // Container tab
        containersView = new ContainersView(client);
        containersView.onSelectionChanged = &onContainerSelected;
        notebook.appendPage(containersView, new Label("Containers"));

        // Images tab
        imagesView = new ImagesView(client);
        notebook.appendPage(imagesView, new Label("Images"));

        // Pods tab
        podsView = new PodsView(client);
        notebook.appendPage(podsView, new Label("Pods"));

        // Volumes tab
        volumesView = new VolumesView(client);
        notebook.appendPage(volumesView, new Label("Volumes"));

        // Networks tab
        networksView = new NetworksView(client);
        notebook.appendPage(networksView, new Label("Networks"));

        mainBox.packStart(notebook, true, true, 0);

        // Status bar
        statusbar = new Statusbar();
        contextId = statusbar.getContextId("main");

        // Bereich 2: Ein Label für die Zeilennummer (rechts)
        auto lineLabel = new Label("Zeile: 1, Spalte: 1");
        statusbar.packEnd(lineLabel, false, false, 5);

        // Bereich 3: Trenner
        auto sep = new Separator(Orientation.VERTICAL);
        statusbar.packEnd(sep, false, false, 5);

        // Bereich 4: Status-Indikator
        auto modeLabel = new Label("INS");
        statusbar.packEnd(modeLabel, false, false, 5);

        mainBox.packStart(statusbar, false, false, 0);

        add(mainBox);
    } // 

    private MenuBar createMenuBar() {
        auto menuBar = new MenuBar();

        // File menu
        auto fileMenu = new Menu();
        auto fileMenuItem = new MenuItem("_File");
        fileMenuItem.setSubmenu(fileMenu);

        auto refreshItem = new MenuItem("_Refresh");
        refreshItem.addOnActivate((MenuItem mi) { refreshAll(); });
        fileMenu.append(refreshItem);

        fileMenu.append(new MenuItem()); // Separator

        auto quitItem = new MenuItem("_Quit");
        quitItem.addOnActivate((MenuItem mi) { getApplication().quit(); });
        fileMenu.append(quitItem);

        menuBar.append(fileMenuItem);

        // Containers menu
        auto containersMenu = new Menu();
        auto containersMenuItem = new MenuItem("_Containers");
        containersMenuItem.setSubmenu(containersMenu);

        auto newContainerItem = new MenuItem("_New Container...");
        newContainerItem.addOnActivate((MenuItem mi) { showNewContainerDialog(); });
        containersMenu.append(newContainerItem);

        auto startItem = new MenuItem("_Start");
        startItem.addOnActivate((MenuItem mi) { startSelectedContainer(); });
        containersMenu.append(startItem);

        auto stopItem = new MenuItem("Sto_p");
        stopItem.addOnActivate((MenuItem mi) { stopSelectedContainer(); });
        containersMenu.append(stopItem);

        auto removeItem = new MenuItem("_Remove");
        removeItem.addOnActivate((MenuItem mi) { removeSelectedContainer(); });
        containersMenu.append(removeItem);

        menuBar.append(containersMenuItem);

        // Help menu
        auto helpMenu = new Menu();
        auto helpMenuItem = new MenuItem("_Help");
        helpMenuItem.setSubmenu(helpMenu);

        auto aboutItem = new MenuItem("_About");
        aboutItem.addOnActivate((MenuItem mi) { showAboutDialog(); });
        helpMenu.append(aboutItem);

        menuBar.append(helpMenuItem);

        return menuBar;
    }

    private Toolbar createToolbar() {
        auto toolbar = new Toolbar();

        // Refresh button
        auto refreshBtn = new ToolButton("view-refresh");
        refreshBtn.setTooltipText("Refresh All");
        refreshBtn.setIsImportant(true);
        refreshBtn.setUseUnderline(true);
        refreshBtn.setLabel("_Refresh All");
        refreshBtn.setIconName("view-refresh");
        refreshBtn.addOnClicked((ToolButton tb) { refreshAll(); });
        toolbar.insert(refreshBtn, -1);

        auto toolItem = new ToolItem();
        auto check = new CheckButton("Option aktivieren");
        toolItem.add(check);
        toolbar.insert(toolItem, -1);

        toolbar.insert(new SeparatorToolItem(), -1);

        // Start button
        auto startBtn = new ToolButton("media-playback-start");
        startBtn.setTooltipText("Start Container");
        startBtn.addOnClicked((ToolButton tb) { startSelectedContainer(); });
        toolbar.insert(startBtn, -1);

        // Stop button
        auto stopBtn = new ToolButton("media-playback-stop");
        stopBtn.setTooltipText("Stop Container");
        stopBtn.addOnClicked((ToolButton tb) { stopSelectedContainer(); });
        toolbar.insert(stopBtn, -1);

        // Pause button
        auto pauseBtn = new ToolButton("media-playback-pause");
        pauseBtn.setTooltipText("Pause Container");
        pauseBtn.addOnClicked((ToolButton tb) { pauseSelectedContainer(); });
        toolbar.insert(pauseBtn, -1);

        toolbar.insert(new SeparatorToolItem(), -1);

        // Remove button
        auto removeBtn = new ToolButton("edit-delete");
        removeBtn.setTooltipText("Remove Container");
        removeBtn.addOnClicked((ToolButton tb) { removeSelectedContainer(); });
        toolbar.insert(removeBtn, -1);

        return toolbar;
    }

    private void setupAutoRefresh() {
        // Refresh every 5 seconds
        refreshTimeout = new Timeout(5000, &autoRefresh, false);
    }

    private bool autoRefresh() {
        refreshAll();
        return true; // Continue refreshing
    }

    private void refreshAll() {
        try {
            final switch (notebook.getCurrentPage()) {
            case 0:
                containersView.refresh();
                break;
            case 1:
                imagesView.refresh();
                break;
            case 2:
                podsView.refresh();
                break;
            case 3:
                volumesView.refresh();
                break;
            case 4:
                networksView.refresh();
                break;
            }
            statusbar.push(contextId, "Refreshed");
        } catch (Exception ex) {
            statusbar.push(contextId, "Error: " ~ ex.msg);
        }
    }

    private void onContainerSelected(uim.podman.library.PodmanContainer container) {
        statusbar.push(contextId, "Selected: " ~ container.name);
    }

    private void startSelectedContainer() {
        auto container = containersView.getSelected();
        if (container.id.empty)
            return;

        try {
            client.startContainer(container.id);
            statusbar.push(contextId, "Started container: " ~ container.name);
            refreshAll();
        } catch (Exception ex) {
            showError("Failed to start container", ex.msg);
        }
    }

    private void stopSelectedContainer() {
        auto container = containersView.getSelected();
        if (container.id.empty)
            return;

        try {
            client.stopContainer(container.id);
            statusbar.push(contextId, "Stopped container: " ~ container.name);
            refreshAll();
        } catch (Exception ex) {
            showError("Failed to stop container", ex.msg);
        }
    }

    private void pauseSelectedContainer() {
        auto container = containersView.getSelected();
        if (container.id.empty)
            return;

        try {
            client.pauseContainer(container.id);
            statusbar.push(contextId, "Paused container: " ~ container.name);
            refreshAll();
        } catch (Exception ex) {
            showError("Failed to pause container", ex.msg);
        }
    }

    private void removeSelectedContainer() {
        auto container = containersView.getSelected();
        if (container.id.empty)
            return;

        auto dialog = new MessageDialog(
            this,
            GtkDialogFlags.MODAL,
            GtkMessageType.QUESTION,
            GtkButtonsType.YES_NO,
            "Remove container '" ~ container.name ~ "'?"
        );

        auto response = dialog.run();
        dialog.destroy();

        if (response == GtkResponseType.YES) {
            try {
                client.removeContainer(container.id, true);
                statusbar.push(contextId, "Removed container: " ~ container.name);
                refreshAll();
            } catch (Exception ex) {
                showError("Failed to remove container", ex.msg);
            }
        }
    }

    private void showNewContainerDialog() {
        auto dialog = new ContainerDialog(this, client);
        auto response = dialog.run();

        if (response == GtkResponseType.OK) {
            refreshAll();
        }

        dialog.destroy();
    }

    private void showAboutDialog() {
        auto dialog = new MessageDialog(
            this,
            GtkDialogFlags.MODAL,
            GtkMessageType.INFO,
            GtkButtonsType.OK,
            "Podman Desktop Manager\n\nA GTK application for managing Podman containers based on D Language\n\n© 2026 Ozan Nurettin Süel"
        );
        dialog.run();
        dialog.destroy();
    }

    private void showError(string title, string message) {
        auto dialog = new MessageDialog(
            this,
            GtkDialogFlags.MODAL,
            GtkMessageType.ERROR,
            GtkButtonsType.OK,
            title ~ "\n\n" ~ message
        );
        dialog.run();
        dialog.destroy();
    }

    private bool onDelete(Event event, Widget widget) {
        if (client !is null && !client.isClosed()) {
            client.close();
        }
        return false;
    }
}
