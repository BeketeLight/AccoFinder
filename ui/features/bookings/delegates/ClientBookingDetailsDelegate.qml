import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"
import "../../../components/buttons"
import "../../../components/dialogs"
import "../../../utils/Utils.js" as Helper
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../utils/ImageUtils.js" as CatchedImage

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
    property string roomId: ""
    property string propertyId: ""
    property real price: 0.0
    property string clientName: ""
    property string clientPhone: ""
    property string clientEmail: ""
    property int guestCount: 0

    property string bookingDate: ""
    property string checkOut: ""
    property int nightsCount: 0
    property string clientNotes: ""

    property string paymentStatus: ""
    property string paymentMethod: ""
    property string paymentDate: ""

    readonly property string statusKey: String(status).trim().toUpperCase()
    readonly property bool canRaiseDispute: statusKey === "CANCELLED" || "EXPIRED"

    property string createdTime: ""
    property string holdExpiresAt:  ""
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

    Timer {
        interval: 1000
        running: detailsPage.holdExpiresAt.length > 0
        repeat: true
        onTriggered: detailsPage.tick++
    }
    readonly property string holdCountdownText: {
        var _ = tick
       // return .holdCountdownText(holdExpiresAt)
        return Helper.holdCountdownText(holdExpiresAt)
    }

    readonly property bool canPay: {
        var _ = tick
        return Helper.canPayBooking(status, holdExpiresAt)
    }
    //Status must be pending
    //Expiration window still open
    readonly property bool showHoldActions: {
        var _ = tick
        return Helper.canPayBooking(status, holdExpiresAt)
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
                        color: "#EAF0F8"

                        Image {
                            id: mainImg

                            anchors.fill: parent

                            source: CatchedImage.cachedSource(detailsPage.propertyImage)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            visible: status === Image.Ready

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    console.warn(
                                        "Booking image failed:",
                                        source.toString(),
                                        "error:",
                                        status
                                    )
                                }
                            }
                        }

                        // Placeholder while loading or if no image is available.
                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            visible: mainImg.status === Image.Loading ||
                                     mainImg.status === Image.Null ||
                                     mainImg.status === Image.Error

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "▧"
                                font.pixelSize: 32
                                color: "#94A3B8"
                            }

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
            //Status Banner
            BookingStatusBanner{
                Layout.fillWidth: true
                status: detailsPage.status
            }

            BookingsCard{
                cardTitle: "Property & Date Info"
                bookingDate: detailsPage.bookingDate
                roomType: detailsPage.roomType
            }
            PaymentSummaryCard{
                roomPrice: detailsPage.price
                commission: ""
                totalAmount: detailsPage.price
            }

            UserInfoCard{
                userName: detailsPage.hostName
                cardTitle: "Property Host"
                userInitial: detailsPage.hostInitials
                userEmail: ""
            }
            // Actions while hold is open ---

            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 12
                visible: detailsPage.showHoldActions
                CustomButton{
                    id: payBtn
                    text: qsTr("Pay now")
                    textColor: "#FFFFFF"
                    cornerRadius: 12
                    //visible: holdCountdownText.length > 0
                    Layout.fillWidth: true
                    implicitHeight: 50
                    buttonColor: detailsPage.primaryColor
                    onClicked: {
                        console.log("Pay now", delegateRoot.bookingId, delegateRoot.price, delegateRoot.holdExpiresAt)
                        detailsPage.payNowRequested(
                            detailPage.bookingId,
                            Number(delegateRoot.price),
                            detailsPage.holdExpiresAt
                        )
                    }
                }
                CustomButton{
                    id: cancelBtn
                    text: qsTr("Cancel booking")
                    textColor: "#F43F5E"
                    Layout.fillWidth: true
                    implicitHeight: 50
                    cornerRadius: 12
                    borderColor: "#FCA5A5"
                    borderWidth: 1
                    buttonColor: "#FEE2E2"
                    onClicked: {
                        cancelBookingDialog.open()
                    }
                }
            }
            // --- Confirmed: raise dispute ---
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 12
                visible: detailsPage.canRaiseDispute

                CustomButton {
                    text: qsTr("Report a problem")
                    textColor: "#1D4ED8"
                    Layout.fillWidth: true
                    implicitHeight: 50
                    cornerRadius: 12
                    borderColor: "#93C5FD"
                    borderWidth: 1
                    buttonColor: "#EFF6FF"
                    onClicked: {
                        NavUtils.navigateToRaiseDispute({
                            bookingId: detailsPage.bookingId,
                            houseName: detailsPage.houseName,
                            propertyImage: detailsPage.propertyImage,
                            propertyLocation: detailsPage.propertyLocation,
                           // status: detailsPage.status,
                           // bookingDate: detailsPage.bookingDate
                        })
                    }
                }
            }

            AppAlertDialog {
                id: cancelBookingDialog
                Layout.alignment: Qt.AlignCenter
                customText: qsTr("Cancel booking?")
                customInformativeText: qsTr(
                    "Are you sure you want to cancel this booking? This action may not be reversible."
                )

                onAccepted: {
                    BookingViewModel.cancelBooking(detailsPage.bookingId)
                }
            }
        }
}