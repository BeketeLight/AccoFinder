import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property bool submitting: false
    property string errorText: ""

    signal submit(int rating, string comment)
    signal cancel

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: qsTr("Write a review")
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            visible: root.errorText.length > 0
            text: root.errorText
            color: "red"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ReviewForm {
            id: form
            Layout.fillWidth: true
            submitting: root.submitting
            onSubmitted: (rating, comment) => root.submit(rating, comment)
        }

        Button {
            text: qsTr("Cancel")
            onClicked: root.cancel()
        }
    }
}
