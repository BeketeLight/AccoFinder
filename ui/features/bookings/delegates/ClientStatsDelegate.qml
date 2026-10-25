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
    property string roomId: model.roomId ?? ""
    property string propertyId: model.propertyId ?? ""
    property string status: model.status ?? "Pending"
    readonly property string statusKey: String(status).trim().toUpperCase()
    property string clientName: model.clientName ?? "Guest"
    property string clientPhone: model.clientPhone ?? "N/A"
    property string bookingDate: model.bookingDate ?? model.bookingDate ?? "N/A"
    //Expires at details
    property string holdExpiresAt: model.holdExpiresAt ?? ""
    property bool holdActive: model.holdActive === true || model.holdActive === 1
    property int tick: 0
    // Robust numeric check for price
    property real price: Number(model.amount ?? 0)
    property string propertyLocation: model.propertyLocation ?? ""
    property string roomType: model.roomType ?? "Standard Room"
    property string details: model.details ?? model.roomType ?? "Standard Room"
    property string clientEmail: model.clientEmail ?? ""

    property double baseAmount: model.amount ?? 0.0
    property double serviceFee: model.commissionAmount ?? 0.0
    property double totalAmount: baseAmount + serviceFee
    //colors
    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color pageColor: "#FFFFFF"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"
    // --- ACTIVE FILTER PROP (FOR INLINE LISTVIEW FILTERING) ---
    //property string activeFilter: "All"

    // --- INTERACTION SIGNALS ---
    signal removeRequested()
    signal viewDetailsRequested(var data)
    signal payNowRequested(string bookingId, real amount, var holdExpiresAt)

    // --- VISIBILITY & LAYOUT BEHAVIOR ---
    // visible: activeFilter === "All" || status === activeFilter
    visible: model.matches ?? true
    width: ListView.view ? ListView.view.width : parent.width
    implicitHeight: visible ? cardContent.implicitHeight + 24 : 0
    color: "#FFFFFF"
    radius: 8
    border.color: "#E2E8F0"
    border.width: 1
    Timer {
        interval: 1000
        running: delegateRoot.visible && delegateRoot.canPay
        repeat: true
        onTriggered: delegateRoot.tick++
    }
     readonly property string holdCountdownText: {
        var _ = tick
        // return .holdCountdownText(holdExpiresAt)
        return Helper.holdCountdownText(delegateRoot.status, holdExpiresAt)
     }

     readonly property bool canPay: {
        var _ = tick
        return Helper.canPayBooking(status, holdExpiresAt)
     }

     readonly property bool showHoldActions: {
        var _ = tick
        return Helper.canPayBooking(status, holdExpiresAt)
     }
    ColumnLayout {
        id: cardContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 6
        z:1
        RowLayout{
            //Layout.alignment: Qt.AlignHCenter
            Rectangle{
                width: 6
                height: 6
                radius: 3
                color: "#BDBDBD"//"#E2E8F0"
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
        // --- 3. MAIN CONTENT: THUMBNAIL & PROPERTY INFO ---
        // Blue accent line on the left side of the booking card

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Rectangle {
                id: leftAccent

                Layout.preferredWidth: 5
                Layout.fillHeight: true
                color: "#2563EB"
                radius: 3
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text:"Property: " + delegateRoot.houseName
                    font.pixelSize: 14
                    color: "#2563EB"
                }
                RowLayout{
                    spacing: 0
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
                    Item{Layout.preferredWidth: 200}
                    ToolButton{
                        icon.source: "qrc:/ui/assets/bookings/forward-icon.svg"
                        icon.width: 8
                        icon.height: 8
                        icon.color: "#616161"
                        background: null
                    }
                }
                RowLayout{
                    ToolButton{
                        icon.source: "qrc:/ui/assets/bookings/location-icon.svg"
                        icon.width: 14
                        icon.height: 14
                        icon.color:"#000000"//"#64748B"
                        background: null
                    }
                    Text {
                        text: delegateRoot.propertyLocation
                        font.pixelSize: 11
                        color: "#94A3B8"
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
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#F1F5F9"; visible:  holdCountdownText.length > 0}
        CustomButton{
            id: payBtn
            text: qsTr("Pay now")
            textColor: "#FFFFFF"
            cornerRadius: 12
            visible: holdCountdownText.length > 0
            Layout.preferredWidth: cardContent.implicitWidth - 8
            implicitHeight: 50
            buttonColor: delegateRoot.primaryColor
            onClicked: {
                console.log("Pay now", delegateRoot.bookingId, delegateRoot.price, delegateRoot.holdExpiresAt)
                delegateRoot.payNowRequested(
                    delegateRoot.bookingId,
                    Number(delegateRoot.price),
                    delegateRoot.holdExpiresAt
                )
            }
        }
    }

    MouseArea {
        anchors.fill: cardContent
        z: 0

        onClicked: {
            delegateRoot.viewDetailsRequested({
                bookingId: delegateRoot.bookingId,
                roomId: delegateRoot.roomId,
                propertyId: delegateRoot.propertyId,
                status: delegateRoot.status,
                houseName: delegateRoot.houseName,
                ownerFirstName: delegateRoot.ownerFirstName,
                hostName: delegateRoot.hostName,
                hostInitials: delegateRoot.hostInitials,
                propertyLocation: delegateRoot.propertyLocation,
                roomType: delegateRoot.roomType,
                bookingDate: delegateRoot.bookingDate,
                price: delegateRoot.price,
                clientName: delegateRoot.clientName,
                clientPhone: delegateRoot.clientPhone,
                clientEmail: delegateRoot.clientEmail,
                paymentStatus: delegateRoot.paymentStatus,
                paymentMethod: delegateRoot.paymentMethod,
                paymentDate: delegateRoot.paymentDate,
                holdExpiresAt: delegateRoot.holdExpiresAt
            })
        }
    }
}