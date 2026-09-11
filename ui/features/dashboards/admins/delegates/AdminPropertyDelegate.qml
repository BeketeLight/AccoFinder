import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string propertyId: ""
    property string title: ""
    property string district: ""
    property string village: ""
    property string landlord: ""
    property string status: ""
    property string statusText: ""
    property string approvedByName: ""
    property bool matches: true

    property color primaryColor: "#2563EB"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color surfaceColor: "#FFFFFF"
    property color softBlueColor: "#EFF6FF"

    signal propertyClicked(var propertyId)

    Layout.fillWidth: true
    implicitHeight: propRow.implicitHeight + 24
    radius: 12
    color: propMouse.pressed ? root.softBlueColor : root.surfaceColor
    border.color: root.borderColor
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
                text: root.title.length > 0 ? root.title.charAt(0) : ""
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
                text: root.district + " \u00B7 " + root.village
                color: root.mutedColor
                font.pixelSize: 11
                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Landlord: %1").arg(root.landlord)
                color: root.mutedColor
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }

        Rectangle {
            implicitHeight: 22
            implicitWidth: statusLabel.implicitWidth + 14
            radius: 11
            color: {
                var s = String(root.status).toUpperCase()
                if (s === "VERIFIED") return "#ECFDF5"
                if (s === "PENDING") return "#FFFBEB"
                if (s === "REJECTED") return "#FEF2F2"
                return "#F3F4F6"
            }

            Label {
                id: statusLabel
                anchors.centerIn: parent
                text: root.statusText
                color: {
                    var s = String(root.status).toUpperCase()
                    if (s === "VERIFIED") return "#166534"
                    if (s === "PENDING") return "#B45309"
                    if (s === "REJECTED") return "#B91C1C"
                    return "#6B7280"
                }
                font.pixelSize: 10
                font.bold: true
            }
        }

        Label {
            visible: String(root.status).toUpperCase() === "VERIFIED"
                     && root.approvedByName.length > 0
            Layout.maximumWidth: 110
            text: qsTr("by %1").arg(root.approvedByName)
            color: root.mutedColor
            font.pixelSize: 10
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: propMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.propertyClicked(root.propertyId)
    }
}