import QtQuick
import QtQuick.Controls
import "../indicators"
import "../../utils/NavigationUtils.js" as NavUtils

// Sign-out control for the side drawers, mirroring the one on the profile page:
// same styling, same "Signing out..." busy state, and the same AuthController
// logout call. Lives in one place so the admin and agent drawers cannot drift
// apart from the profile page.
Item {
    id: root

    // Set once the user asks to sign out, so the busy state is only shown for
    // our own logout and not for unrelated background requests.
    property bool pendingLogout: false

    // The button's busy state. Driven by pendingLogout rather than the global
    // AuthController.isLoading, so a concurrent background request cannot make
    // an idle sign-out button look like it is signing the user out.
    readonly property bool busy: pendingLogout

    // Emitted after the session has actually been torn down, so the host drawer
    // can close itself.
    signal logoutCompleted()

    implicitHeight: logoutButton.implicitHeight

    Button {
        id: logoutButton
        anchors.fill: parent
        text: root.busy ? qsTr("Signing out...") : qsTr("Sign out")
        enabled: !AuthController.isLoading && !root.busy

        // Spinner sits inside the button instead of in a modal dialog. The dialog
        // was re-parented into the window overlay, so inside a Drawer it opened
        // as a separate panel hanging under the button and read as a second
        // control rather than as the button's own busy state.
        contentItem: Item {
            Text {
                id: logoutLabel
                anchors.centerIn: parent
                // Half the spinner (18px) plus half the 8px gap, so the spinner
                // and label stay centred together as the text length changes.
                anchors.horizontalCenterOffset: root.busy ? 13 : 0
                text: logoutButton.text
                color: "#B91C1C"
                font.pixelSize: 14
                font.bold: true
            }

            AppSpinner {
                // Explicit width/height: this contentItem is a plain Item, not a
                // layout, so AppSpinner's implicit size is never applied.
                width: 18
                height: 18
                size: 18
                lineWidth: 2.5
                // Matches the label so the whole control reads as one red action.
                color: "#B91C1C"
                anchors.right: logoutLabel.left
                anchors.rightMargin: 8
                anchors.verticalCenter: logoutLabel.verticalCenter
                visible: root.busy
                running: root.busy
            }
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
    }
}
