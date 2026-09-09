import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../utils/Utils.js" as Utils

Rectangle {
    id: root

    property string propertyId: ""
    property string title: ""
    property string district: ""
    property string village: ""
    property real price: 0
    property string landlord: ""

    property color successColor: "#16A34A"
    property color primaryColor: "#2563EB"

    signal reviewRequested(var propertyId)
    signal approveRequested(var propertyId, var title)
    signal rejectRequested(var propertyId, var title)

    Layout.fillWidth: true
    implicitHeight: approvalContent.implicitHeight + 20
    radius: 12
    color: "#FFFFFF"
    border.color: "#E5E7EB"
    border.width: 1

    ColumnLayout {
        id: approvalContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 8

        Label {
            Layout.fillWidth: true
            text: root.title
            color: "#111827"
            font.pixelSize: 14
            font.bold: true
            elide: Text.ElideRight
        }

        Label {
            Layout.fillWidth: true
            text: root.district + " · " + root.village
                  + " · " + Utils.formatCurrency(root.price) + "/mo"
            color: "#6B7280"
            font.pixelSize: 11
            elide: Text.ElideRight
        }

        Label {
            Layout.fillWidth: true
            text: qsTr("Landlord: %1").arg(root.landlord)
            color: "#6B7280"
            font.pixelSize: 11
            elide: Text.ElideRight
        }

        Button {
            id: reviewButton
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            text: qsTr("Review & decide")

            contentItem: Label {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: reviewButton.text
                color: root.primaryColor
                font.pixelSize: 12
                font.bold: true
            }

            background: Rectangle {
                radius: 19
                color: reviewButton.down ? "#DBEAFE" : "#EFF6FF"
                border.color: "#BFDBFE"
                border.width: 1
            }

            onClicked: root.reviewRequested(root.propertyId)
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                id: approveButton
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                text: qsTr("Approve")

                contentItem: Label {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: approveButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    font.bold: true
                }

                background: Rectangle {
                    radius: 18
                    color: approveButton.down ? "#15803D" : root.successColor
                }

                onClicked: root.approveRequested(root.propertyId, root.title)
            }

            Button {
                id: rejectButton
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                text: qsTr("Reject")

                contentItem: Label {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: rejectButton.text
                    color: "#B91C1C"
                    font.pixelSize: 12
                    font.bold: true
                }

                background: Rectangle {
                    radius: 18
                    color: rejectButton.down ? "#FEE2E2" : "#FEF2F2"
                    border.color: "#FECACA"
                    border.width: 1
                }

                onClicked: root.rejectRequested(root.propertyId, root.title)
            }
        }
    }
}