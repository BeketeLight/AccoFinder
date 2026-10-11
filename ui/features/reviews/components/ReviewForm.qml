import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root

    property int rating: 0
    property string comment: ""
    property bool submitting: false

    signal submitted(int rating, string comment)

    spacing: 12

    Text {
        text: qsTr("Your rating")
        font.bold: true
    }

    StarInput {
        id: stars
        value: root.rating
        onValueEdited: root.rating = newValue
    }

    Text {
        text: qsTr("Your review")
        font.bold: true
    }

    ScrollView {
        Layout.fillWidth: true
        Layout.preferredHeight: 140

        TextArea {
            id: commentArea
            placeholderText: qsTr("Tell others about your stay…")
            wrapMode: TextArea.Wrap
            text: root.comment
            onTextChanged: root.comment = text
        }
    }

    Button {
        Layout.alignment: Qt.AlignRight
        text: qsTr("Submit review")
        enabled: root.rating >= 1 && root.comment.trim().length > 0 && !root.submitting
        onClicked: root.submitted(root.rating, root.comment)
    }
}
