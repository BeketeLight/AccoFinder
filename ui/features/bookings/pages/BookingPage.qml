import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule
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
    footer: ToolBar{
        background: Rectangle{
            color: "white"
        }
        RowLayout{
            anchors.fill: parent
            ToolButton{
                id:homeId
                contentItem: ColumnLayout{
                    Image {
                        id: home
                        width: 16
                        height: 16
                        source: "qrc:/ui/assets/home.png"
                        fillMode: Image.PreserveAspectFit
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label{
                        Text{
                            anchors.centerIn: parent
                            text:qsTr("Home")
                            color: "black"
                        }
                        Layout.alignment: Qt.AlignHCenter
                        font{
                            pointSize: 12
                            bold:true
                        }

                    }
                }
                onClicked: {
                    UtilsModule.NavigationUtils.navigateToNotifications()
                }
            }
            ToolButton{
                id:propertyId
                contentItem: ColumnLayout{
                    Image {
                        id: property
                        width: 24
                        height: 24
                        source: "qrc:/ui/assets/property.png"
                        fillMode: Image.PreserveAspectFit
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label{
                        Text{
                            anchors.centerIn: parent
                            text:qsTr("Properties")
                            color: "black"
                        }
                        Layout.alignment: Qt.AlignHCenter
                        font{
                            pointSize: 12
                            bold:true
                        }

                    }

                }
                onClicked: {
                    UtilsModule.NavigationUtils.navigateToProperties()
                }

            }
            ToolButton{
                id:bookingId
                contentItem: ColumnLayout{
                    Image {
                        id: bookings
                        width: 24
                        height: 24
                        source: "qrc:/ui/assets/booking.png"
                        fillMode: Image.PreserveAspectFit
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label{
                        Text{
                            anchors.centerIn: parent
                            text:qsTr("Bookings")
                            color: "black"
                        }
                        Layout.alignment: Qt.AlignHCenter
                        font{
                            pointSize: 12
                            bold: true
                        }

                    }
                }
            }
            ToolButton{
                id:acountId
                contentItem: ColumnLayout{
                    Image {
                        id: account
                        width: 24
                        height: 24
                        source: "qrc:/ui/assets/account.png"
                        fillMode: Image.PreserveAspectFit
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label{
                        Text{
                            anchors.centerIn: parent
                            text:qsTr("Account")
                            color: "black"

                        }
                        Layout.alignment: Qt.AlignHCenter
                        font{
                            pointSize: 12
                            bold:true
                        }

                    }
                }
                onClicked: {
                    UtilsModule.NavigationUtils.navigateToSignIn()
                }
            }

        }

    }

}
