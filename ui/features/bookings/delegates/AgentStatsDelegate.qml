import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../models"
import "../components"
import "../../../utils/Utils.js" as Helper
Rectangle {
    id: root
    property string bookingId: model.bookingId ?? ""
    property string houseName: model.houseName ?? "Hostel/Apartment"
    property string landlordName: model.landlordName ?? model.hostName ?? "Landlord / Agent"
    property string ownerFirstName: model.ownerFirstName ?? ""
    property string hostName: model.hostName ?? ""
    property string hostInitials: model.hostInitials ?? ""
    property string landlord: model.landlord ?? ""
    property string landlordInitials: model.landlordInitials ?? ""
    property string landlordPhone: model.landlordPhone ?? ""
    property string clientInitial: model.clientInitial ?? ""
    property string propertyId: model.propertyId ?? ""
    property string status: model.status ?? "Pending"
    readonly property string statusKey: String(status).trim().toUpperCase()
    property string clientName: model.clientName ?? "Guest"
    property string clientPhone: model.clientPhone ?? "N/A"
    property string dateRange: model.bookingDate ?? model.dateRange ?? "N/A"
    property real price: Number(model.amount ?? 0)
    property real commission: Number(model.commissionAmount ?? 0)
    property string propertyLocation: model.location ?? ""
    property string roomType: model.roomType ?? "Standard Room"
    property string roomId: model.roomId ?? ""
    property string details: model.details ?? model.roomType ?? "Standard Room"
    property string clientEmail: model.clientEmail ?? ""
    //Signals
    signal approveBooking()
    signal viewDetailsRequested(var data)

    //match status from model
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
        spacing: 10
        RowLayout{
            Rectangle{
                width: 6
                height: 6
                radius: 3
                color: "black"
            }
            BookingStatusBadge{
                status: root.status
            }
        }
        Rectangle{
            Layout.fillWidth: true
            height: 1
            radius: 2
            color: "#E2E8F0"
        }

        //Main content
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                id: leftAccent

                Layout.preferredWidth: 5
                Layout.fillHeight: true
                color: "#2563EB"
                radius: 3
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text:"Property: " + root.houseName
                    font.pixelSize: 14
                    color: "#2563EB"
                }
                RowLayout{
                    spacing: 0
                    Text {
                        text: "Client: " + root.clientName
                        font.pixelSize: 12
                        color: "#888888"
                   }
                    Item{Layout.preferredWidth: 240}
                    ToolButton{
                        icon.source: "qrc:/ui/assets/bookings/forward-icon.svg"
                        icon.width: 8
                        icon.height: 8
                        icon.color: "#616161"
                        background: null
                    }
                }
                RowLayout{
                    //spacing: 0
                    ToolButton{
                        icon.source: "qrc:/ui/assets/bookings/room-icon.svg"
                        icon.width: 14
                        icon.height: 14
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
                RowLayout{
                    spacing: 2
                    Layout.leftMargin: 10
                    Text{
                        text:qsTr("Total: ")
                        font.pointSize: 12
                        color: "#94A3B8"
                    }
                    Text {
                        text: Helper.formatCurrency(root.price)
                        font.bold: true
                        font.pixelSize: 13
                        color: "#000000"
                    }
                }
            }
        }
    }
    MouseArea{
        anchors.fill: root

        onClicked: {
            root.viewDetailsRequested({
                bookingId: root.bookingId || "",
                status: root.status || "",
                houseName: root.houseName || "",
                propertyLocation: root.propertyLocation || "124 Lakeview Drive, Sector 4",
                propertyId: root.propertyId,
                roomType: root.roomType || "2 Bedrooms",
                roomId: root.roomId || "",
                clientName: root.clientName || "John Doe",
                clientPhone: root.clientPhone || "+1 555-0192",
                clientEmail: root.clientEmail || "johndoe@example.com",
                clientInitial: root.clientInitial || "B" ,
                checkIn: root.checkIn || root.bookingDate || root.dateRange || "",
                price: root.price,
                commission: root.commission,
                landlord: root.landlord || "",
                landlordInitials: root.landlordInitials || "" ,
                landlordPhone: root.landlordPhone || ""
            })
        }
    }
}