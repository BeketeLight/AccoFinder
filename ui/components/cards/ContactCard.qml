import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Compact contact card: shows one person (title + name + phone) with an
// optional Call button. Used wherever a property lists its owner/submitter
// ("Listed by") and landlord side by side (agent dashboard, admin all
// properties, admin approval review…).
Rectangle {
    id: root

    property string title: ""
    property string name: ""
    property string phone: ""
    property color accentColor: "#2563EB"

    signal callRequested(string number)

    Layout.fillWidth: true
    implicitHeight: cardRow.implicitHeight + 26
    radius: 12
    color: "#FFFFFF"
    border.color: "#E5E7EB"
    border.width: 1

    RowLayout {
        id: cardRow
        anchors.fill: parent
        anchors.margins: 13
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            radius: 21
            color: "#EFF6FF"

            Label {
                anchors.centerIn: parent
                text: root.name.length > 0 ? root.name.charAt(0).toUpperCase() : "?"
                color: root.accentColor
                font.pixelSize: 18
                font.bold: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Label {
                text: root.title
                color: "#6B7280"
                font.pixelSize: 10
                font.bold: true
            }

            Label {
                Layout.fillWidth: true
                text: root.name.length > 0 ? root.name : qsTr("Not provided")
                color: "#1F2937"
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true
                visible: root.phone.length > 0
                text: root.phone
                color: "#6B7280"
                font.pixelSize: 12
            }
        }

        Button {
            id: callButton
            visible: root.phone.length > 0
            Layout.preferredHeight: 34
            Layout.preferredWidth: 72
            text: qsTr("Call")

            contentItem: Label {
                text: callButton.text
                color: root.accentColor
                font.pixelSize: 11
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 17
                color: callButton.down ? "#EFF6FF" : "transparent"
                border.color: root.accentColor
                border.width: 1
            }

            onClicked: root.callRequested(root.phone)
        }
    }
}