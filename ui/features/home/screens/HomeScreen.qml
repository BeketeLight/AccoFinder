import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../components/pages"
import "../../../components/navigations"
import "../components"
import "../pages"
import "../models"

Item {
    id: root
    objectName: "HomeScreen"
    anchors.fill: parent

    property string pageTitle: qsTr("Home")
    property bool showHeader: true
    property bool showBack: false
    property bool showBottomBorder: false
    property bool isSearchBar: true
    property bool searchReadOnly: false
    property int titleFontSize: 15

    property Component rightComponentAction: Component {
        AppNotificationBell {
            notificationScreen: Qt.resolvedUrl("../../notifications/screens/NotificationsScreen.qml")
        }
    }

    PropertiesModel {
        id: sharedProperties
    }

    property bool refreshing: false
    readonly property bool loading: sharedProperties.loading

    function refresh() {
        if (root.refreshing)
            return;
        root.refreshing = true;
        PropertyViewModel.getProperties();
    }

    function goBack() {
    }

    Connections {
        target: PropertyViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.refreshing = false;
        }
    }

    // If your app does NOT auto-render AppHeader from these props,
    // uncomment this block and remove the "anchors.fill: parent" from the
    // ColumnLayout below (change to anchors.top: header.bottom).
    // AppHeader {
    //     id: homeHeader
    //     anchors.top: parent.top
    //     anchors.left: parent.left
    //     anchors.right: parent.right
    //     title: root.pageTitle
    //     isSearchBar: root.isSearchBar
    //     searchReadOnly: root.searchReadOnly
    //     showBottomBorder: root.showBottomBorder
    //     titleFontSize: root.titleFontSize
    //     rightAction: root.rightComponentAction
    //     onSearchBarTapped: NavUtils.navigateToSearchScreen()
    // }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 0

        // Chips (pinned)
        PropertyCategoryRow {
            id: categoryRow
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            currentIndex: pager.currentIndex
            model: ListModel {
                ListElement {
                    name: "All"
                }
                ListElement {
                    name: "Hostels"
                }
                ListElement {
                    name: "Quarters"
                }
                ListElement {
                    name: "House"
                }
            }
            onCategoryClicked: function (index, name) {
                pager.currentIndex = index;
            }
        }

        // Pager (fills the rest)
        SwipeView {
            id: pager
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            currentIndex: 0

            onCurrentIndexChanged: {
                categoryRow.currentIndex = currentIndex;
                root.applyTabFilter(currentIndex);
            }

            // Page 0 — All
            AppScrollablePage {
                pullEnabled: true
                refreshing: root.refreshing
                loading: root.loading
                contentTopMargin: 16
                onRefreshRequested: root.refresh()

                HomePage {
                    Layout.fillWidth: true
                    propertiesModelRef: sharedProperties
                    showSuperDeals: true
                    headingText: qsTr("All Properties")
                }
            }

            // Page 1 — Hostels
            AppScrollablePage {
                pullEnabled: true
                refreshing: root.refreshing
                loading: root.loading
                contentTopMargin: 16
                onRefreshRequested: root.refresh()

                HomePage {
                    Layout.fillWidth: true
                    propertiesModelRef: sharedProperties
                    showSuperDeals: false
                    headingText: qsTr("Hostels")
                }
            }

            // Page 2 — Quarters
            AppScrollablePage {
                pullEnabled: true
                refreshing: root.refreshing
                loading: root.loading
                contentTopMargin: 16
                onRefreshRequested: root.refresh()

                HomePage {
                    Layout.fillWidth: true
                    propertiesModelRef: sharedProperties
                    showSuperDeals: false
                    headingText: qsTr("Quarters")
                    renderAs: "quarter"
                }
            }

            // Page 3 — Houses
            AppScrollablePage {
                pullEnabled: true
                refreshing: root.refreshing
                loading: root.loading
                contentTopMargin: 16
                onRefreshRequested: root.refresh()

                HomePage {
                    Layout.fillWidth: true
                    propertiesModelRef: sharedProperties
                    showSuperDeals: false
                    headingText: qsTr("Houses")
                }
            }
        }
    }

    function applyTabFilter(index) {
        var t = "ALL";
        if (index === 1)
            t = "HOSTEL";
        else if (index === 2)
            t = "QUARTER";
        else if (index === 3)
            t = "WHOLE";
        sharedProperties.setFilter(t);
    }
    Component.onCompleted: {
        sharedProperties.reload();
        PropertyViewModel.getProperties();
        applyTabFilter(0);
    }
}
