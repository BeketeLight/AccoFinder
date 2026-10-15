import QtQuick
import QtQuick.Controls
import "../../home/delegates"

// One saved property card. Data comes from a SavedPropertiesModel row that was
// itself copied from the shared home properties model, so nothing is fetched
// here.
Item {
    id: root

    required property string propertyId
    required property string title
    required property string location
    required property real price
    required property string imageUrl
    required property string imageUrls
    required property var amenities
    required property string status
    required property bool isVerified

    signal removeRequested(string propertyId)

    implicitHeight: 240

    PropertyCardDelegate {
        anchors.fill: parent
        propertyId: root.propertyId
        title: root.title
        location: root.location
        price: root.price
        imageUrl: root.imageUrl
        imageUrls: root.imageUrls
        amenities: root.amenities
        status: root.status
        isVerified: root.isVerified
        isInfoSectionVisible: true
        insideInfoSection: false
    }

    // Remove-from-saves button — same style as the room card.
    Rectangle {
        width: 32
        height: 32
        radius: 16
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        color: "#FFFFFF"
        border.color: "#E5E7EB"
        border.width: 1

        Image {
            anchors.centerIn: parent
            source: "qrc:/ui/assets/favorite-filled.svg"
            sourceSize.width: 18
            sourceSize.height: 18
            width: 18
            height: 18
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.removeRequested(root.propertyId)
        }
    }
}
