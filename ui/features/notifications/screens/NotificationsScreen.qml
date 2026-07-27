import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
Item {
    id:notficationItemId

    Image{
        id: notificationImage
        width: 100
        height: 100
        anchors.centerIn: parent
        source: "qrc:/ui/assets/icons8-notification-24.png"
    }
}
