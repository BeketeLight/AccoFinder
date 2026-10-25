import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root

    // Must exist so push({ ... }) can assign them
    property string bookingId: ""
    property string propertyImage: ""
    property string propertyLocation: ""
    property string houseName: ""
    property string landlord: ""
    property string hostName: ""
    property string status: ""
    property string bookingDate: ""

    property string pageTitle: qsTr("Report a problem")
    property bool showHeader: true
    property bool showBack: true
    property bool isSearchBar: false
    property bool collapsible: false
    property bool transparentHeader: false

    property string issueText: ""

    function goBack() { NavUtils.pop() }

    // ... form UI using root.bookingId, root.houseName, etc.
}