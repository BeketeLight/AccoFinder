import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"
Rectangle {
    id: delegateRoot
    // --- MODEL PROPERTIES WITH AUTOMATIC FALLBACKS ---
        property string bookingId: model.bookingId ?? ""
        property string houseName: model.houseName ?? "Hostel/Apartment"
        property string imageUrl: model.propertyImage ?? model.imageUrl ?? ""
        property string status: model.status ?? "Pending"
        property string clientName: model.clientName ?? "Guest"
        property string clientPhone: model.clientPhone ?? "N/A"
        property string dateRange: model.bookingDate ?? model.dateRange ?? "N/A"
        property string price: model.amount ? model.amount.toString() : (model.price ?? "0")

        property string propertyLocation: model.location ?? ""
        property string roomType: model.roomType ?? "Standard Room"
        property string clientEmail: model.clientEmail ?? ""

        property double baseAmount: model.amount ?? 0.0
        property double serviceFee: model.commissionAmount ?? 0.0
        property double totalAmount: baseAmount + serviceFee
        property bool isLoading: clientName === "" || clientName === "Loading..." || houseName === ""
    // --- ACTIVE FILTER PROP ---
    property string activeFilter: "All"

    // --- SIGNALS ---
    signal approveRequested()
    signal rejectRequested()
    signal cancelRequested()
    signal contactRequested()
    signal detailsRequested(var data)

    // --- VISIBILITY & HEIGHT COLLAPSE ---
    //visible: activeFilter === "View all" || status === activeFilter
    visible: model.matches ?? true
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
                id: imageContainer
                Layout.preferredWidth: 80
                Layout.preferredHeight: 100
                radius: 8
                color: "#F0F0F0"
                clip: true

                Image {
                    id: propImage
                    anchors.fill: parent
                    source: delegateRoot.imageUrl !== "" ? delegateRoot.imageUrl : "qrc:/assets/placeholder.png"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                }
                MultiEffect {
                    anchors.fill: propImage
                    source: propImage
                    maskEnabled: true
                    maskThresholdMin: 0.5

                    // This clips the effect to a rounded rectangle
                    maskSource: ShaderEffectSource {
                        sourceItem: Rectangle {
                            width: imageContainer.width
                            height: imageContainer.height
                            radius: imageContainer.radius
                            color: "black"
                            }
                    }
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
            // Rectangle {
            //     implicitWidth: 75
            //     implicitHeight: 32
            //     radius: 16
            //     border.color: "#CCCCCC"
            //     border.width: 1
            //     color: "transparent"

            //     // Text {
            //     //     anchors.centerIn: parent
            //     //     text: "Contact"
            //     //     font.pixelSize: 12
            //     //     font.bold: true
            //     //     color: "#000000"
            //     // }
            //     ToolButton{
            //         anchors.centerIn: parent
            //         icon.source: "qrc:/ui/assets/message-icon.svg"
            //         icon.height: 16
            //         icon.width: 16
            //     }

            //     MouseArea {
            //         anchors.fill: parent
            //         onClicked: delegateRoot.contactRequested()
            //     }
            // }

            Rectangle {
                implicitWidth: 150
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
                        checkIn: delegateRoot.dateRange,
                        roomPrice: delegateRoot.price,
                        propertyImage: delegateRoot.imageUrl,
                        propertyLocation: delegateRoot.propertyLocation,
                        //readonly property string propertyImage: model.propertyImage ?? "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=500"
                        roomType: delegateRoot.roomType,
                        clientEmail: delegateRoot.clientEmail,
                        baseAmount: delegateRoot.baseAmount,
                        serviceFee: delegateRoot.serviceFee,
                        totalAmount: delegateRoot.totalAmount,
                        paymentStatus: delegateRoot.paymentStatus
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
        // ColumnLayout {
        //         // anchors.fill: parent
        //         // anchors.margins: 12
        //     Layout.top: parent.top
        //     Layout.right: parent.right
        //     Layout.top: parent.top
        //         spacing: 12
        //         visible: delegateRoot.isLoading

        //         // Top Status Header Placeholder
        //         RowLayout {
        //             Layout.fillWidth: true
        //             LoadingSkeleton {
        //                 Layout.preferredWidth: 80
        //                 Layout.preferredHeight: 18
        //                 loading: delegateRoot.isLoading
        //             }
        //         }

        //         // House Name Placeholder
        //         LoadingSkeleton {
        //             Layout.preferredWidth: 140
        //             Layout.preferredHeight: 16
        //             loading: delegateRoot.isLoading
        //         }

        //         // Content Row Placeholder
        //         RowLayout {
        //             Layout.fillWidth: true
        //             spacing: 12

        //             // Image Placeholder
        //             LoadingSkeleton {
        //                 Layout.preferredWidth: 80
        //                 Layout.preferredHeight: 100
        //                 radius: 8
        //                 loading: delegateRoot.isLoading
        //             }
        //         }
        // }
    }
}