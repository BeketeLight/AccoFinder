import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule
Page{
    id: propertiesDetailsId
    anchors.fill: parent

    header: ToolBar {
        background: Rectangle {
            color: "white"
        }

        contentHeight: 56

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16

            // Back Button
            ToolButton {

                Image {
                    id: home
                    width: 24
                    height: 24
                    source: "qrc:/ui/assets/back.png"
                    fillMode: Image.PreserveAspectFit
                    Layout.alignment: Qt.AlignHCenter

                    MouseArea{
                        anchors.fill: parent
                        onClicked: UtilsModule.NavigationUtils.pop()
                    }
                }
                onClicked: UtilsModule.NavigationUtils.pop()
            }

            Item { Layout.fillWidth: true }  // Spacer
        }
    }

        ScrollView {
            anchors.fill: parent

            ColumnLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                     right: parent.right
                    topMargin: 40
                    leftMargin: 24
                    rightMargin: 24
                }


                Label {
                    text: "Sunset Apartments"
                    font.pixelSize: 22
                    font.bold: true
                }
                Label {
                    text: "Zomba, Chikanda"
                }

                Label {
                    text: "MK 85,000 / month"
                    color: "blue"
                    font.bold: true
                    font.pixelSize: 18
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#dddddd"
                }

                Label {
                    text: "Description"
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: "Modern three-bedroom house with spacious rooms and its fenced."
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#dddddd"
                }

                Label {
                    text: "Features"
                    font.bold: true
                }

                GridLayout {
                    columns: 2

                    Label { text: "🛏 Bedrooms" }
                    Label { text: "3" }

                    Label { text: "🛁 Bathrooms" }
                    Label { text: "2" }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#dddddd"
                }

                Label {
                    text: "Owner"
                    font.bold: true
                }

                Label { text: "BRYAN" }
                Label { text: "+265 999 123 456" }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#dddddd"
                }

                Button {
                    text: "BOOK NOW"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    background: Rectangle{
                        color: "#2563EB"
                        radius: 10
                    }
                    onClicked: UtilsModule.NavigationUtils.navigateToPayments()
                }
            }
        }

}
