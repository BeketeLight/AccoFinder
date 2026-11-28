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

    // BookingsScreen injects the root tab's visible/idle state; role-specific
    // pages use it to defer their ListModel mirrors.
    property bool refreshAllowed: true
    readonly property bool scrollIdle: bookingLoader.item
                                       && typeof bookingLoader.item.scrollIdle !== "undefined"
                                       ? bookingLoader.item.scrollIdle
                                       : true

    // --- USER-ROLE ROUTER ---
    Loader {
        id: bookingLoader
        anchors.fill: parent
        source: {
            if (root.isAgent)  return "BookingOverviewAgentPage.qml"
            if (root.isClient) return "BookingOverviewClientPage.qml"
            if(root.isAdmin) return "../../dashboards/admins/screens/AdminBookingsScreen.qml" //"BookingOverviewAdminPage.qml"
            if (root.isGuest) return "../../auth/screens/SignInScreen.qml"
            return ""
        }
    }

    // The role page may be a client/agent list or the admin oversight screen;
    // only pages that opt in to the refresh gate receive this binding.
    Binding {
        target: bookingLoader.item
        property: "refreshAllowed"
        value: root.refreshAllowed
        when: bookingLoader.item !== null && "refreshAllowed" in bookingLoader.item
    }

    // Admins get the platform-wide oversight list rather than a blank page.
    // The page is content-only, so it is hosted in the shared scrollable shell
    // here - the same shell AdminBookingsScreen uses when the list is reached
    // by pushing from the admin dashboard.
}