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
        }
    }

    background: Rectangle {
        radius: 16
        color: "#FFFFFF"
        border.color: "#E5E7EB"
        border.width: 1
    }
}
