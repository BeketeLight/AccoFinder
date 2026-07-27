import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule
Page{
    id:homePageId

    header:ToolBar{
        background: Rectangle{
            color: "white"
        }
        RowLayout{
            anchors.fill: parent
            Button{
                id:searchbarId
                implicitHeight: 40
                Layout.preferredWidth: 300
                Text{
                    anchors.centerIn: parent
                    text: qsTr("My Bookings")
                    font{
                        pointSize: 24
                        bold: true
                    }

                }
                background: Rectangle{
                    color: "white"
                    radius: 10
                }

            }

            Image{
                id:notifications
                fillMode: Image.PreserveAspectFit
                source: "qrc:/ui/assets/notification.png"
                width: 24
                height: 24
                MouseArea{
                    anchors.fill: parent
                    onClicked: UtilsModule.NavigationUtils.navigateToNotifications()
                }
            }
        }
    }

    contentItem:ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        RowLayout {
            Button { text: "Completed" }
            Button { text: "Cancelled" }
        }
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
