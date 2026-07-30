import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: headerId

    RowLayout{
        anchors.fill: parent
        spacing:20

        Label{
            id: registerId
            Text{
                Layout.leftMargin: 20
                text: qsTr("Sign in/Register")
                //Layout.alignment: Qt.AlignHCenter
                color: "black"
                font{
                    bold: true
                    pointSize: 12
                }
            }
        }
        Item{
            Layout.preferredWidth: 50
        }

        ToolButton{
            id: settings
            icon.source: "qrc:/ui/assets/settings.svg"
            icon.name: "Settings-icon"
            icon.height: 24
            icon.width: 24
            icon.color: "black"
            background: null
            padding: 0
        }

        ToolButton{
            id: notifications
            icon.source: "qrc:/ui/assets/notification.svg"
            icon.name: "Notifications-icon"
            icon.height: 24
            icon.width: 24
            icon.color: "black"
            background: null
            padding: 0
        }

    }
}
