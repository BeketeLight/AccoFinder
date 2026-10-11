import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"
import "../../../components/buttons"

Item{
    id: detailsPage
    anchors.fill: parent
    implicitHeight: mainContent.implicitHeight + 32
   // color: "#F8F9FB"

    // --- DATA MODEL / PASSED PARAMETERS ---
    property bool isLoading: false

    property string bookingId: ""
    property string status: ""
    property string houseName: ""
    property string ownerFirstName: ""
    property string hostName: ""
    property string hostInitials: ""
    property string propertyImage: ""
    property string propertyLocation: ""
    property string roomType: ""

    property string clientName: ""
    property string clientPhone: ""
    property string clientEmail: ""
    property string clientInitial: ""
    property string landlord: ""
    property string landlordInitials: ""
    property string landlordPhone: ""

    property string checkIn: ""
    property real price: 0.0
    property real commission: 0.0
    property string paymentStatus: ""
    property string paymentMethod: ""
    property string paymentDate: ""

    property string createdTime: ""

    // --- SIGNALS ---
    signal contactHostRequested()
    signal viewMapRequested()

        // ------------------------------------------
        // 1. POPULATED DATA VIEW
        // ------------------------------------------
    ColumnLayout {
        id: mainContent
        width: parent.width
        spacing: 16

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        // --- HERO CARD: PROPERTY BANNER & TITLE ---
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: propertyColumn.implicitHeight + 16
            radius: 16
            color: "#FFFFFF"

            ColumnLayout {
                id: propertyColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 12

                // Top Image Banner
                Rectangle {
                    id: imageWrapper
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    radius: 16
                    clip: true

                    Image {
                        id: mainImg
                        anchors.fill: parent
                        source: detailsPage.propertyImage
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                // Property Titles
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.bottomMargin: 12
                    spacing: 4

                    Text {
                        text: detailsPage.houseName
                        font.pixelSize: 16
                        font.bold: true
                        color: "#0F172A"
                    }

                    RowLayout {
                        spacing: 0
                        ToolButton{
                            icon.source: "qrc:/ui/assets/bookings/location-icon.svg"
                            icon.height: 16
                            icon.width: 16
                            background: null
                        }
                        Text {
                            text: detailsPage.propertyLocation
                            font.pixelSize: 12
                            color: "#64748B"
                        }
                    }
                }
            }
        }
        // --- RESERVATION DETAILS CARD ---
        BookingStatusBanner{
            status: detailsPage.status
        }
        BookingsCard{
            bookingDate: detailsPage.checkIn
            roomType: detailsPage.roomType
        }
        PaymentSummaryCard{
            roomPrice: detailsPage.price
            totalAmount: detailsPage.price
            commission: detailsPage.commission
            customIconHeight: 14
            customIconWidth: 14
        }
        UserInfoCard{
            cardTitle: "Client Info"
            cardIcon: "qrc:/ui/assets/account-icon.svg"
            userName: detailsPage.clientName
            userPhone: detailsPage.clientPhone
            userInitial: detailsPage.clientInitial
        }
        UserInfoCard{
            cardTitle: "Landlord Info"
            cardIcon: "qrc:/ui/assets/bookings/landlord-icon.svg"
            userName: detailsPage.landlord
            userPhone: detailsPage.landlordPhone
            userInitial: detailsPage.landlordInitials
            custIconHeight: 16
            custIconWidth: 16
        }
        // --- APPROVE ACTION BUTTON ---
        Rectangle {
            visible: detailsPage.status === "Pending"
            Layout.fillWidth: true
            implicitHeight: 44
            radius: 22
            border.color: "#10B981"
            border.width: 1
            color: "transparent"

            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                Text {
                    text: "Approve Booking"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#10B981"
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: detailsPage.cancelBookingRequested()
            }
        }
    }
}