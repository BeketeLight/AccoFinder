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
            font.pixelSize: 25
            font.bold: true
        }


        Item {
            Layout.fillWidth: true
        }

        //here this label will be replaced with notification icon or image
        Image {
            id: notifications
            //fillMode: Image.PreserveAspectFit
            source: "qrc:/ui/assets/notification.svg"
            // 1. Force the size the layout will see
            // width: 24
            // height: 24
            // or if inside a Layout:
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.maximumWidth: 24
            Layout.maximumHeight: 24

            // 2. Control how the SVG is rasterized (very important for quality + size)
            sourceSize.width: 48          // 2× for retina / high-DPI
            sourceSize.height: 48

            fillMode: Image.PreserveAspectFit
            antialiasing: true
            smooth: true
            MouseArea {
                anchors.fill: parent
                onClicked: UtilsModule.NavigationUtils.navigateToNotifications()
            }
            Layout.topMargin: 15
            Layout.rightMargin: 10
        }
    }

    AppSearchBar {
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
}
