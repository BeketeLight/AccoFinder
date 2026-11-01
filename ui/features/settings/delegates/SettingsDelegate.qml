import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// One row in a settings group. `kind` selects the trailing control:
//   navigation -> value text + chevron, emits activated()
//   toggle     -> a Switch, emits toggled(checked)
//   action     -> value text only, emits activated()
Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string valueText: ""
    property string kind: "navigation"
    property bool checked: false
    property bool destructive: false
    property bool rowEnabled: true
    property string iconText: ""

    signal activated()
    signal toggled(bool checked)

    implicitHeight: rowContent.implicitHeight + 20
    radius: 10
    color: root.destructive
           ? (rowMouse.pressed ? "#FEE2E2" : "transparent")
           : (rowMouse.pressed && root.kind !== "toggle" ? "#F0F4FF" : "transparent")
    opacity: root.rowEnabled ? 1.0 : 0.45

    RowLayout {
        id: rowContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        Rectangle {
            visible: root.iconText.length > 0
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: 8
            color: root.destructive ? "#FEE2E2" : "#EFF6FF"

            Label {
                anchors.centerIn: parent
                text: root.iconText
                color: root.destructive ? "#DC2626" : "#2563EB"
                font.pixelSize: 14
                font.bold: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                Layout.fillWidth: true
                text: root.title
                color: root.destructive ? "#B91C1C" : "#111827"
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: "#6B7280"
                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }
        }

        Label {
            visible: root.kind !== "toggle" && root.valueText.length > 0
            text: root.valueText
            color: "#6B7280"
            font.pixelSize: 12
            elide: Text.ElideRight
            Layout.maximumWidth: root.width * 0.4
        }

        Label {
            visible: root.kind === "navigation"
            text: "\u203A"
            color: "#9CA3AF"
            font.pixelSize: 18
        }

        Switch {
            id: toggleSwitch
            visible: root.kind === "toggle"
            enabled: root.rowEnabled
            onToggled: root.toggled(checked)

            // Keep the control in sync when the stored preference changes from
            // elsewhere, without re-breaking the binding on every user toggle.
            Binding {
                target: toggleSwitch
                property: "checked"
                value: root.checked
                restoreMode: Binding.RestoreBindingOrValue
            }
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        // The Switch owns its own clicks; the row only handles navigation and
        // action rows.
        enabled: root.kind !== "toggle" && root.rowEnabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
