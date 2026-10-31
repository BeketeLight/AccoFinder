import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../components/pages"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("Report a problem")
    property bool showHeader: true
    property bool showBack: true

    // Assigned by NavUtils.navigateToRaiseDispute
    property string bookingId: ""
    property string propertyImage: ""
    property string propertyLocation: ""
    property string houseName: ""
    property string landlord: ""
    property string hostName: ""
    property string status: ""
    property string bookingDate: ""

    function goBack() { NavUtils.pop() }

    AppScrollablePage {
        anchors.fill: parent

        CreateDisputePage {
            id: page
            Layout.fillWidth: true
            bookingId: root.bookingId
            propertyLocation: root.propertyLocation
            houseName: root.houseName
            bookingDate: root.bookingDate
        }
    }
}
