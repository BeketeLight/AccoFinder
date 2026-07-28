import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/inputs"

ColumnLayout {
    width: parent ? parent.width : implicitWidth
    spacing: 20
    RowLayout {
        Label {
            text: "AccoFinder"
            Layout.topMargin: 15
            Layout.leftMargin: 10
            font.pixelSize: 15
            font.bold: true
        }
        // Flexible spacer – takes all remaining space

        Item {
            Layout.fillWidth: true
        }

        //here this label will be replaced with notification icon or image
        Label {
            text: "Noti"
            Layout.topMargin: 15
            Layout.rightMargin: 10
        }
    }

    SearchBar {
        Layout.alignment: Qt.AlignHCenter
    }

    // RowLayout {
    //     spacing: 5
    //     Label {
    //         text: "New Feeds"
    //     }

    //     Label {
    //         text: "Explore"
    //     }
    //     Label {
    //         text: "Recent"
    //     }
    // }
    // Image {
    //     id: notifications
    //     fillMode: Image.PreserveAspectFit
    //     source: "ui/assets/notification.svg"
    //     width: 48
    //     height: 48
    //     MouseArea {
    //         anchors.fill: parent
    //         onClicked: UtilsModule.NavigationUtils.navigateToNotifications()
    //     }
    //     Layout.rightMargin: 20
    // }
}
