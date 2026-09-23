import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: delegateRoot

    //Item {
        //id: delegateRoot
        width: ListView.view ? ListView.view.width : parent.width
        implicitHeight: mainLayout.implicitHeight

        // Fallbacks allow using model roles directly or binding custom properties
        property string bookingId: ""
        property string status: ""
        property string houseName: ""
        property string propertyImage: ""
        property string propertyLocation: ""
        //readonly property string propertyImage: model.propertyImage ?? "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=500"
        property string roomType: ""

        property string clientName: ""
        property string clientPhone: ""
        property string clientEmail: ""
        property int guestCount: 0

        property string checkIn: ""
        property string checkOut: ""
        property int nightsCount: 0
        property string clientNotes: ""

        property double baseAmount: 0.0
        property double serviceFee: 0.0
        property double totalAmount: 0.0//(Number(baseAmount) || 0.0) + (Number(serviceFee) || 0.0)
        property string paymentStatus: ""
        property string paymentMethod: ""
        property string paymentDate: ""

        property string createdTime: ""
        //property string paidTime: model.paidTime ?? "Oct 10, 2026 at 10:18 AM"
        //property string approvedTime: model.approvedTime ?? "Oct 11, 2026 at 09:00 AM"

        // Background layer equivalent to Page background
        //  Rectangle {
        //      anchors.fill: parent
        //      color: "#F5F5F5"
        // }
        color: "#FFFFFF"
        radius: 12
        border.color: "#E2E8F0"
        border.width: 1

        ColumnLayout {
            id: mainLayout
           // anchors.fill: parent
            //spacing: 0
            //id: mainColumn
                    width: parent.width
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 12

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
                    // Booking ID Title
                    // Text {
                    //     text: delegateRoot.bookingId
                    //     font.pixelSize: 17
                    //     font.bold: true
                    //     color: "#0F172A"
                    // }

                    Item { Layout.fillWidth: true }

                    // Dynamic Status Badge
                    Rectangle {
                        implicitWidth: statusText.implicitWidth + 16
                        implicitHeight: 24
                        radius: 12
                        color: delegateRoot.status === "Pending" ? "#FEF3C7" :
                              (delegateRoot.status === "Approved" ? "#DCFCE7" :
                              (delegateRoot.status === "Completed" ? "#E0F2FE" : "#FEE2E2"))

                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            text: delegateRoot.status
                            font.pixelSize: 11
                            font.bold: true
                            color: delegateRoot.status === "Pending" ? "#D97706" :
                                  (delegateRoot.status === "Approved" ? "#16A34A" :
                                  (delegateRoot.status === "Completed" ? "#0284C7" : "#E11D48"))
                        }
                    }
                }
            }

            // --- MAIN SCROLLABLE CONTENT ---

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
                                    source: delegateRoot.propertyImage
                                    fillMode: Image.PreserveAspectCrop
                                }
                            }

                            Text {
                                text: delegateRoot.houseName
                                font.pixelSize: 16
                                font.bold: true
                                color: "#0F172A"
                            }
                            RowLayout{
                                spacing: 0
                                ToolButton{
                                    icon.source: "qrc:/ui/assets/location-icon.svg"
                                    icon.width: 10
                                    icon.height: 10
                                    background: null
                                }
                                Text {
                                    text: delegateRoot.propertyLocation
                                    font.pixelSize: 12
                                    color: "#64748B"
                                }
                            }


                            Text {
                                text: delegateRoot.roomType
                                font.pixelSize: 12
                                color: "#64748B"
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
                                Text { text: delegateRoot.clientName; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Phone:"; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 80 }
                                Text {
                                    text: delegateRoot.clientPhone
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2563EB"
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Email:"; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 80 }
                                Text { text: delegateRoot.clientEmail; font.pixelSize: 12; color: "#0F172A" }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 36
                                radius: 18
                                color: "#2563EB"
                                RowLayout{
                                    anchors.centerIn: parent
                                    spacing: 6
                                    ToolButton{
                                        icon.source: "qrc:/ui/assets/message-icon.svg"
                                        icon.height: 16
                                        icon.width: 16
                                        background: null
                                    }
                                    Text {
                                        //anchors.centerIn: parent
                                        text: "Contact Client"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#FFFFFF"
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: console.log("Contact client:", delegateRoot.clientName)
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
                                Text { text: delegateRoot.checkIn; font.pixelSize: 12; font.bold: true; color: "#0F172A" }
                            }

                            // RowLayout {
                            //     Layout.fillWidth: true
                            //     Text { text: "Check-out:"; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 90 }
                            //     Text { text: delegateRoot.checkOut; font.pixelSize: 12; font.bold: true; color: "#0F172A" }
                            // }

                            // RowLayout {
                            //     Layout.fillWidth: true
                            //     Text { text: "Duration:"; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 90 }
                            //     Text { text: delegateRoot.nightsCount + " Nights"; font.pixelSize: 12; color: "#0F172A" }
                            // }

                            // Text {
                            //     text: "Special Requests:"
                            //     font.pixelSize: 12; font.bold: true; color: "#64748B"
                            // }

                            // Rectangle {
                            //     Layout.fillWidth: true
                            //     implicitHeight: notesText.implicitHeight + 16
                            //     radius: 6
                            //     color: "#F8FAFC"
                            //     border.color: "#E2E8F0"

                            //     Text {
                            //         id: notesText
                            //         anchors.fill: parent
                            //         anchors.margins: 8
                            //         text: delegateRoot.clientNotes
                            //         font.pixelSize: 12
                            //         color: "#334155"
                            //         wrapMode: Text.WordWrap
                            //     }
                            // }
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
                                Text { text: "MWK" + delegateRoot.baseAmount; font.pixelSize: 12; color: "#0F172A" }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Booking Fee:"; font.pixelSize: 12; color: "#64748B" }
                                Item { Layout.fillWidth: true }
                                Text { text:"MWK" + delegateRoot.serviceFee; font.pixelSize: 12; color: "#0F172A" }
                            }

                            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#E2E8F0" }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Total Amount:"; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
                                Item { Layout.fillWidth: true }
                                Text { text:"MWK" + delegateRoot.totalAmount; font.pixelSize: 15; font.bold: true; color: "#0F172A" }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Status:"; font.pixelSize: 12; color: "#64748B" }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: delegateRoot.paymentStatus
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: delegateRoot.paymentStatus === "Paid" ? "#16A34A" : "#E11D48"
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Method:"; font.pixelSize: 12; color: "#64748B" }
                                Item { Layout.fillWidth: true }
                                Text { text: delegateRoot.paymentMethod; font.pixelSize: 12; color: "#334155" }
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

                                Text { text: "• Created: " + delegateRoot.createdTime; font.pixelSize: 12; color: "#64748B" }
                                Text { text: "• Paid: " + delegateRoot.paidTime; font.pixelSize: 12; color: "#64748B" }
                                Text { text: "• Approved: " + delegateRoot.approvedTime; font.pixelSize: 12; color: "#16A34A"; font.bold: true }
                            }
                        }
                    }
                }
            //}
        }
    //}
//}