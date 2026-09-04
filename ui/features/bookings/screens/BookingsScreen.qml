import QtQuick 2.15
import "../pages"
Item {
    id:root
    property string pageTitle: "My Bookings"
    property bool showHeader: true
     property bool showBack: true
    property bool showBackButton: false
     property bool isSearchBar: false
    BookingPage{
        anchors.fill: parent
    }
}
