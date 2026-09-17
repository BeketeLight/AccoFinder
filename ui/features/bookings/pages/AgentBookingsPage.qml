import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: agentPage

    Component.onCompleted: {
        bookingController.fetchAgentBookings()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Property Booking Requests"
            font.pixelSize: 20
            font.bold: true
            color: "#0F172A"
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true

            model: bookingController.agentBookings

            delegate: Rectangle {
                width: listView.width
                implicitHeight: 95
                radius: 10
                color: "#FFFFFF"
                border.color: "#E2E8F0"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Rectangle {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 100
                            radius: 12
                            color: "#CBD5E1"
                            clip: true

                            Image{
                                anchors.fill: parent
                                source: model.imageUrl || "https://www.google.com/url?sa=t&source=web&rct=j&url=https%3A%2F%2Fwww.instagram.com%2Fp%2FDNTE5ecsxJ0%2F&ved=0CBYQjRxqFwoTCMjSwI-c8ZYDFQAAAAAdAAAAABAK&opi=89978449"
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        Text {
                            text: modelData.houseName || "Property"
                            font.bold: true
                            font.pixelSize: 15
                        }
                        Text {
                            text: "Client: " + (modelData.clientName || "N/A") + " | " + (modelData.clientPhone || "")
                            font.pixelSize: 12
                            color: "#64748B"
                        }
                        Text {
                            text: "Status: " + modelData.status
                            font.pixelSize: 12
                            font.bold: true
                            color: modelData.status === "Pending" ? "#D97706" : (modelData.status === "Approved" ? "#16A34A" : "#E11D48")
                        }
                    }

                    // --- STATUS ACTIONS ---
                    RowLayout {
                        spacing: 8

                        Button {
                            text: "Approve"
                            visible: modelData.status === "Pending"
                            onClicked: bookingController.approveBooking(modelData.id)
                        }

                        Button {
                            text: "Reject"
                            visible: modelData.status === "Pending"
                            onClicked: bookingController.rejectBooking(modelData.id, "Declined by Landlord")
                        }

                        Button {
                            text: "Cancel"
                            visible: modelData.status === "Approved" || modelData.status === "Confirmed"
                            onClicked: bookingController.cancelBooking(modelData.id)
                        }
                    }
                }
            }
        }
    }
}