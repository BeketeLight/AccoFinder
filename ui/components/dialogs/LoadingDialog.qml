import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: loadingDialog
    title: "Please wait"
    modal: true
    closePolicy: Popup.NoAutoClose
    anchors.centerIn: parent

    standardButtons: Dialog.NoButton

    contentItem: ColumnLayout {
        spacing: 20
        anchors.margins: 20

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: true
        }

        Label {
            text: "Loading..."
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 16
        }
    }
}
