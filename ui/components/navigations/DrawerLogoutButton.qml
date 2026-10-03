import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../dialogs"
import "../../utils/NavigationUtils.js" as NavUtils

// Sign-out control for the side drawers, mirroring the one on the profile page:
// same styling, same "Signing out..." busy state, and the same AuthController
// logout call. Lives in one place so the admin and agent drawers cannot drift
// apart from the profile page.
Item {
    id: root

    // Set once the user asks to sign out, so the busy dialog is only shown for
    // our own logout and not for unrelated background requests.
    property bool pendingLogout: false

    // Emitted after the session has actually been torn down, so the host drawer
    // can close itself.
    signal logoutCompleted()

    implicitHeight: logoutButton.implicitHeight

    Button {
        id: logoutButton
        anchors.fill: parent
        text: AuthController.isLoading ? qsTr("Signing out...") : qsTr("Sign out")
        enabled: !AuthController.isLoading && !root.pendingLogout

        contentItem: Text {
            text: logoutButton.text
            color: "#B91C1C"
            font.pixelSize: 14
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: 8
            color: logoutButton.down ? "#FEE2E2" : "#FEF2F2"
            border.color: "#FECACA"
        }

        onClicked: {
            root.pendingLogout = true
            AuthController.logOut()
        }
    }

    // No explicit parent: like the profile page's dialog, this relies on Popup
    // re-parenting itself into the window overlay. Setting parent to
    // Overlay.overlay instead resolves to null when the host is a Drawer, which
    // leaves the dialog parentless and never shown.
    AppLoadingDialog {
        id: logoutDialog
        title: qsTr("Signing out")
        message: qsTr("Signing out...")
    }

    Connections {
        target: AuthController

        function onUserLoggedOut() {
            // Both drawers are alive at once, so both instances see this signal.
            // Only the one whose button was pressed should act, otherwise the
            // idle drawer resets navigation a second time.
            if (!root.pendingLogout)
                return
            root.pendingLogout = false
            root.logoutCompleted()
            // Same landing page the profile page uses, so signing out from a
            // drawer and from the profile end up in the same place.
            NavUtils.resetToSignIn()
        }

        // Read the property rather than the signal argument so the dialog does
        // not depend on isLoadingChanged carrying its new value.
        function onIsLoadingChanged() {
            if (!root.pendingLogout)
                return
            if (AuthController.isLoading)
                logoutDialog.open()
            else
                logoutDialog.close()
        }
    }
}
