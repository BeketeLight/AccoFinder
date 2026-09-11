import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ItemDelegate {
    id: root

    width: ListView.view ? ListView.view.width - 32 : 0
    implicitHeight: 200
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

    background: Rectangle {
        color: "white"
        radius: 16
        border.color: "#EAEFF5"
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Upper Card Info
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 12
            spacing: 12

            // Property Thumbnail Placeholder
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                radius: 12
                color: "#CBD5E1"
                clip: true

                Image {
                    anchors.fill: parent
                    source: model.imageUrl || ""
                    fillMode: Image.PreserveAspectCrop

                    // Fallback visual if image fails or path is empty
                    Rectangle {
                        anchors.fill: parent
                        color: "#E2E8F0"
                        visible: parent.status !== Image.Ready
                        Text {
                            anchors.centerIn: parent
                            text: "🏠"
                            font.pixelSize: 32
                        }
                    }
                }
            }

            // Property Details
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: model.propertyName
                        font.pixelSize: 16
                        font.bold: true
                        color: "#1E293B"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    // Status Badge
                    Rectangle {
                        implicitWidth: statusText.implicitWidth + 16
                        implicitHeight: 24
                        radius: 12
                        color: model.status === "Pending"   ? "#FFF3E0" :
                               model.status === "Confirmed" ? "#E8F5E9" : "#FFEBEE"

                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            text: model.status
                            font.pixelSize: 11
                            font.bold: true
                            color: model.status === "Pending"   ? "#E65100" :
                                   model.status === "Confirmed" ? "#2E7D32" : "#C62828"
                        }
                    }
                }

                Text { text: "📍  " + model.location; color: "#64748B"; font.pixelSize: 12 }
                Text { text: "📅  " + model.bookingDate; color: "#64748B"; font.pixelSize: 12 }
                Text { text: "👤  " + model.guests; color: "#64748B"; font.pixelSize: 12 }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#F1F5F9"
        }

        // Bottom Host Confirmation Note
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            Layout.preferredHeight: 40

            Text {
                text: "🕒  " + model.statusNote
                color: "#64748B"
                font.pixelSize: 12
            }
            Item { Layout.fillWidth: true }
            Text { text: "›"; color: "#64748B"; font.pixelSize: 20; font.bold: true }
        }
    }
}