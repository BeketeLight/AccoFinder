import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../components/pages"
import "../../../components/navigations"
import "../pages"
import "../models"

Item {
    id: root
    objectName: "HomeScreen"
    anchors.fill: parent

    // ========== SCREEN CONTRACT ==========
    property string pageTitle: qsTr("Home")
    property bool showHeader: true
    property bool showBack: false
    property bool showBottomBorder: false
    property bool isSearchBar: true
    property bool searchReadOnly: false
    property int titleFontSize: 15

    // Header bell: notification list, same as every other screen.
    property Component rightComponentAction: Component {
        AppNotificationBell {
            notificationScreen: Qt.resolvedUrl("../../notifications/screens/NotificationsScreen.qml")
        }
    }

    // ========== PALETTE ==========
    readonly property color pageColor: "#F8FAFC"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    // ========== SHARED MODEL ==========
    // ONE PropertiesModel shared by the whole Home feature.
    PropertiesModel {
        id: sharedProperties
    }

    // ========== REFRESH RHYTHM ==========
    property bool refreshing: false
    readonly property bool loading: sharedProperties.loading

    function refresh() {
        if (root.refreshing)
            return;
        root.refreshing = true;
        PropertyViewModel.getProperties();
    }

    function goBack() {
        // Home is a root tab — nothing to do.
    }

    Connections {
        target: PropertyViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.refreshing = false;
        }
    }

    Component.onCompleted: {
        sharedProperties.reload();
        PropertyViewModel.getProperties();
    }

    // ========== CONTENT ==========
    // Shared shell: #F8FAFC background, one Flickable, centered 520 column,
    // pull-to-refresh strip, and loading spinner — all for free.
    AppScrollablePage {
        anchors.fill: parent
        pullEnabled: true
        refreshing: root.refreshing
        loading: root.loading
        contentTopMargin: 16
        onRefreshRequested: root.refresh()

        HomePage {
            Layout.fillWidth: true
            propertiesModelRef: sharedProperties
        }
    }
}
