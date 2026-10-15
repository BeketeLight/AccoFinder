import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

Rectangle {
    id: root
    property string bookingId: model.bookingId ?? ""
    property string houseName: model.houseName ?? "Hostel/Apartment"
    property string ownerFirstName: model.ownerFirstName ?? ""
    property string landlord: model.landlord ?? ""
    property string landlordInitials: model.landlordInitials ?? ""
    property string landlordPhone: model.landlordPhone ?? ""
    property string hostName: model.hostName ?? ""
    property string hostInitials: model.hostInitials ?? ""
    property string hostEmail: model.hostEmail ?? ""
    property string hostPhone: model.hostPhone ?? ""
    property string propertyImage: model.propertyImage ?? model.imageUrl ?? ""
    property string status: model.status ?? "Pending"
    property string clientName: model.clientName ?? "Guest"
    property string clientPhone: model.clientPhone ?? "N/A"
    property string clientEmail: model.clientEmail ?? ""
    property string clientInitial: model.clientInitial ?? ""
    property string bookingDate: model.bookingDate ?? model.dateRange ?? "Date"
    property string propertyLocation: model.propertyLocation ?? ""
    property string roomType: model.roomType ?? "Standard Room"
    property string details: model.details ?? model.roomType ?? "Standard Room"
    property real price: Number(model.amount ?? 0) // !== undefined && model.amount !== null ? model.amount.toString() : (model.price ?? "0")
    property real commission: Number(model.commissionAmount ?? 0)



    //Signals
    signal approveBooking()
    signal viewDetailsRequested(var data)

    //Status match
    visible: model.matches ?? true
    width: ListView.view ? ListView.view.width : parent.width
    implicitHeight: visible ? cardContent.implicitHeight + 16 : 0
    color: "#FFFFFF"
    radius: 8
    border.color: "#E2E8F0"
    border.width: 1

    ColumnLayout {
        id: cardContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 12
        RowLayout{
            Text {
                text: root.bookingId
                font.pixelSize: 13
                font.bold: true
                color: "#0F172A"
            }
            Item{Layout.fillWidth: true}
            RowLayout{
                Rectangle{
                    width: 6
                    height: 6
                    radius: 3
                    color: "#BDBDBD"//"#E2E8F0"
                }
                BookingStatusBadge{
                    status: root.status
                }
            }
        }
        Rectangle{
            Layout.fillWidth: true
            height: 1
            radius: 2
            color: "#E2E8F0"
        }

        RowLayout{
            Layout.fillWidth: true
            spacing: 6
            // Image

            Rectangle {
                id: imageContainer
                Layout.preferredWidth: 118
                Layout.preferredHeight: 118
                radius: 10
                color: "#F0F0F0"
                clip: true

                Image {
                    id: propImage
                    anchors.fill: parent
                    source: root.propertyImage !== "" ? root.propertyImage : "qrc:/assets/placeholder.png"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                }
                MultiEffect {
                    anchors.fill: propImage
                    source: propImage
                    maskEnabled: true
                    maskThresholdMin: 0.5

                    maskSource: ShaderEffectSource {
                        sourceItem: Rectangle {
                            width: imageContainer.width
                            height: imageContainer.height
                            radius: imageContainer.radius
                            color: "black"
                        }
                    }
                }
            }

            //  id, house, location, client, host, room
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Text {
                    text: root.houseName
                    font.pixelSize: 12
                    color: "#334155"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: "Booked: " + root.bookingDate
                    font.pixelSize: 11
                    color: "#64748B"
                }
                RowLayout{
                    spacing: 0

                    RowLayout{
                        ToolButton{
                            icon.source: "qrc:/ui/assets/bookings/location-icon.svg"
                            icon.width: 10
                            icon.height: 10
                            icon.color:"#000000"//"#64748B"
                            background: null
                        }
                        Text {
                            text: root.propertyLocation
                            font.pixelSize: 11
                            color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                    }
                    Item{Layout.preferredWidth: 145}
                    ToolButton{
                        icon.source: "qrc:/ui/assets/bookings/forward-icon.svg"
                        icon.width: 8
                        icon.height: 8
                        icon.color:"#64748B"
                        background: null
                    }
                }
                Text {
                    text: "Client: " + root.clientName
                    font.pixelSize: 12
                    color: "#94A3B8"
                }

                Text {
                    text: "Agent: " + root.hostName
                    font.pixelSize: 11
                    color: "#94A3B8"
                }
                RowLayout{
                    //spacing: 0
                    ToolButton{
                        icon.source: "qrc:/ui/assets/bookings/room-icon.svg"
                        icon.width: 10
                        icon.height: 10
                        icon.color:"#000000"
                        background: null
                    }
                    Text {
                        text: root.roomType
                        font.pixelSize: 11
                        color: "#94A3B8"
                        //elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.viewDetailsRequested(data)
    }
}