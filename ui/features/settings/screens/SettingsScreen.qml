import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../components/pages"
import "../../../utils/NavigationUtils.js" as NavUtils

// Settings is pushed onto the main stack from Profile and the account drawers.
// It deliberately reuses the shared AppScrollablePage shell so the header,
// scrollbar and safe-area behaviour match every other pushed screen.
Item {
    id: root

    property string pageTitle: qsTr("Settings")
    property bool showHeader: true
    property bool showBack: true

    function goBack() {
        NavUtils.pop()
    }

    AppScrollablePage {
        anchors.fill: parent

        SettingsPage {
            id: settingsPage
            Layout.fillWidth: true
        }
    }
}
