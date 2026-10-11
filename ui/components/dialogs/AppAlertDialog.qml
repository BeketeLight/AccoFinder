import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string customText: qsTr("Cancel booking?")
    property string customInformativeText: qsTr("Are you sure you want to cancel this booking?")
    property alias visibleDialog: alertDialog.visible

    signal accepted()
    signal rejected()

    // Optional: fill host so local anchors still work if Overlay is unavailable
    anchors.fill: parent

    function open()  { alertDialog.open() }
    function close() { alertDialog.close() }

    Dialog {
        id: alertDialog

        // Critical: center on the full window, not the details column
        parent: Overlay.overlay
        anchors.centerIn: parent

        width: Math.min(Overlay.overlay ? Overlay.overlay.width - 48 : 320, 380)
        padding: 0
        modal: true
        dim: true
        closePolicy: Popup.CloseOnEscape

        // Solid card
        background: Rectangle {
            color: "#FFFFFF"
            radius: 20
            border.color: "#E2E8F0"
            border.width: 1
        }

        // Dimmed backdrop (Controls 2)
        Overlay.modal: Rectangle {
            color: "#80000000"
        }

        contentItem: ColumnLayout {
            spacing: 0
            // ... keep your existing content (icon, texts, buttons) ...
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                // Rectangle {
                //     Layout.topMargin: 22
                //     Layout.leftMargin: 22
                //     width: 42
                //     height: 42
                //     radius: 21
                //     color: "#FFF1F2"
                //     Text {
                //         anchors.centerIn: parent
                //         text: "!"
                //         color: "#E11D48"
                //         font.pixelSize: 25
                //         font.bold: true
                //     }
                // }
                Text {
                    Layout.leftMargin: 22
                    Layout.rightMargin: 22
                    Layout.fillWidth: true
                    text: root.customText
                    font.pixelSize: 19
                    font.bold: true
                    color: "#0F172A"
                    wrapMode: Text.WordWrap
                }
                Text {
                    Layout.leftMargin: 22
                    Layout.rightMargin: 22
                    Layout.bottomMargin: 24
                    Layout.fillWidth: true
                    text: root.customInformativeText
                    font.pixelSize: 13
                    color: "#64748B"
                    wrapMode: Text.WordWrap
                    lineHeight: 1.25
                }
            }
            // Rectangle {
            //     Layout.fillWidth: true
            //     height: 1
            //     color: "#E2E8F0"
            // }
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 18
                spacing: 12
                Item { Layout.fillWidth: true }
                Button {
                    text: qsTr("Cancel")
                    implicitWidth: 100
                    implicitHeight: 44
                    onClicked: {
                        alertDialog.close()
                        root.rejected()
                    }
                    background: Rectangle {
                        radius: 12
                        color: "#F8FAFC"
                        border.color: "#CBD5E1"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#475569"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Button {
                    text: qsTr("Confirm")
                    implicitWidth: 100
                    implicitHeight: 44
                    onClicked: {
                        alertDialog.close()
                        root.accepted()
                    }
                    background: Rectangle {
                        radius: 12
                        color: "#E11D48"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}