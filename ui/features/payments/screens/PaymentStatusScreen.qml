import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../../../utils" as UtilsModule

Page {
    id: signInPage
    //anchors.fill: parent
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
            text: "Payment status"
            font.pixelSize: 22
            font.bold: true
        }
    }
}