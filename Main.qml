import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./ui/components/navigations"
import "./ui/app"
import "./ui/features/properties/screens"
import "./ui/features/home/screens"
import "./ui/features/home/components"
import "./ui/utils/NavigationUtils.js" as NavUtils

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("AccoFinder")
    flags: {
        if (Qt.platform.os === "android") {
            return Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint
        } else {
            return Qt.Window
        }
    }

    Component.onCompleted: {
        AppSettings.setStatusBarAppearance(Qt.rgba(0,0,0,0),true)
    }
    readonly property var currentPage: (mainStack.depth > 0 && mainStack.currentItem)
                                    ? mainStack.currentItem
                                    :(loader.item ? loader.item: null)

    Shortcut {
        sequences: ["Back", "Esc"]
        context: Qt.ApplicationShortcut
        onActivated: {
            if(mainStack.depth > 1){
                NavUtils.pop()
                return
            }
            if(mainStack.depth === 1){
                mainStack.stackView.clear()
                return
            }
            // If on Account, Properties, or Bookings  go back to Home tab to exit
            if (!loader.source.toString().endsWith("HomeScreen.qml")) {
                loader.source = "./ui/features/home/screens/HomeScreen.qml"

                if (typeof bottomNavBar.currentIndex !== "undefined") {
                    bottomNavBar.currentIndex = 0
                }
                return
            }

            // if already on Home quit
            Qt.quit()
        }
    }

    ColumnLayout{
        anchors.fill: parent
        spacing: 0

        AppHeader{
            id: appHeader
            Layout.fillWidth: true
            //collapse header if not specified
            Layout.preferredHeight: visible ? 64 : 0
            visible: {
                if(!currentPage) return false
                return typeof currentPage.showHeader !== "undefined" ? currentPage.showHeader: true
            }
            //binding readonly to for searchBar
            searchReadOnly: currentPage && typeof currentPage.searchReadOnly !== "undefined"
                            ? currentPage.searchReadOnly
                            : false

            onSearchBarTapped: {
                if(currentPage && typeof currentPage.onSearchBarTapped === "function"){
                    currentPage.onSearchBarTapped()
                }
            }
            title: currentPage && currentPage.pageTitle ? currentPage.pageTitle:""
            isSearchBar: Boolean(currentPage && currentPage.isSearchBar)
            showBackButton: mainStack.depth > 0 || Boolean(currentPage && currentPage.showBack)
            leftAction: currentPage && currentPage.leftComponentAction ? currentPage.leftComponentAction: null
            rightAction: currentPage && currentPage.rightComponentAction ? currentPage.rightComponentAction: null

            onBackClicked: {
                if(mainStack.depth > 0){
                    NavUtils.pop()
                } else if(currentPage && typeof currentPage.goBack === "function"){
                    currentPage.goBack()
                }
            }
        }
        Loader{
            id: loader
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: mainStack.depth === 0
            source: "./ui/features/home/screens/HomeScreen.qml"
        }
        MainStackview{
            id: mainStack
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: depth > 0
        }

        FooterComponent{
            id: bottomNavBar
            Layout.fillWidth: true
            Layout.preferredHeight: 65
            visible: mainStack.depth === 0
            //signals
            onHomeTapped: loader.source = "./ui/features/home/screens/HomeScreen.qml"
            onPropertiesTapped: loader.source = "./ui/features/properties/screens/PropertiesScreen.qml"
            onAccountTapped: loader.source = AppSettings.isLoggedIn()
                             ? "./ui/features/auth/pages/Profile.qml"
                             : "./ui/features/auth/pages/CreateAccountPage.qml"
            onBookingsTapped: loader.source = "./ui/features/bookings/screens/BookingsScreen.qml"
            onSaveTapped: loader.source = ""
        }

    }

}