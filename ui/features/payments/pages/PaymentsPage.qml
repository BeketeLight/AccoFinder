import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule

Page {
    id: signInPage
    anchors.fill: parent

    // ===== HEADER WITH BACK BUTTON =====
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

            Item { Layout.fillWidth: true }
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
                text: "Payment summary"
                font.pixelSize: 16
                font.bold: true
            }
            Item {
                Layout.preferredHeight: 20
            }
            Label {
                text: "Total: MK 85,000 / month"
                color: "blue"
                font.bold: true
                font.pixelSize: 18
            }
            RowLayout{
                spacing: 10
                Layout.fillHeight: true
                Layout.fillWidth: true

                Label {
                    text: "MK 85,000 "
                    color: "red"
                    font.bold: true
                    font.pixelSize: 12
                }
                Button {
                    text: "Pay now"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    background: Rectangle{
                        color: "#2563EB"
                        radius: 10
                    }
                     onClicked: UtilsModule.NavigationUtils.navigateToPaymentStatus()
                }
            }

        }
    }
}