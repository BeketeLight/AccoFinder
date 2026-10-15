import QtQuick
import "../pages"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    // Reached from the footer's Saves tab, which is a root-level destination
    // rather than a pushed page, so the header hides the back arrow.
    property string pageTitle: qsTr("Saves")
    property bool showHeader: true
    property bool showBack: false
    property bool showBackButton: false
    property bool showBottomBorder: true
    property bool isSearchBar: false
    property int titleFontSize: 15

    function goBack() {
        NavUtils.pop();
    }

    // SavesPage routes on the viewer's own role, so admins reach their
    // oversight list here too rather than a blank page.
    SavesPage {
        anchors.fill: parent
    }
}
