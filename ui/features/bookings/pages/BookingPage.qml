import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule
import "../../home/components"
Page{
    id:homePageId
    anchors.fill: parent
    // header:ToolBar{
    //     background: Rectangle{
    //         color: "white"
    //     }
    //     RowLayout{
    //         anchors.fill: parent
    //         Button{
    //             id:searchbarId
    //             implicitHeight: 40
    //             Layout.preferredWidth: 300
    //             Text{
    //                 text: qsTr("My Bookings")
    //                 font{
    //                     pointSize: 18
    //                     bold: true
    //                 }

    //             }
    //             background: Rectangle{
    //                 color: "white"
    //                 radius: 10
    //             }

    //         }

    //         Image{
    //             id:notifications
    //             fillMode: Image.PreserveAspectFit
    //             source: "qrc:/ui/assets/notification.png"
    //             width: 24
    //             height: 24
    //             MouseArea{
    //                 anchors.fill: parent
    //                 onClicked: UtilsModule.NavigationUtils.navigateToNotifications()
    //             }
    //         }
    //     }
    // }
    header: ToolBar {
        background: Rectangle {
            color: "white"
        }

        contentHeight: 20

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16

            // Back Button
            ToolButton {

                // Image {
                //     id: home
                //     width: 24
                //     height: 24
                //     source: "qrc:/ui/assets/back.png"
                //     fillMode: Image.PreserveAspectFit
                //     Layout.alignment: Qt.AlignHCenter

                //     MouseArea{
                //         anchors.fill: parent
                //         onClicked: UtilsModule.NavigationUtils.pop()
                //     }
                // }
                Label{
                    text: "My Bookings"
                    font{
                        bold: true
                        pointSize: 24
                    }
                    color: "black"
                    MouseArea{
                        anchors.fill: parent
                    }
                }

                onClicked: UtilsModule.NavigationUtils.pop()
            }

            Item { Layout.fillWidth: true }  // Spacer
        }
    }


    RowLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 40
            leftMargin: 10
            rightMargin: 0
        }
        spacing: 20

        Label {
            text: "Completed"
            font.pixelSize: 16
            font.bold: true
            color: "#1a1a1a"
            //Layout.fillWidth: true
        }

        Label {
            text: "Cancelled"
            font.pixelSize: 16
            font.bold: true
            color: "#1a1a1a"
            Layout.fillWidth: true
        }

        // TextField{
        //     id: email
        //     placeholderText: "Email"
        //     Layout.fillWidth: true

        // }

        // TextField{
        //     id: password
        //     placeholderText: "Password"
        //     Layout.fillWidth: true
        // }
        // Button{
        //     id: signinButtonId
        //     text: "SIGN IN"
        //     Layout.fillWidth: true
        //     Layout.preferredHeight: 50
        //     background: Rectangle{
        //         color: "#2563EB"
        //         radius: 10
        //     }
        // }
        // Item{
        //     Layout.preferredHeight: 40
        // }
        // Label{
        //     text: "Sign Up"
        //     color: "#2563EB"
        //     font{
        //         pointSize: 12
        //         bold: true
        //     }
        //     Layout.alignment: Qt.AlignHCenter
        //     MouseArea{
        //         anchors.fill: parent
        //         onClicked: UtilsModule.NavigationUtils.navigateToSignUp()
        //     }
        // }

        // ... rest of your phone input + buttons
    }
    footer: FooterComponent{

    }


}
