import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../../../utils/ImageUtils.js" as CachedImage
import "../../../utils/Utils.js" as Formator
Item {
    id: root

    anchors.fill: parent
    implicitHeight: mainContent.implicitHeight + 32
    property bool isLoading: false

    property string bookingId: ""
    property string status: ""
    property string houseName: ""
    property string ownerFirstName: ""
    property string landlord: ""
    property string landlordPhone: ""
    property string landlordInitials: ""
    property string hostName: ""
    property string hostInitials: ""
    property string hostEmail: ""
    property string hostPhone: ""
    readonly property string propertyImage: cachImage.propertyImage
    property string propertyLocation: ""
    property string propertyId: ""
    property string roomType: ""
    property string roomId: ""
    property string clientName: ""
    property string clientPhone: ""
    property string clientEmail: ""
    property string clientInitial: ""
    property string paymentStatus: ""
    property string paymentMethod: ""
    property string paymentDate: ""
    property string bookingDate: ""
    property real price: 0.0
    property real commission: 0.0
    property int guestCount: 0
    property int tick: 0

    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color pageColor: "#FFFFFF"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

    // --- SIGNALS ---
    signal backRequested()
    signal cancelBookingRequested()
    signal contactHostRequested()
    signal payNowRequested(string bookingId, real amount, var holdExpiresAt)

    //Component used to get image using
    //propertyId and roomId
    BookingCachImage{
        id: cachImage
        propertyId: root.propertyId
        roomId: root.roomId
    }

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
                    Layout.preferredHeight: 200
                    radius: 16
                    clip: true

                    Image {
                        id: mainImg
                        anchors.fill: parent
                        source: CachedImage.cachedSource(root.propertyImage)
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
                        text: root.houseName
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
                            text: root.propertyLocation
                            font.pixelSize: 12
                            color: "#64748B"
                        }
                    }
                }
            }
        }
        // --- RESERVATION DETAILS CARD ---
        BookingStatusBanner{
            status: root.status
        }
        BookingsCard{
            bookingDate: root.bookingDate
            roomType: root.roomType
        }
        PaymentSummaryCard{
            roomPrice: Formator.formatCurrency(root.price)
            totalAmount: Formator.formatCurrency(root.price)
            commission: Formator.formatCurrency(root.commission)
            customIconHeight: 14
            customIconWidth: 14
        }
        UserInfoCard{
            cardTitle: "Client Info"
            cardIcon: "qrc:/ui/assets/account-icon.svg"
            userName: root.clientName
            userPhone: root.clientPhone
            userEmail: root.clientEmail
            emailIcon: "qrc:/ui/assets/bookings/email-icon.svg"
            userInitial: root.clientInitial
        }
        UserInfoCard{
            userName: root.hostName
            cardTitle: "Agent Info"
            userInitial: root.hostInitials
            userPhone: root.hostPhone
            userEmail: root.hostEmail
            emailIcon: "qrc:/ui/assets/bookings/email-icon.svg"
        }
        UserInfoCard{
            cardTitle: "Landlord Info"
            cardIcon: "qrc:/ui/assets/bookings/landlord-icon.svg"
            userName: root.landlord
            userPhone: root.landlordPhone
            userInitial: root.landlordInitials
            userEmail: ""
            custIconHeight: 16
            custIconWidth: 16
        }
    }
}
