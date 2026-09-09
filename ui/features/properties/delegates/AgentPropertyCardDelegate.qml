import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: root

    property string title: ""
    property string district: ""
    property string village: ""
    property real price: 0
    property string verificationStatus: ""
    property string rejectionReason: ""
    property string source: ""
    property string propertyId: ""
    property bool matches: true

    property color primaryColor: "#2563EB"
    property color surfaceColor: "#FFFFFF"
    property color softBlueColor: "#EFF6FF"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"

    signal opened(var propertyId, var source)

    function prettyStatus(s) {
        var v = String(s).toUpperCase()
        if (v === "VERIFIED") return qsTr("Verified")
        if (v === "PENDING") return qsTr("Pending")
        if (v === "REJECTED") return qsTr("Rejected")
        if (v === "DRAFT") return qsTr("Draft")
        return v.length > 0 ? v : qsTr("Draft")
    }

    Layout.fillWidth: true
    implicitHeight: propRow.implicitHeight + 24
    radius: 12
    color: propCardMouse.pressed ? root.softBlueColor : root.surfaceColor
    border.color: propCardMouse.pressed ? "#BFDBFE" : root.borderColor
    border.width: 1
    visible: root.matches

    RowLayout {
        id: propRow
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            radius: 12
            color: root.softBlueColor

            Label {
                anchors.centerIn: parent
                text: String(root.title).charAt(0)
                color: root.primaryColor
                font.pixelSize: 17
                font.bold: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                Layout.fillWidth: true
                text: root.title
                color: root.textColor
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true
                text: (root.district ? root.district + " · " : "") +
                      (root.village ? root.village + " · " : "") +
                      qsTr("MK %1").arg(Number(root.price).toLocaleString()) + qsTr("/mo")
                color: root.mutedColor
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        StatusChip {
            textValue: root.prettyStatus(root.verificationStatus)
            variant: {
                var s = String(root.verificationStatus).toUpperCase()
                if (s === "VERIFIED") return "success"
                if (s === "PENDING") return "warning"
                if (s === "REJECTED") return "danger"
                return "neutral"
            }
        }

        Label {
            visible: String(root.verificationStatus || "").toUpperCase() === "REJECTED"
                   && root.rejectionReason && String(root.rejectionReason).length > 0
            Layout.fillWidth: true
            text: qsTr("Reason: %1").arg(root.rejectionReason)
            color: "#B91C1C"
            font.pixelSize: 11
            elide: Text.ElideRight
        }

        Item {
            Layout.preferredWidth: 9
            Layout.preferredHeight: 16

            Rectangle {
                width: 10
                height: 1.8
                radius: 0.9
                color: root.mutedColor
                rotation: 45
                transformOrigin: Item.Left
                x: 0
                y: 2.5
            }

            Rectangle {
                width: 10
                height: 1.8
                radius: 0.9
                color: root.mutedColor
                rotation: -45
                transformOrigin: Item.Left
                x: 0
                y: 13.5
            }
        }
    }

    MouseArea {
        id: propCardMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.opened(root.propertyId, root.source)
    }
}