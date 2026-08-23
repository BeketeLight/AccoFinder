import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ItemDelegate {
    id: root
    width: ListView.view.width
    height: 140

    required property var model          // or the roles if you use roleNames
    // required property string title
    // required property string location
    // required property real price
    // etc.

    signal propertyClicked
    signal favoriteToggled

    background: Rectangle {
        color: root.highlighted ? "#f0f4ff" : "white"
        radius: 12
        border.color: "#e0e0e0"
    }

    contentItem: RowLayout {
        spacing: 16
        anchors.margins: 12

        // Image placeholder
        Rectangle {
            width: 110
            height: 110
            radius: 8
            color: "#eee"
            // Image { source: model.imageUrl; ... }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                text: model.title
                font.bold: true
                font.pixelSize: 16
                elide: Text.ElideRight
            }
            Label {
                text: model.location
                color: "#666"
                font.pixelSize: 13
            }
            Label {
                text: qsTr("%1 / month").arg(model.price.toFixed(0))
                font.pixelSize: 15
                color: "#1a73e8"
            }
            // Status chip, agent name, etc.
        }
    }

    onClicked: root.propertyClicked()
}
