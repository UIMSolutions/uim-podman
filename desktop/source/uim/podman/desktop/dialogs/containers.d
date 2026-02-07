/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.desktop.dialogs.containers;

import uim.podman.desktop;
import std.string : indexOf, replace, split, strip;
import gtk.Box;
import gtk.CheckButton;
import gtk.Dialog;
import gtk.c.types;
import gtk.Entry;
import gtk.Label;
import gtk.MessageDialog;
import gtk.Window;

/// Dialog for creating a new container.
class ContainerDialog {
    private PodmanClient client;
    private Dialog dialog;
    private Entry nameEntry;
    private Entry imageEntry;
    private Entry commandEntry;
    private Entry envEntry;
    private Entry workDirEntry;
    private CheckButton startCheck;

    this(Window parent, PodmanClient client) {
        this.client = client;
        dialog = new Dialog();
        dialog.setTitle("New Container");
        dialog.setTransientFor(parent);
        dialog.setModal(true);
        dialog.addButton("_Cancel", GtkResponseType.CANCEL);
        dialog.addButton("_Create", GtkResponseType.OK);
        dialog.setDefaultResponse(GtkResponseType.OK);

        auto content = dialog.getContentArea();
        auto form = new Box(GtkOrientation.VERTICAL, 8);
        content.packStart(form, true, true, 0);

        nameEntry = addEntryRow(form, "Name");
        imageEntry = addEntryRow(form, "Image");
        commandEntry = addEntryRow(form, "Command");
        envEntry = addEntryRow(form, "Environment (KEY=VALUE, comma or newline)");
        workDirEntry = addEntryRow(form, "Working Directory");

        startCheck = new CheckButton("Start after create");
        form.packStart(startCheck, false, false, 0);

        dialog.showAll();
    }

    int run() {
        while (true) {
            auto response = dialog.run();
            if (response != GtkResponseType.OK) {
                return response;
            }

            if (createContainer()) {
                return response;
            }
        }
    }

    void destroy() {
        dialog.destroy();
    }

    private Entry addEntryRow(Box parent, string labelText) {
        auto row = new Box(GtkOrientation.HORIZONTAL, 8);
        auto label = new Label(labelText);
        label.setXalign(0);
        auto entry = new Entry();
        row.packStart(label, false, false, 0);
        row.packStart(entry, true, true, 0);
        parent.packStart(row, false, false, 0);
        return entry;
    }

    private bool createContainer() {
        if (client is null) {
            showError("No Podman client configured.");
            return false;
        }

        string name = nameEntry.getText().strip;
        string image = imageEntry.getText().strip;
        string command = commandEntry.getText().strip;
        string envText = envEntry.getText().strip;
        string workDir = workDirEntry.getText().strip;

        if (name.empty) {
            showError("Container name is required.");
            return false;
        }

        if (image.empty) {
            showError("Container image is required.");
            return false;
        }

        auto builder = new ContainerBuilder()
            .withName(name)
            .withImage(image);

        auto cmdTokens = splitCommand(command);
        if (cmdTokens.length > 0) {
            builder.withCommand(cmdTokens);
        }

        auto envMap = parseEnv(envText);
        if (envMap.length > 0) {
            builder.withEnv(envMap);
        }

        if (!workDir.empty) {
            builder.withWorkDir(workDir);
        }

        try {
            auto config = builder.build();
            auto id = client.createContainer(name, config);
            if (startCheck.getActive()) {
                client.startContainer(id.length > 0 ? id : name);
            }
            return true;
        } catch (Exception ex) {
            showError(ex.msg);
            return false;
        }
    }

    private string[] splitCommand(string command) {
        if (command.empty) return [];
        string[] tokens;
        foreach (token; command.split()) {
            auto cleaned = token.strip;
            if (!cleaned.empty) {
                tokens ~= cleaned;
            }
        }
        return tokens;
    }

    private string[string] parseEnv(string envText) {
        string[string] env;
        if (envText.empty) return env;

        auto normalized = envText.replace("\n", ",").replace(";", ",");
        foreach (part; normalized.split(",")) {
            auto item = part.strip;
            if (item.empty) continue;
            auto pos = item.indexOf("=");
            if (pos > 0) {
                env[item[0..pos]] = item[pos + 1 .. $];
            } else {
                env[item] = "";
            }
        }

        return env;
    }

    private void showError(string message) {
        auto errorDialog = new MessageDialog(
            dialog,
            GtkDialogFlags.MODAL,
            GtkMessageType.ERROR,
            GtkButtonsType.OK,
            message
        );
        errorDialog.run();
        errorDialog.destroy();
    }
}
