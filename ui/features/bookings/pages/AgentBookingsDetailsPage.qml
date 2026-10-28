import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../models"
import "../components"
import "../../../utils/NavigationUtils.js" as NavUtils

Page{
    id: root
    property alias bookingId: detailDelegate.bookingId
    property alias status: detailDelegate.status
    property alias houseName: detailDelegate.houseName
    property alias propertyLocation: detailDelegate.propertyLocation
    property alias propertyImage:detailDelegate.propertyImage
    property alias propertyId: detailDelegate.propertyId
    property alias roomType: detailDelegate.roomType
    property alias roomId: detailDelegate.roomId
    property alias clientName: detailDelegate.clientName
    property alias clientPhone: detailDelegate.clientPhone
    property alias clientEmail: detailDelegate.clientEmail
    property alias clientInitial: detailDelegate.clientInitial
    property alias landlord: detailDelegate.landlord
    property alias landlordInitials: detailDelegate.landlordInitials
    property alias landlordPhone: detailDelegate.landlordPhone
    property alias price: detailDelegate.price
    property alias commission: detailDelegate.commission
    property alias checkIn: detailDelegate.checkIn
    property alias paymentStatus: detailDelegate.paymentStatus
    property alias paymentMethod: detailDelegate.paymentMethod
    property alias paymentDate: detailDelegate.paymentDate

    property bool showHeader: true
    property bool showBack: false
    property bool isSearchBar: false
    property bool showBottomBorder: false
    property bool collapsible: false
    property bool transparentHeader: true
    property real scrollY: scrollViewId.contentItem.contentY


    property Component leftComponentAction: Component {
        RowLayout {
            spacing: 12
            ToolButton {
                implicitWidth: 28
                implicitHeight: 28
                icon.source: "qrc:/ui/assets/back-icons.svg"
                icon.color: "#111111"
                icon.width: 10
                icon.height: 16
                onClicked: {
                    if (typeof NavUtils !== "undefined")
                        NavUtils.pop()
                }
                background: Rectangle{
                    radius: 14
                    color: "#FFFFFF"
                }
            }
            BookingStatusBadge {
                Layout.alignment: Qt.AlignVCenter
                status: root.status
            }
        }
    }
    ScrollView {
        id: scrollViewId
        anchors.topMargin: 6
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        AgentBookingDetailsDelegate {
            id: detailDelegate
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            width: Math.min(parent.width - 32, 600)

            onReleaseRequested: releaseDialog.open()

            // onPayNowRequested: {
            //     console.log("Processing payment for booking:", bookingId)
            // }
        }
    }

    // Refunding frees the room, so require a deliberate confirmation before the
    // release call goes out.
    Dialog {
        id: releaseDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent ? parent.width - 40 : 320, 340)
        title: qsTr("Refund & relist room")

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("This refunds the client and returns the room to the market so it can be booked again. This cannot be undone.")
                color: "#64748B"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Cancel")
                    onClicked: releaseDialog.reject()
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Refund & relist")
                    onClicked: {
                        if (String(root.bookingId).length > 0)
                            BookingController.releaseBooking(root.bookingId)
                        releaseDialog.accept()
                    }
                }
            }
        }
    }
}
