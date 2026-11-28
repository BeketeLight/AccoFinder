import QtQuick
import "../pages"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    // Reached from the footer's Bookings tab, which is a root-level destination
    // rather than a pushed page, so the header hides the back arrow.
    property string pageTitle: qsTr("Bookings")
    property bool showHeader: true
    property bool showBack: false
    property bool showBackButton: false
    property bool showBottomBorder: true
    property bool isSearchBar: false
    property int titleFontSize: 15

    // Forward the root tab's visible/idle state into the role-specific list so
    // its QML mirror is not rebuilt under the user's finger.
    readonly property bool refreshAllowed: root.enabled && root.visible && bookingPage.scrollIdle
    readonly property bool scrollIdle: bookingPage.scrollIdle

    function goBack() { NavUtils.pop() }

    // BookingPage routes on the viewer's own role, so admins reach their
    // oversight list here too rather than a blank page.
    BookingPage {
        id: bookingPage
        anchors.fill: parent
        refreshAllowed: root.refreshAllowed
    }
}
