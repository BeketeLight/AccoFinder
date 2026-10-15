import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../components"

Rectangle {
    id: root
    property string reviewId: model.reviewId
    property int rating: model.rating
    property string comment: model.comment
    property string createdAt: model.createdAt
    property string clientId: model.clientId

    width: ListView.view ? ListView.view.width : implicitWidth
    implicitHeight: layout.implicitHeight + 24
    color: "#FFFFFF"
    radius: 8
    border.color: "#EEE"

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        RowLayout {
            StarRating {
                value: root.rating
                starSize: 16
            }
            Item {
                Layout.fillWidth: true
            }
            Text {
                text: root.createdAt
                color: "#888"
                font.pixelSize: 12
            }
        }

        Text {
            text: root.comment
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            font.pixelSize: 14
        }
    }
}
