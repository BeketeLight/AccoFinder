import QtQuick 2.15
import "../pages"
Item {
    id:root
    property string pageTitle: "Bookings"
    property bool showHeader: true
    property bool showBack: false
    property bool showBackButton: false
    property bool isSearchBar: false
    BookingPage{
        anchors.fill: parent
    }
}
