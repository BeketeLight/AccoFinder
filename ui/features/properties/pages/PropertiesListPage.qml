import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"

Page {
    id: root
    property alias model: listView.model
    signal propertyClicked(var propertyId)
    signal addPropertyRequested

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        clip: true

        delegate: PropertyDelegate {
            onPropertyClicked: root.propertyClicked(model.id)   // or model.modelData.id
        }

        ScrollBar.vertical: ScrollBar {}
    }

    // Empty state
    Label {
        anchors.centerIn: parent
        visible: listView.count === 0
        text: qsTr("No properties found")
        color: "#999"
    }
}
