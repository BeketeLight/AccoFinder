import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: detailsPage
    background: Rectangle { color: "#F5F5F5" }

    // --- SAMPLE BOOKING DATA PROPERTIES ---
    property string bookingId: "BK-1001"
    property string status: "Approved" // Pending / Approved / Rejected / Cancelled / Completed
    property string propertyName: "Sunset Lake Villa"
    property string propertyLocation: "124 Lakeview Drive, Sector 4"
    property string propertyImage: "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=500"
    property string roomType: "Entire Villa (2 Bedrooms)"

    property string clientName: "John Doe"
    property string clientPhone: "+1 555-0192"
    property string clientEmail: "johndoe@example.com"
    property int guestCount: 3

    property string checkIn: "Oct 12, 2026 (2:00 PM)"
    property string checkOut: "Oct 15, 2026 (11:00 AM)"
    property int nightsCount: 3
    property string clientNotes: "Please provide an extra crib if available. Late check-in expected."

    property string baseAmount: "$400.00"
    property string serviceFee: "$50.00"
    property string totalAmount: "$450.00"
    property string paymentStatus: "Paid" // Unpaid / Paid / Refunded / Partial
    property string paymentMethod: "Credit Card (Visa ending in 4242)"
    property string paymentDate: "Oct 10, 2026"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- 1. HEADER ROW ---
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 56
            color: "#FFFFFF"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                // Back Button
                Rectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 16
                    color: "#F1F5F9"

                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#0F172A"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: console.log("Back button clicked")
                    }
                }

                // Booking ID Title
                Text {
                    text: detailsPage.bookingId
                    font.pixelSize: 17
                    font.bold: true
                    color: "#0F172A"
                }

                Item { Layout.fillWidth: true }

                // Dynamic Status Badge
                Rectangle {
                    implicitWidth: statusText.implicitWidth + 16
                    implicitHeight: 24
                    radius: 12
                    color: detailsPage.status === "Pending" ? "#FEF3C7" :
                          (detailsPage.status === "Approved" ? "#DCFCE7" :
                          (detailsPage.status === "Completed" ? "#E0F2FE" : "#FEE2E2"))

                    Text {
                        id: statusText
                        anchors.centerIn: parent
                        text: detailsPage.status
                        font.pixelSize: 11
                        font.bold: true
                        color: detailsPage.status === "Pending" ? "#D97706" :
                              (detailsPage.status === "Approved" ? "#16A34A" :
                              (detailsPage.status === "Completed" ? "#0284C7" : "#E11D48"))
                    }
                }
            }
        }

        // --- MAIN SCROLLABLE CONTENT ---
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: scrollContent.implicitHeight + 24
            clip: true

            ColumnLayout {
                id: scrollContent
                width: parent.width - 24
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Item { implicitHeight: 4 } // Top padding spacing

                // --- 2. PROPERTY SUMMARY ---
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: propertyCol.implicitHeight + 24
                    radius: 10
                    color: "#FFFFFF"

                    ColumnLayout {
                        id: propertyCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 140
                            radius: 8
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: detailsPage.propertyImage
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        Text {
                            text: detailsPage.propertyName
                            font.pixelSize: 16
                            font.bold: true
                            color: "#0F172A"
                        }

                        Text {
                            text: "📍 " + detailsPage.propertyLocation
                            font.pixelSize: 12
                            color: "#64748B"
                        }

                        Text {
                            text: "🏠 " + detailsPage.roomType
                            font.pixelSize: 12
                            color: "#64748B"
                        }

                        Text {
                            text: "View Property ›"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#2563EB"
                        }
                    }
                }

                // --- 3. CLIENT INFORMATION ---
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: clientCol.implicitHeight + 24
                    radius: 10
                    color: "#FFFFFF"

                    ColumnLayout {
                        id: clientCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            text: "Client Information"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#0F172A"
                        }

                        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#F1F5F9" }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Name:"; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 80 }
                            Text { text: detailsPage.clientName; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Phone:"; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 80 }
                            Text {
                                text: detailsPage.clientPhone + " 📞"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#2563EB"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Email:"; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 80 }
                            Text { text: detailsPage.clientEmail; font.pixelSize: 12; color: "#0F172A" }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Guests:"; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 80 }
                            Text { text: detailsPage.guestCount + " Guests"; font.pixelSize: 12; color: "#0F172A" }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 36
                            radius: 18
                            color: "#0F172A"

                            // Text {
                            //     anchors.centerIn: parent
                            //     text: "💬 Contact Client"
                            //     font.pixelSize: 12
                            //     font.bold: true
                            //     color: "#FFFFFF"
                            // }
                            ToolButton{
                              anchors.centerIn: parent
                              icon.source: "qrc:/ui/assets/message-icon.svg"
                              icon.height: 16
                              icon.width: 16
                              background: null
                            }
                        }
                    }
                }

                // --- 4. STAY DETAILS ---
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: stayCol.implicitHeight + 24
                    radius: 10
                    color: "#FFFFFF"

                    ColumnLayout {
                        id: stayCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            text: "Stay Details"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#0F172A"
                        }

                        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#F1F5F9" }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Check-in:"; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 90 }
                            Text { text: detailsPage.checkIn; font.pixelSize: 12; font.bold: true; color: "#0F172A" }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Check-out:"; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 90 }
                            Text { text: detailsPage.checkOut; font.pixelSize: 12; font.bold: true; color: "#0F172A" }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Duration:"; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 90 }
                            Text { text: detailsPage.nightsCount + " Nights"; font.pixelSize: 12; color: "#0F172A" }
                        }

                        Text {
                            text: "Special Requests:"
                            font.pixelSize: 12; font.bold: true; color: "#64748B"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: notesText.implicitHeight + 16
                            radius: 6
                            color: "#F8FAFC"
                            border.color: "#E2E8F0"

                            Text {
                                id: notesText
                                anchors.fill: parent
                                anchors.margins: 8
                                text: detailsPage.clientNotes
                                font.pixelSize: 12
                                color: "#334155"
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                // --- 5. PAYMENT SUMMARY ---
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: payCol.implicitHeight + 24
                    radius: 10
                    color: "#FFFFFF"

                    ColumnLayout {
                        id: payCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            text: "Payment Summary"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#0F172A"
                        }

                        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#F1F5F9" }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Room Amount:"; font.pixelSize: 12; color: "#64748B" }
                            Item { Layout.fillWidth: true }
                            Text { text: detailsPage.baseAmount; font.pixelSize: 12; color: "#0F172A" }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Service Fees:"; font.pixelSize: 12; color: "#64748B" }
                            Item { Layout.fillWidth: true }
                            Text { text: detailsPage.serviceFee; font.pixelSize: 12; color: "#0F172A" }
                        }

                        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#E2E8F0" }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Total Amount:"; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
                            Item { Layout.fillWidth: true }
                            Text { text: detailsPage.totalAmount; font.pixelSize: 15; font.bold: true; color: "#0F172A" }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Status:"; font.pixelSize: 12; color: "#64748B" }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: detailsPage.paymentStatus
                                font.pixelSize: 12
                                font.bold: true
                                color: detailsPage.paymentStatus === "Paid" ? "#16A34A" : "#E11D48"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Method:"; font.pixelSize: 12; color: "#64748B" }
                            Item { Layout.fillWidth: true }
                            Text { text: detailsPage.paymentMethod; font.pixelSize: 12; color: "#334155" }
                        }
                    }
                }

                // --- 6. BOOKING TIMELINE ---
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: timelineCol.implicitHeight + 24
                    radius: 10
                    color: "#FFFFFF"

                    ColumnLayout {
                        id: timelineCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            text: "Booking Timeline"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#0F172A"
                        }

                        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#F1F5F9" }

                        Column {
                            spacing: 6

                            Text { text: "• Created: Oct 10, 2026 at 10:15 AM"; font.pixelSize: 12; color: "#64748B" }
                            Text { text: "• Paid: Oct 10, 2026 at 10:18 AM"; font.pixelSize: 12; color: "#64748B" }
                            Text { text: "• Approved: Oct 11, 2026 at 09:00 AM"; font.pixelSize: 12; color: "#16A34A"; font.bold: true }
                        }
                    }
                }
            }
        }
    }
}