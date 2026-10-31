// One workspace: a dot when empty, a pill with its window icons otherwise.
import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager
import org.kde.kitemmodels as KItemModels

Item {
    id: pill

    property var controller // the PlasmoidItem in main.qml
    property var desktopId
    property int position
    property string name
    property bool isCurrent
    property string activity
    property Item ghost

    readonly property int iconSize: Kirigami.Units.iconSizes.small
    readonly property int maxIcons: 4
    readonly property bool occupied: windows.count > 0
    readonly property bool dragging: ghost && ghost.dragging
    readonly property int pillHeight: iconSize + 8
    readonly property int sidePadding: Kirigami.Units.smallSpacing * 2

    implicitHeight: pillHeight
    implicitWidth: occupied ? icons.implicitWidth + 2 * sidePadding
                            : (dragging ? pillHeight : (isCurrent ? 22 : 14))

    Behavior on implicitWidth {
        NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.OutCubic }
    }

    TaskManager.TasksModel {
        id: tasks
        filterByVirtualDesktop: true
        virtualDesktop: pill.desktopId
        filterByActivity: true
        activity: pill.activity
        filterByScreen: false
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortDisabled
    }

    // The task model also lists windows that want attention (e.g. a chat with
    // unread messages) on every desktop, like the taskbar does. Keep only the
    // ones that are on this desktop.
    KItemModels.KSortFilterProxyModel {
        id: windows
        sourceModel: tasks
        filterRoleName: "VirtualDesktops" // re-check a window when this changes
        filterRowCallback: (row, parent) => {
            const roles = tasks.KItemModels.KRoleNames;
            const index = tasks.index(row, 0, parent);
            if (tasks.data(index, roles.role("IsOnAllVirtualDesktops"))) {
                return true;
            }
            const desktops = tasks.data(index, roles.role("VirtualDesktops")) ?? [];
            return desktops.includes(pill.desktopId);
        }
    }

    KItemModels.KSortFilterProxyModel {
        id: attention
        sourceModel: windows
        filterRoleName: "IsDemandingAttention"
        filterRowCallback: (row, parent) => {
            const role = windows.KItemModels.KRoleNames.role("IsDemandingAttention");
            return windows.data(windows.index(row, 0, parent), role) === true;
        }
    }

    // Index in tasks of a row in windows
    function taskIndex(row) {
        return windows.mapToSource(windows.index(row, 0));
    }

    HoverHandler { id: hover }

    // Pill (occupied), capsule (current and empty) or dot (empty)
    Rectangle {
        id: background
        anchors.centerIn: parent

        readonly property bool big: pill.occupied || dropArea.containsDrag

        width: big ? pill.width : (pill.isCurrent ? pill.width - 4 : 6)
        height: big ? pill.pillHeight : 6
        radius: height / 2

        color: {
            const text = Kirigami.Theme.textColor;
            const accent = Kirigami.Theme.highlightColor;
            if (dropArea.containsDrag) {
                return pill.controller.tint(accent, 0.35);
            }
            if (pill.occupied) {
                if (pill.isCurrent) {
                    return pill.controller.tint(accent, 0.55);
                }
                return pill.controller.tint(text, hover.hovered ? 0.13 : 0.06);
            }
            if (pill.isCurrent) {
                return Qt.lighter(accent, 1.4);
            }
            return pill.controller.tint(text, hover.hovered ? 0.6 : 0.3);
        }

        border.width: dropArea.containsDrag || attention.count > 0 ? 1 : 0
        border.color: dropArea.containsDrag ? Kirigami.Theme.highlightColor : Kirigami.Theme.neutralTextColor

        Behavior on color { ColorAnimation { duration: Kirigami.Units.shortDuration } }
        Behavior on width { NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.OutCubic } }
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: pill.name
        subText: pill.occupied ? i18np("%1 window", "%1 windows", windows.count) : i18n("Empty")
    }

    // Click anywhere on the workspace (not on an icon) to switch to it
    MouseArea {
        anchors.fill: parent
        onClicked: pill.controller.switchTo(pill.position)
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        keys: ["redflake-workspace-window"]
        onDropped: drop => {
            pill.controller.dropOn(pill.desktopId);
            drop.accept();
        }
    }

    Row {
        id: icons
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing
        visible: pill.occupied

        Repeater {
            model: windows

            delegate: Item {
                id: win

                required property var model
                required property int index

                visible: index < pill.maxIcons
                width: pill.iconSize
                height: pill.iconSize

                Kirigami.Icon {
                    anchors.fill: parent
                    source: win.model.decoration
                    opacity: win.model.IsMinimized ? 0.4 : 1.0
                }

                // Marks the focused window
                Rectangle {
                    visible: win.model.IsActive
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom
                    anchors.topMargin: 1
                    width: 6
                    height: 2
                    radius: 1
                    color: Kirigami.Theme.textColor
                }

                PlasmaCore.ToolTipArea {
                    anchors.fill: parent
                    mainText: win.model.display ?? ""
                    subText: win.model.AppName ?? ""
                }

                MouseArea {
                    id: iconMouse

                    property bool dragged: false

                    anchors.fill: parent
                    drag.target: pill.ghost

                    onPressed: {
                        dragged = false;
                        const p = mapToItem(pill.ghost.parent,
                                            (width - pill.ghost.width) / 2,
                                            (height - pill.ghost.height) / 2);
                        pill.ghost.x = p.x;
                        pill.ghost.y = p.y;
                        pill.ghost.source = win.model.decoration;
                    }

                    drag.onActiveChanged: {
                        if (drag.active) {
                            dragged = true;
                            pill.controller.startDrag(tasks, pill.taskIndex(win.index).row, pill.desktopId);
                            pill.ghost.dragging = true;
                        }
                    }

                    onReleased: {
                        if (dragged) {
                            pill.ghost.Drag.drop();
                            pill.ghost.dragging = false;
                            pill.controller.clearDrag(); // in case it was dropped outside

                        } else {
                            tasks.requestActivate(pill.taskIndex(win.index));
                        }
                    }
                }
            }
        }

        PC3.Label {
            visible: windows.count > pill.maxIcons
            height: pill.iconSize
            verticalAlignment: Text.AlignVCenter
            text: "+" + (windows.count - pill.maxIcons)
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.8
        }
    }
}
