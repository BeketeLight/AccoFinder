import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string draftKey: ""
    property string draftTitle: ""
    property string propertyType: ""
    property string locationText: ""
    property bool locationVisible: false

    property color pageColor: "#F8FAFC"
    property color primaryColor: "#2563EB"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"

    signal resendRequested(string draftKey)
    signal deleteRequested(string draftKey)

    Layout.fillWidth: true
    implicitHeight: cardColumn.implicitHeight + 24
    radius: 14
    color: root.pageColor
    border.color: root.borderColor
    border.width: 1

    ColumnLayout {
        id: cardColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                Layout.fillWidth: true
                text: root.draftTitle
                color: root.textColor
                font.pixelSize: 15
                font.bold: true
                elide: Text.ElideRight
            }

            Label {
                text: root.propertyType
                color: root.primaryColor
                font.pixelSize: 11
                font.bold: true
            }
        }

        Label {
            Layout.fillWidth: true
            visible: root.locationVisible
            text: root.locationText
            color: root.mutedColor
            font.pixelSize: 12
            elide: Text.ElideRight
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                text: qsTr("Resend")

                contentItem: Label {
                    text: parent.text
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 10
                    color: parent.down ? "#1D4ED8" : root.primaryColor
                }
                onClicked: root.resendRequested(root.draftKey)
            }

            Button {
                Layout.preferredHeight: 38
                Layout.preferredWidth: 72
                text: qsTr("Delete")

                contentItem: Label {
                    text: parent.text
                    color: "#B91C1C"
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 10
                    color: parent.down ? "#FEE2E2" : "#FEF2F2"
                    border.color: "#FECACA"
                    border.width: 1
                }
                onClicked: root.deleteRequested(root.draftKey)
            }
        }
    }
}