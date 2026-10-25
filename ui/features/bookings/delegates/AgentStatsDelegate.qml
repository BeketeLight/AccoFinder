import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../models"
import "../components"
import "../../../utils/Utils.js" as Helper
Rectangle {
    id: delegateRoot
    // --- REQUIRED MODEL PROPERTIES ---
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
    //property string imageUrl: model.propertyImage ?? model.imageUrl ?? ""
    property string propertyId: model.propertyId ?? ""
    property string status: model.status ?? "Pending"
    readonly property string statusKey: String(status).trim().toUpperCase()
    property string clientName: model.clientName ?? "Guest"
    property string clientPhone: model.clientPhone ?? "N/A"
    property string dateRange: model.bookingDate ?? model.dateRange ?? "N/A"
    // Robust numeric check for price
    property real price: Number(model.amount ?? 0) // !== undefined && model.amount !== null ? model.amount.toString() : (model.price ?? "0")
    property real commission: Number(model.commissionAmount ?? 0)
    property string propertyLocation: model.location ?? ""
    property string roomType: model.roomType ?? "Standard Room"
    property string roomId: model.roomId ?? ""
    property string details: model.details ?? model.roomType ?? "Standard Room"
    property string clientEmail: model.clientEmail ?? ""
    // --- INTERACTION SIGNALS ---
    signal approveBooking()
    signal viewDetailsRequested(var data)

    // --- VISIBILITY & LAYOUT BEHAVIOR ---
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
            //Layout.alignment: Qt.AlignHCenter
            Rectangle{
                width: 6
                height: 6
                radius: 3
                color: "black"
            }
            BookingStatusBadge{
                status: delegateRoot.status
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
                    text:"Property: " + delegateRoot.houseName
                    font.pixelSize: 14
                    color: "#2563EB"
                }
                RowLayout{
                    spacing: 0
                    Text {
                        text: "Client: " + delegateRoot.clientName
                        font.pixelSize: 12
                        color: "#888888"
                   }
                    Item{Layout.preferredWidth: 240}
                    ToolButton{
                        icon.source: "qrc:/ui/assets/bookings/forward-icon.svg"
                        icon.width: 8
                        icon.height: 8
                        icon.color: "#616161"//"#64748B"
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
                        text: delegateRoot.roomType
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
                        text: Helper.formatCurrency(delegateRoot.price)
                        font.bold: true
                        font.pixelSize: 13
                        color: "#000000"
                    }
                }
            }
        }
    }
    MouseArea{
        anchors.fill: delegateRoot
        onClicked: {
            delegateRoot.viewDetailsRequested({

                bookingId: delegateRoot.bookingId || "",
                status: delegateRoot.status || "",
                houseName: delegateRoot.houseName || "",
                propertyLocation: delegateRoot.propertyLocation || "124 Lakeview Drive, Sector 4",
                propertyId: delegateRoot.propertyId,
                // propertyImage: data.propertyImage || data.imageUrl || "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=500",
                roomType: delegateRoot.roomType || "2 Bedrooms",
                roomId: delegateRoot.roomId || "",
                clientName: delegateRoot.clientName || "John Doe",
                clientPhone: delegateRoot.clientPhone || "+1 555-0192",
                clientEmail: delegateRoot.clientEmail || "johndoe@example.com",
                clientInitial: delegateRoot.clientInitial || "B" ,
                checkIn: delegateRoot.checkIn || delegateRoot.bookingDate || delegateRoot.dateRange || "",
                price: delegateRoot.price,
                commission: delegateRoot.commission,
                paymentStatus: delegateRoot.paymentStatus || "Paid",
                paymentMethod: delegateRoot.paymentMethod ?? "Credit Card (Visa ending in 4242)",
                paymentDate: delegateRoot.paymentDate || "Oct 10, 2026",
                landlord: delegateRoot.landlord || "",
                landlordInitials: delegateRoot.landlordInitials || "" ,
                landlordPhone: delegateRoot.landlordPhone || ""

            })
        }
    }
}