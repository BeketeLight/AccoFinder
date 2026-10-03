import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../indicators"

Dialog {
    id: loadingDialog
    title: "Please wait"
    modal: true
    closePolicy: Popup.NoAutoClose
    anchors.centerIn: parent
    property alias message: messageLabel.text

    // Long-running flows that can be abandoned (e.g. the browser hand-off in
    // a Google sign-in) opt into a cancel button so the dialog is not a dead
    // end for the full length of the operation.
    property bool cancellable: false
    property string cancelText: "Cancel"
    signal cancelled()

    standardButtons: Dialog.NoButton

    contentItem: ColumnLayout {
        spacing: 18
        anchors.margins: 24

        AppSpinner {
            Layout.alignment: Qt.AlignHCenter
            size: 40
            lineWidth: 3.5
            color: "#2563EB"
            running: loadingDialog.visible
        }

        Label {
            id: messageLabel
            text: "Loading..."
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 15
            font.weight: Font.Medium
            color: "#374151"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Button {
            id: cancelButton
            Layout.alignment: Qt.AlignHCenter
            visible: loadingDialog.cancellable
            Layout.preferredHeight: visible ? 40 : 0
            text: loadingDialog.cancelText

            contentItem: Label {
                text: cancelButton.text
                color: "#2563EB"
                font.pixelSize: 14
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 10
                color: cancelButton.down ? "#EFF6FF" : "transparent"
                border.color: "#BFDBFE"
                border.width: 1
            }

            onClicked: loadingDialog.cancelled()
        }
    }

    background: Rectangle {
        radius: 16
        color: "#FFFFFF"
        border.color: "#E5E7EB"
        border.width: 1
    }
}
