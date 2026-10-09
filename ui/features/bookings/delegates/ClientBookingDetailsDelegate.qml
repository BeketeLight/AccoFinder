import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"
import "../../../components/buttons"
import "../../../components/dialogs"
import "../../../utils/Utils.js" as Helper

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
    property real price: 0.0
    property string clientName: ""
    property string clientPhone: ""
    property string clientEmail: ""
    property int guestCount: 0

    property string checkIn: ""
    property string checkOut: ""
    property int nightsCount: 0
    property string clientNotes: ""

    property string paymentStatus: ""
    property string paymentMethod: ""
    property string paymentDate: ""

    property string createdTime: ""
    property string holdExpiresAt:  ""
    property int tick: 0
    // --- SIGNALS ---
    signal backRequested()
    signal cancelBookingRequested()
    signal contactHostRequested()
    signal payNowRequested(string bookingId, real amount, var holdExpiresAt)

        // ------------------------------------------
        // 1. POPULATED DATA VIEW
        // ------------------------------------------
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
                                icon.source: "qrc:/ui/assets/location-icon.svg"
                                icon.height: 12
                                icon.width: 12
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

            // --- RESERVATION DETAILS CARD ---
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: resCol.implicitHeight + 24
                radius: 12
                color: "#FFFFFF"
                border.color: "#E2E8F0"
                border.width: 1

                ColumnLayout {
                    id: resCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 4

                    RowLayout {
                        spacing: 0
                        ToolButton{
                            icon.source: "qrc:/ui/assets/reservation-icon.svg"
                            icon.height: 12
                            icon.width: 12
                            background: null
                        }
                        Text {
                            text: "Reservation Details"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#0F172A"
                        }
                    }

                    GridLayout {
                        columns: 2
                        Layout.fillWidth: true
                        columnSpacing: 24
                        rowSpacing: 12
                        // Row 2 Col 1
                        ColumnLayout {
                            spacing: 2
                            Text { text: "Booking date"; font.pixelSize: 13; color:"#0F172A"  }
                            Item{Layout.preferredWidth: 250}
                            Text { text: detailsPage.checkIn; font.pixelSize: 11; color:  "#64748B"}
                        }

                        // Row 2 Col 2
                        ColumnLayout {
                            spacing: 2
                            Text { text: "Room Type"; font.pixelSize: 13; color: "#0F172A" }
                            Item{Layout.preferredWidth: 250}
                            Text { text: detailsPage.roomType; font.pixelSize: 11; color: "#64748B" }
                        }
                    }
                }
            }

            // --- PAYMENT SUMMARY CARD ---
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: payCol.implicitHeight + 24
                radius: 12
                color: "#FFFFFF"
                border.color: "#E2E8F0"
                border.width: 1
                ColumnLayout {
                    id: payCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 4

                    RowLayout {
                        spacing: 0
                        ToolButton{
                            icon.source: "qrc:/ui/assets/payment-icon.svg"
                            icon.height: 16
                            icon.width: 16
                            background: null
                        }
                        Text { text: "Payment Summary"; font.pixelSize: 14; font.bold: true; color: "#0F172A" }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            spacing: 6
                            RowLayout {
                                Text { text: "Room price"; font.pixelSize: 12; color: "#64748B" }
                                Item { Layout.fillWidth: true }
                                Text { text:"MWK" + detailsPage.price; font.pixelSize: 12; font.bold: true; color: "#0F172A" }
                            }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#F1F5F9" }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Total"; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
                        Item { Layout.fillWidth: true }
                        Text { text:"MWK" + detailsPage.price; font.pixelSize: 15; font.bold: true; color: "#0F172A" }
                    }
                }
            }

            // --- PROPERTY HOST CARD ---
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: hostRow.implicitHeight + 48
                radius: 12
                border.color: "#E2E8F0"
                border.width: 1
                color: "#FFFFFF"

                ColumnLayout {
                    id: hostCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 4

                    RowLayout {
                        spacing: 0
                        RowLayout {
                            spacing: 0
                            ToolButton{
                            icon.source: "qrc:/ui/assets/account-icon.svg"
                            icon.height: 12
                            icon.width: 12
                            background: null
                        }
                        Text { text: "Property Host"; font.pixelSize: 14; font.bold: true; color: "#0F172A" }
                    }

                    }

                    RowLayout {
                        id: hostRow
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            implicitWidth: 44
                            implicitHeight: 44
                            radius: 22
                            color: "#E2E8F0"
                            clip: true
                            Text{
                                anchors.centerIn: parent
                                text: detailsPage.hostInitials
                                color: "blue"
                                font.pointSize: 14
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Text { text: detailsPage.hostName; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
                            // Text { text: "📞 " + detailsPage.hostPhone; font.pixelSize: 11; color: "#64748B" }
                        }
                    }
                }
            }
            // Cancel action button
            // Actions while hold is open ---
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 12
                visible: detailsPage.showHoldActions

                Rectangle {
                    id: cancel
                    Layout.fillWidth: true
                    implicitHeight: 40
                    radius: 24
                    border.width: 1
                    border.color: "#F43F5E"
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Cancel booking")
                        color: "#F43F5E"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            //cancelBookingDialog.visibleDialog = true
                            //detailsPage.cancelBookingRequested()
                            cancelBookingDialog.open()
                        }
                    }
                }

                Rectangle {
                    id: pay
                    Layout.fillWidth: true
                    implicitHeight: 40
                    radius: 24
                    color: "#22C55E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Pay now")
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: pay
                        onClicked: detailsPage.payNowRequested(
                            detailsPage.bookingId,
                            detailsPage.price,
                            detailsPage.holdExpiresAt
                        )
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