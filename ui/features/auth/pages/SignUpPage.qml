import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule

Page{
    id:signInPageId
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

                Item { Layout.fillWidth: true }  // Spacer
            }
        }

    ColumnLayout{
        anchors.centerIn: parent
        width: parent.width * 0.85
        spacing: 20
        // Layout.preferredWidth: 680

        Label{
            text: "Sign Up"
            font{
                pointSize: 24
                bold: true
            }
            Layout.alignment: Qt.AlignHCenter
        }
        Item{
            Layout.preferredHeight: 50
        }


        TextField{
            id: name
            placeholderText: "Email"
            Layout.fillWidth: true

        }

        TextField{
            id: email
            placeholderText: "Email"
            Layout.fillWidth: true
        }
        TextField{
            id: residenttialAddress
            placeholderText: "Residential address"
            Layout.fillWidth: true
        }
        Button{
            id: signinButtonId
            text: "SIGN UP"
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            background: Rectangle{
                color: "#2563EB"
                radius: 10
            }
        }
    }

}
