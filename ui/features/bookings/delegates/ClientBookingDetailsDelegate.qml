import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: delegateRoot

    // --- INPUT PROPERTIES PASSED FROM MODEL / CONTROLLER ---
    property string bookingId: ""
    property string status: "Approved" // "Pending", "Approved", "Cancelled", "Completed"
    property string statusNote: ""

    property string houseName: ""
    property string landlordName: ""
    property string imageUrl: ""

    property string checkIn: ""
    property string checkOut: ""
    property string specialRequests: ""

    property double roomPrice: 0.0
    property double discount: 0.0
    property double totalPrice: roomPrice - discount
    property string paymentStatus: "Unpaid" // "Unpaid", "Paid", "Refunded"
    property string paymentMethod: ""
    property string paymentDate: ""

    property string cancellationPolicy: ""

    // Check-in details (only displayed if approved and paid)
    property string keyInstructions: ""

    // --- INTERACTION SIGNALS ---
    signal payNowRequested()
    signal actionRequested(string actionType)

    // --- COMPONENT SIZING ---
    width: ListView.view ? ListView.view.width : parent.width
    implicitHeight: contentColumn.implicitHeight + 32
    color: "#FFFFFF"
    radius: 12
    border.color: "#E2E8F0"
    border.width: 1

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 10
        spacing: 16

        // ==========================================
        // 1. BOOKING STATUS CARD
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: statusLayout.implicitHeight + 24
            radius: 10
            color: "#F8FAFC"
            border.color: "#E2E8F0"

            ColumnLayout {
                id: statusLayout
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Booking Ref: " + delegateRoot.bookingId
                        font.pixelSize: 13
                        font.bold: true
                        color: "#64748B"
                        Layout.fillWidth: true
                       // elide: Text.ElideRigh
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: statusText.implicitWidth + 16
                        implicitHeight: statusText.implicitHeight + 8
                       // implicitHeight: 24
                        radius: 12
                        color: {
                            switch(delegateRoot.status) {
                                case "Approved": return "#DCFCE7"
                                case "Pending": return "#FEF3C7"
                                case "Cancelled": return "#FEE2E2"
                                default: return "#F1F5F9"
                            }
                        }

                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            text: delegateRoot.status
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: {
                                switch(delegateRoot.status) {
                                    case "Approved": return "#15803D"
                                    case "Pending": return "#B45309"
                                    case "Cancelled": return "#B91C1C"
                                    default: return "#475569"
                                }
                            }
                        }
                    }
                }

                Text {
                    text: delegateRoot.statusNote
                    font.pixelSize: 13
                    color: "#334155"
                    wrapMode: Text.WordWrap
                }
            }
        }

        // ==========================================
        // 2. CHECK-IN INSTRUCTIONS (CONDITIONAL)
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            visible: delegateRoot.status === "Approved" && delegateRoot.paymentStatus === "Paid"
            implicitHeight: visible ? checkInInstLayout.implicitHeight + 24 : 0
            radius: 10
            color: "#EFF6FF"
            border.color: "#BFDBFE"

            ColumnLayout {
                id: checkInInstLayout
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: "Key Pickup Instructions"
                    font.pixelSize: 15
                    font.bold: true
                    color: "#1E40AF"
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#DBEAFE" }

                Text {
                    text: delegateRoot.keyInstructions
                    font.pixelSize: 13
                    color: "#1E3A8A"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }
        }

        // ==========================================
        // 3. STAY INFORMATION
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: stayLayout.implicitHeight + 24
            radius: 10
            color: "#FFFFFF"
            border.color: "#E2E8F0"

            ColumnLayout {
                id: stayLayout
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: delegateRoot.houseName
                    font.pixelSize: 16
                    font.bold: true
                    color: "#0F172A"
                }

                Text {
                    text: "Hosted by " + delegateRoot.landlordName
                    font.pixelSize: 13
                    color: "#64748B"
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#F1F5F9" }

                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text { text: "Check-in"; font.pixelSize: 12; color: "#94A3B8" }
                        Text { text: delegateRoot.checkIn; font.pixelSize: 13; font.bold: true; color: "#334155" }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text { text: "Check-out"; font.pixelSize: 12; color: "#94A3B8" }
                        Text { text: delegateRoot.checkOut; font.pixelSize: 13; font.bold: true; color: "#334155" }
                    }
                }

                ColumnLayout {
                    visible: delegateRoot.specialRequests !== ""
                    spacing: 2
                    Text { text: "Special Requests:"; font.pixelSize: 12; color: "#94A3B8" }
                    Text { text: delegateRoot.specialRequests; font.pixelSize: 13; color: "#334155"; Layout.fillWidth: true; wrapMode: Text.Wrap }
                }
            }
        }

        // ==========================================
        // 4. PAYMENT DETAILS
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: paymentLayout.implicitHeight + 24
            radius: 10
            color: "#FFFFFF"
            border.color: "#E2E8F0"

            ColumnLayout {
                id: paymentLayout
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: "Payment Summary"
                    font.pixelSize: 15
                    font.bold: true
                    color: "#0F172A"
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Room Total"; font.pixelSize: 13; color: "#64748B" }
                    Item { Layout.fillWidth: true }
                    Text { text: "MWK" + delegateRoot.roomPrice.toFixed(2); font.pixelSize: 13; color: "#334155" }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: delegateRoot.discount > 0
                    Text { text: "Discount"; font.pixelSize: 13; color: "#16A34A" }
                    Item { Layout.fillWidth: true }
                    Text { text: "-$" + delegateRoot.discount.toFixed(2); font.pixelSize: 13; color: "#16A34A" }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#F1F5F9" }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Total Amount"; font.pixelSize: 14; font.bold: true; color: "#0F172A" }
                    Item { Layout.fillWidth: true }
                    Text { text: "MWK" + delegateRoot.totalPrice.toFixed(2); font.pixelSize: 15; font.bold: true; color: "#0F172A" }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Payment Status:"; font.pixelSize: 13; color: "#64748B" }
                    Text { text: delegateRoot.paymentStatus; font.pixelSize: 13; font.bold: true; color: delegateRoot.paymentStatus === "Paid" ? "#16A34A" : "#DC2626" }
                }

                Text {
                    visible: delegateRoot.paymentStatus === "Paid"
                    text: "Paid via " + delegateRoot.paymentMethod + " on " + delegateRoot.paymentDate
                    font.pixelSize: 12
                    color: "#94A3B8"
                }

                Button {
                    Layout.fillWidth: true
                    visible: delegateRoot.paymentStatus === "Unpaid"
                    text: "Pay Now"
                    highlighted: true
                    background: Rectangle{
                        color: "#2563EB"
                        radius: 16
                    }
                    onClicked: delegateRoot.payNowRequested()
                }
            }
        }

        // ==========================================
        // 5. CANCELLATION POLICY
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: cancelLayout.implicitHeight + 24
            radius: 10
            color: "#FFFFFF"
            border.color: "#E2E8F0"

            ColumnLayout {
                id: cancelLayout
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                Text {
                    text: "Cancellation Policy"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#0F172A"
                }

                Text {
                    text: delegateRoot.cancellationPolicy
                    font.pixelSize: 13
                    color: "#64748B"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}