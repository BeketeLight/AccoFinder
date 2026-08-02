import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
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

    // Material Theme configuration
    Material.accent: "#2563EB"

    flags: {
        if (Qt.platform.os === "android") {
            return Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint;
        } else {
            return Qt.Window;
        }
    }

    Component.onCompleted: {
        AppSettings.setStatusBarAppearance(Qt.rgba(0, 0, 0, 0), true);
        //NavUtils.init(mainStack)
    }

    Shortcut {
        sequences: ["Back", "Esc"]
        context: Qt.ApplicationShortcut
        onActivated: {
            if (mainStack.depth) {
                NavUtils.pop();
                return;
            }
            // If on Account, Properties, or Bookings  go back to Home tab to exit
            if (!loader.source.toString().endsWith("HomeScreen.qml")) {
                loader.source = "./ui/features/home/screens/HomeScreen.qml";

                if (typeof bottomNavBar.currentIndex !== "undefined") {
                    bottomNavBar.currentIndex = 0;
                }
                return;
            }

            // if already on Home quit
            Qt.quit();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Loader {
            id: loader
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: "./ui/features/home/screens/HomeScreen.qml"
        }
        FooterComponent {
            id: bottomNavBar
            Layout.fillWidth: true
            Layout.preferredHeight: 65

            //signals
            onHomeTapped: loader.source = "./ui/features/home/screens/HomeScreen.qml"
            onPropertiesTapped: loader.source = "./ui/features/properties/screens/PropertiesScreen.qml"
            onAccountTapped: loader.source = "./ui/features/auth/pages/CreateAccountPage.qml"
            onBookingsTapped: loader.source = "./ui/features/bookings/screens/BookingsScreen.qml"
        }
    }

    MainStackview {
        id: mainStack
        anchors.fill: parent
    }
}
