import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.VectorImage
import "../../../components/inputs"
import "../../../utils" as UtilsModule
Page{
    id:homePageId

    header: RowLayout{
        //anchors.fill: parent

        SearchBar{
            Layout.preferredWidth: 280
            Layout.leftMargin: 20
        }
        Rectangle{
            width: 300
            height: 50
            color: "blue"
            VectorImage{
                    id:notifications
                    fillMode: Image.PreserveAspectFit
                    source: "ui/assets/home.svg"
                    width: 48
                    height: 48
                    MouseArea{
                        anchors.fill: parent
                        onClicked: UtilsModule.NavigationUtils.navigateToNotifications()
                }
                    Layout.rightMargin: 20
             }
        }

    }
    //     background: Rectangle{
    //         color: "white"
    //     }
    //     RowLayout{
    //         anchors.fill: parent
    //         TextField{
    //             id:searchbarId
    //             implicitHeight: 40
    //             Layout.preferredWidth: 300
    //             placeholderText: qsTr("Search here..")
    //             color: "#1e1e1e"
    //             background: Rectangle{
    //                 color: "#e1e1e1"
    //                 radius: 10
    //             }
    //             Image {
    //                 id:searchIcon
    //                 anchors{
    //                     right: parent.right
    //                     rightMargin: 15
    //                     verticalCenter: parent.verticalCenter
    //                 }
    //                 source: "qrc:/ui/assets/search.png"
    //                 width: 20
    //                 height: 20
    //                 fillMode: Image.PreserveAspectFit
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

    footer: ToolBar{
        background: Rectangle{
            color: "white"
        }
        RowLayout{
            anchors.fill: parent
            ToolButton{
                id:homeId
                contentItem: ColumnLayout{
                    // Image {
                    //     id: home
                    //     width: 16
                    //     height: 16
                    //     source: "/ui/assets/home.png"
                    //     fillMode: Image.PreserveAspectFit
                    //     Layout.alignment: Qt.AlignHCenter
                    // }
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
                onClicked: {
                    UtilsModule.NavigationUtils.navigateToBookings()
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
