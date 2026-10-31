// Red Flake Workspaces: one pill per virtual desktop, showing the windows on it.
//
//   click a workspace      switch to it
//   click a window icon    focus that window
//   drag a window icon     drop it on another workspace to move the window there
//   scroll                 previous / next workspace
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager
import org.kde.plasma.workspace.dbus as DBus
import org.kde.kcmutils as KCM
import org.kde.config as KConfig

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    // Window currently being dragged between workspaces
    property var dragTasksModel: null
    property int dragRow: -1
    property var dragSourceDesktop: null

    TaskManager.VirtualDesktopInfo { id: desktopInfo }
    TaskManager.ActivityInfo { id: activityInfo }

    function tint(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    // position is 0-based; KWin counts from 1
    function switchTo(position) {
        DBus.SessionBus.asyncCall({
            "service": "org.kde.KWin",
            "path": "/KWin",
            "iface": "org.kde.KWin",
            "member": "setCurrentDesktop",
            "arguments": [new DBus.int32(position + 1)],
            "signature": "(i)"
        });
    }

    function step(delta) {
        const count = desktopInfo.numberOfDesktops;
        if (count < 2) {
            return;
        }
        const current = desktopInfo.desktopIds.indexOf(desktopInfo.currentDesktop);
        switchTo(((current + delta) % count + count) % count);
    }

    function startDrag(tasksModel, row, desktopId) {
        dragTasksModel = tasksModel;
        dragRow = row;
        dragSourceDesktop = desktopId;
    }

    function dropOn(desktopId) {
        if (dragTasksModel && dragRow >= 0 && desktopId && desktopId !== dragSourceDesktop) {
            dragTasksModel.requestVirtualDesktops(dragTasksModel.makeModelIndex(dragRow), [desktopId]);
        }
        clearDrag();
    }

    function clearDrag() {
        dragTasksModel = null;
        dragRow = -1;
        dragSourceDesktop = null;
    }

    fullRepresentation: Item {
        id: content

        Layout.minimumWidth: row.implicitWidth
        Layout.preferredWidth: row.implicitWidth
        Layout.maximumWidth: row.implicitWidth
        Layout.fillHeight: true

        WheelHandler {
            property int accumulated: 0
            onWheel: event => {
                accumulated += event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x;
                if (Math.abs(accumulated) >= 120) {
                    root.step(accumulated > 0 ? -1 : 1);
                    accumulated = 0;
                }
            }
        }

        Row {
            id: row
            anchors.verticalCenter: parent.verticalCenter
            spacing: Math.round(Kirigami.Units.smallSpacing * 1.5)

            Repeater {
                model: desktopInfo.desktopIds

                delegate: WorkspacePill {
                    required property var modelData
                    required property int index

                    controller: root
                    desktopId: modelData
                    position: index
                    name: desktopInfo.desktopNames[index] ?? ""
                    isCurrent: modelData === desktopInfo.currentDesktop
                    activity: activityInfo.currentActivity
                    ghost: dragGhost
                }
            }
        }

        // Icon that follows the pointer while a window is dragged to another workspace
        Kirigami.Icon {
            id: dragGhost

            property bool dragging: false

            width: Kirigami.Units.iconSizes.small
            height: width
            visible: dragging
            opacity: 0.85
            z: 100

            Drag.active: dragging
            Drag.keys: ["redflake-workspace-window"]
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Configure Virtual Desktops…")
            icon.name: "preferences-desktop-virtual"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}
