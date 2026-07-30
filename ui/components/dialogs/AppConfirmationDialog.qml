import QtQuick 2.15
import QtQuick.Dialogs

Item {
    id: root

    property alias customText: alertDialog.text
    property alias customInformativeText: value
    signal accepted
    MessageDialog {
        id: alertDialog
        text: "change me."
        informativeText: "change me"
        buttons: MessageDialog.Ok
        onAccepted: accepted()
    }
}
