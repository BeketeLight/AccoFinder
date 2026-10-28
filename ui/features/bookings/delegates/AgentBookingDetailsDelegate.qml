import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"
import "../../../components/buttons"
import "../../../utils/ImageUtils.js" as CachedImage
import "../../../utils/Utils.js" as Formator

Item{
    id: root
    anchors.fill: parent
    implicitHeight: mainContent.implicitHeight + 32
    property bool isLoading: false

    property string bookingId: ""
    property string status: ""
    property string houseName: ""
    property string ownerFirstName: ""
    property string hostName: ""
    property string hostInitials: ""
    readonly property string propertyImage: cachImage.propertyImage
    property string propertyId: ""
    property string propertyLocation: ""
    property string roomType: ""
    property string roomId: ""

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

    //Signals
    signal contactHostRequested()
    signal viewMapRequested()
    // Ask the page to refund the client and put the room back on the market.
    signal releaseRequested()

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
                        cache: true
                        asynchronous: true
                    }
                    // Placeholder while loading or if no image is available.
                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        visible: mainImg.status === Image.Loading ||
                                 mainImg.status === Image.Null ||
                                 mainImg.status === Image.Error

                        // Text {
                        //     anchors.horizontalCenter: parent.horizontalCenter
                        //     text: "▧"
                        //     font.pixelSize: 32
                        //     color: "#94A3B8"
                        // }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: mainImg.status === Image.Error
                                  ? "Image unavailable"
                                  : "Loading property image..."
                            color: "#64748B"
                            font.pixelSize: 12
                        }
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
            bookingDate: root.checkIn
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
            userInitial: root.clientInitial
            userEmail: ""
        }
        UserInfoCard{
            cardTitle: "Landlord Info"
            cardIcon: "qrc:/ui/assets/bookings/landlord-icon.svg"
            userName: root.landlord
            userPhone: root.landlordPhone
            userInitial: root.landlordInitials
            custIconHeight: 16
            custIconWidth: 16
            userEmail: ""
        }
        // --- APPROVE ACTION BUTTON ---
        Rectangle {
            visible: root.status === "Pending"
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
                onClicked: root.cancelBookingRequested()
            }
        }
    }
}