import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../components/pages"
import "../../dashboards/admins/pages"

Rectangle {
    id: root
    anchors.fill: parent
    color: "#F4F6F9"

    readonly property bool isGuest: !AppSettings.isLoggedIn()
    readonly property bool isClient: AppSettings.isLoggedIn() && AppSettings.userType() === "CLIENT"
    readonly property bool isAgent: AppSettings.isLoggedIn() && AppSettings.userType() === "AGENT"
    readonly property bool isAdmin: AppSettings.isLoggedIn() && AppSettings.userType() === "ADMIN"
    // --- USER-ROLE ROUTER ---
    Loader {
        anchors.fill: parent
        //visible: !root.isGuest && !root.isAdmin
        source: {
            if (root.isAgent)  return "BookingOverviewAgentPage.qml"
            if (root.isClient) return "BookingOverviewClientPage.qml"
            if(root.isAdmin) return "BookingOverviewAdminPage.qml"
            if (root.isGuest) return "../../auth/screens/SignInScreen.qml"
            return ""
        }
    }

    // Admins get the platform-wide oversight list rather than a blank page.
    // The page is content-only, so it is hosted in the shared scrollable shell
    // here - the same shell AdminBookingsScreen uses when the list is reached
    // by pushing from the admin dashboard.
}