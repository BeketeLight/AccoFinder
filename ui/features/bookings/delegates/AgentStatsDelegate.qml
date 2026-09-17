import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: delegateRoot

    // --- MODEL PROPERTIES ---
    property string bookingId: ""//model.bookingId ?? ""
    property string houseName: ""//model.houseName ?? ""
    property string imageUrl: ""//model.imageUrl ?? ""
    property string status: ""//model.status ?? ""
    property string clientName: ""//model.clientName ?? ""
    property string clientPhone: ""//model.clientPhone ?? ""
    property string dateRange: model.dateRange ?? ""
    property string price: ""//model.price ?? ""
    property string createdDate: model.createdDate ?? "Aug 31, 2026"
    property string propertyImage : ""
    property string propertyLocation: ""
    property string roomType: ""
    property string clientEmail: ""
    property int guestCount: 0
    property string checkIn: ""
    property string checkOut: ""
    property int nightsCount: 0
    property string clientNotes: ""
    property double baseAmount: 0.0
    property double serviceFee: 0.0
    property double totalAmount:  baseAmount + serviceFee
    property string paymentStatus: ""
    property string paymentMethod: ""
    property string paymentDate: ""

    // --- ACTIVE FILTER PROP ---
    property string activeFilter: "View all"

    // --- SIGNALS ---
    signal approveRequested()
    signal rejectRequested()
    signal cancelRequested()
    signal contactRequested()
    signal detailsRequested(var data)

    // --- VISIBILITY & HEIGHT COLLAPSE ---
    visible: activeFilter === "View all" || status === activeFilter
    width: ListView.view ? ListView.view.width : parent.width
    implicitHeight: visible ? mainLayout.implicitHeight + 24 : 0

    color: "#FFFFFF"

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // --- 1. TOP HEADER: STATUS TITLE & DATE ---
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: delegateRoot.status
                font.pixelSize: 15
                font.bold: true
                color: "#000000"
            }

            Item { Layout.fillWidth: true }

            // Text {
            //     text: delegateRoot.createdDate
            //     font.pixelSize: 12
            //     color: "#888888"
            // }
        }

        // --- 2. AGENT / HOUSE STORE HEADER ---
        RowLayout {
            spacing: 6

            // "Choice" style tag
            // Rectangle {
            //     implicitWidth: 46
            //     implicitHeight: 18
            //     radius: 4
            //     color: "#FFD700"

            //     Text {
            //         anchors.centerIn: parent
            //         text: "Propety Name"
            //         font.pixelSize: 10
            //         font.bold: true
            //         color: "#000000"
            //     }
            // }

            Text {
                text: delegateRoot.houseName
                font.pixelSize: 14
                font.bold: true
                color: "#2B62ED"//"#000000"
            }
        }

        // --- 3. PRODUCT ROW: THUMBNAIL & DETAILS ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: 8
                color: "#F0F0F0"
                clip: true

                Image {
                    anchors.fill: parent
                    source: delegateRoot.imageUrl !== "" ? delegateRoot.imageUrl : "qrc:/assets/placeholder.png"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Client: " + delegateRoot.clientName + " (" + delegateRoot.clientPhone + ")"
                    font.pixelSize: 13
                    color: "#222222"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: "Dates: " + delegateRoot.dateRange
                    font.pixelSize: 12
                    color: "#888888"
                }

                Text {
                    text:"MWK" + delegateRoot.price
                    font.pixelSize: 14
                    font.bold: true
                    color: "#000000"
                }
            }
        }

        // --- 4. TOTAL PRICE SUMMARY ---
        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            Text {
                text: "Total: MWK" + delegateRoot.price
                font.pixelSize: 13
                color: "#000000"
            }

            // Text {
            //     text: "MWK" + delegateRoot.roomPrice
            //     font.pixelSize: 14
            //     font.bold: true
            //     color: "#000000"
            // }
        }

        // --- 5. ACTION BUTTONS ROW ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // LEFT BUTTONS: Contact & Details
            Rectangle {
                implicitWidth: 75
                implicitHeight: 32
                radius: 16
                border.color: "#CCCCCC"
                border.width: 1
                color: "transparent"

                // Text {
                //     anchors.centerIn: parent
                //     text: "Contact"
                //     font.pixelSize: 12
                //     font.bold: true
                //     color: "#000000"
                // }
                ToolButton{
                    anchors.centerIn: parent
                    icon.source: "qrc:/ui/assets/message-icon.svg"
                    icon.height: 16
                    icon.width: 16
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: delegateRoot.contactRequested()
                }
            }

            Rectangle {
                implicitWidth: 70
                implicitHeight: 32
                radius: 16
                border.color: "#CCCCCC"
                border.width: 1
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "Details"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#000000"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                        delegateRoot.detailsRequested({
                                                        bookingId: delegateRoot.bookingId,
                                                        status: delegateRoot.status,
                                                        houseName: delegateRoot.houseName,
                                                        clientName: delegateRoot.clientName,
                                                        clientPhone: delegateRoot.clientPhone,
                                                        checkIn: delegateRoot.checkIn,
                                                        roomPrice: delegateRoot.price,
                                                        //propertyImage: delegateRoot.propertyImage,
                                                          //bookingId: data.bookingId || "",
                                                          //status: data.status || "",
                                                          //houseName: data.propertyName || "",
                                                          propertyLocation: delegateRoot.propertyLocation,
                                                               //readonly property string propertyImage: model.propertyImage ?? "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=500"
                                                          roomType: delegateRoot.roomType,

                                                         // clientName: data.clientName || "John Doe",
                                                         // clientPhone: data.clientPhone || "+1 555-0192",
                                                          clientEmail: delegateRoot.clientEmail,
                                                               //readonly property int guestCount: model.guestCount ?? 3

                                                          //checkIn: data.checkIn || "Oct 12, 2026 (2:00 PM)",
                                                          //checkOut: model.checkOut || "Oct 15, 2026 (11:00 AM)"
                                                          //nightsCount: model.nightsCount ?? 3
                                                          //clientNotes: model.clientNotes ?? "Please provide an extra crib if available. Late check-in expected."

                                                          baseAmount: delegateRoot.baseAmount,
                                                          serviceFee: delegateRoot.serviceFee,
                                                          totalAmount: delegateRoot.totalAmount,
                                                          paymentStatus: delegateRoot.paymentStatus
                                                          //paymentMethod: delegateRoot.pay
                                                         //paymentDate: data.paymentDate || "Oct 10, 2026"

                                                                      // Pull remaining fields directly from model roles (with defaults)

                                                      })
                    }
                }
            }

            // Flexible space pushes primary actions to the right
            Item { Layout.fillWidth: true }

            // RIGHT BUTTONS: Primary Status Actions (Approve, Reject, Cancel)
            Rectangle {
                visible: delegateRoot.status === "Pending"
                implicitWidth: 75
                implicitHeight: 32
                radius: 16
                border.color: "#000000"
                border.width: 1
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "Reject"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#000000"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        delegateRoot.rejectRequested()
                        if (typeof index !== "undefined") agentBookingsModel.setProperty(index, "status", "Rejected")
                    }
                }
            }

            Rectangle {
                visible: delegateRoot.status === "Pending"
                implicitWidth: 85
                implicitHeight: 32
                radius: 16
                border.color: "#E11D48"
                border.width: 1
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "Approve"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#E11D48"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        delegateRoot.approveRequested()
                        if (typeof index !== "undefined") agentBookingsModel.setProperty(index, "status", "Approved")
                    }
                }
            }

            Rectangle {
                visible: delegateRoot.status === "Approved"
                implicitWidth: 120
                implicitHeight: 32
                radius: 16
                border.color: "#E11D48"
                border.width: 1
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "Cancel Booking"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#E11D48"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        delegateRoot.cancelRequested()
                        if (typeof index !== "undefined") agentBookingsModel.setProperty(index, "status", "Cancelled")
                    }
                }
            }
        }
    }
}