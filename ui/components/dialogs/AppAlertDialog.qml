import QtQuick 2.15
import QtQuick.Dialogs

Item {
    id: root

    property alias customText: alertDialog.text
    property alias customInformativeText: value
    signal accepted
    signal rejected
    MessageDialog {
        id: alertDialog
        text: "change me."
        informativeText: "change me"
        buttons: MessageDialog.Ok | MessageDialog.Cancel
        onAccepted: accepted()
        onRejected: rejected()
    }
}
