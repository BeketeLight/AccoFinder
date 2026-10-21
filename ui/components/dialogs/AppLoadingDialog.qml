import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../indicators"

Dialog {
    id: loadingDialog
    title: "Please wait"
    modal: true
    dim: true
    closePolicy: Popup.NoAutoClose
    property alias message: messageLabel.text

    // Long-running flows that can be abandoned (e.g. the browser hand-off in
    // a Google sign-in) opt into a cancel button so the dialog is not a dead
    // end for the full length of the operation.
    property bool cancellable: false
    property string cancelText: "Cancel"
    signal cancelled()

    standardButtons: Dialog.NoButton

    // The dialog is parented to the overlay so that it is centered on the
    // whole window and not on the page that happens to host it.
    parent: Overlay.overlay
    anchors.centerIn: parent

    width: Math.min(Overlay.overlay ? Overlay.overlay.width - 48 : 280, 280)

    // The style brings its own padding and a title bar; the card below does
    // the spacing and the heading itself, the way the other dialogs of the
    // app do it.
    padding: 18
    topPadding: 18
    bottomPadding: 18
    leftPadding: 18
    rightPadding: 18
    header: null

    // The dimmed backdrop used by the other dialogs of the app.
    Overlay.modal: Rectangle {
        color: "#80000000"
    }

    contentItem: ColumnLayout {
        spacing: 12

        Text {
            Layout.fillWidth: true
            text: loadingDialog.title
            font.pixelSize: 17
            font.bold: true
            color: "#0F172A"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        AppSpinner {
            Layout.alignment: Qt.AlignHCenter
            size: 32
            lineWidth: 3
            color: "#2563EB"
            running: loadingDialog.visible
        }

        Label {
            id: messageLabel
            text: ""
            visible: text.length > 0
            Layout.fillWidth: true
            font.pixelSize: 12
            color: "#64748B"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            lineHeight: 1.25
        }

        Button {
            id: cancelButton
            Layout.alignment: Qt.AlignHCenter
            visible: loadingDialog.cancellable
            Layout.preferredHeight: visible ? 40 : 0
            implicitWidth: 104
            text: loadingDialog.cancelText

            contentItem: Text {
                text: cancelButton.text
                color: cancelButton.down ? "#334155" : "#475569"
                font.pixelSize: 13
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 12
                color: cancelButton.down ? "#E2E8F0" : "#F8FAFC"
                border.color: "#CBD5E1"
                border.width: 1
            }

            onClicked: loadingDialog.cancelled()
        }
    }

    background: Rectangle {
        radius: 16
        color: "#FFFFFF"
        border.color: "#E2E8F0"
        border.width: 1
    }
}
