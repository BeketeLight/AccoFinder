import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils

Rectangle {
    id: root
    anchors.fill: parent
    color: "#F4F6F9"

    readonly property bool isGuest: !AppSettings.isLoggedIn()
    readonly property bool isClient: AppSettings.isLoggedIn() && AppSettings.userType() === "CLIENT"
    readonly property bool isAgent: AppSettings.isLoggedIn() && AppSettings.userType() === "AGENT"

    // --- GUEST VIEW BANNER ---
    ColumnLayout {
        anchors.fill: parent
        visible: root.isGuest
        //Layout.visible: visible
        spacing: 16

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            color: "#2563EB"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: qsTr("Welcome to AccoFinder")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#FFFFFF"
                }
                Text {
                    text: qsTr("Sign in to manage or view your bookings.")
                    color: "#E0F2FE"
                }
                Button {
                    text: qsTr("Sign in / Register")
                    onClicked: NavUtils.navigateToSignIn()
                }
            }
        }
    }

    // --- LOGGED-IN ROLE ROUTER ---
    Loader {
        anchors.fill: parent
        visible: !root.isGuest
        source: {
            if (root.isAgent)  return "BookingOverviewAgentPage.qml"
            if (root.isClient) return "BookingOverviewClientPage.qml"
            return ""
        }
    }
}