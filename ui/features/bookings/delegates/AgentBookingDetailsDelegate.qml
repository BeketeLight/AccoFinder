import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"
import "../../../components/buttons"

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

    property string clientName: ""
    property string clientPhone: ""
    property string clientEmail: ""
    property string clientInitial: ""
    property int guestCount: 0

    property string checkIn: ""
    property real price: 0.0
    property real commission: 0.0
    property string paymentStatus: ""
    property string paymentMethod: ""
    property string paymentDate: ""

    property string createdTime: ""

    // --- SIGNALS ---
    signal contactHostRequested()
    signal viewMapRequested()

        // ------------------------------------------
        // 1. POPULATED DATA VIEW
        // ------------------------------------------
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
                    spacing: 12

                    RowLayout {
                        spacing: 8
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
                        ColumnLayout {
                            spacing: 2
                            Text { text: "Booking date"; font.pixelSize: 13; color:"#0F172A"  }
                            Text { text: detailsPage.checkIn; font.pixelSize: 11; color:  "#64748B"}
                        }
                        ColumnLayout {
                            spacing: 2
                            Text { text: "Room Type"; font.pixelSize: 13; color: "#0F172A" }
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
                    spacing: 12

                    RowLayout {
                        spacing: 2
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
                            RowLayout {
                                Text { text: "Commission Earned"; font.pixelSize: 12; color: "#2563EB" }
                                Item { Layout.fillWidth: true }
                                Rectangle{
                                    width: commTextId.width + 8
                                    height: commTextId.height + 8
                                    radius: 8
                                    color: "#2563EB"

                                    Text {
                                        id: commTextId
                                        anchors.centerIn: parent
                                        text:"MWK1000000" //detailsPage.commission
                                        font.pixelSize: 10
                                        font.bold: true
                                        color: "#FFFFFF"
                                    }
                                }

                            }
                            // RowLayout {
                            //     Text { text: "Commission"; font.pixelSize: 12; color: "#64748B" }
                            //     Item { Layout.fillWidth: true }
                            //     Text { text: detailsPage.commissionPrice; font.pixelSize: 12; font.bold: true; color: "#0F172A" }
                            // }
                        }

                        Rectangle {
                            implicitWidth: 1
                            implicitHeight: 36
                            color: "#E2E8F0"
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                        }

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Payment status"; font.pixelSize: 11; color: "#64748B" }

                            Rectangle {
                                implicitWidth: payStatusText.implicitWidth + 20
                                implicitHeight: 22
                                radius: 11
                                color: "#E6F4EA"

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text { text: "✓"; font.pixelSize: 10; color: "#1E8E3E"; font.bold: true }
                                    Text {
                                        id: payStatusText
                                        text: detailsPage.paymentStatus
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: "#1E8E3E"
                                    }
                                }
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

            // --- PROPERTY CLIENT CARD ---
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
                    spacing: 8

                    RowLayout {
                        spacing: 8
                        RowLayout {
                            spacing: 0
                            ToolButton{
                                icon.source: "qrc:/ui/assets/account-icon.svg"
                                icon.height: 12
                                icon.width: 12
                                background: null
                            }
                            Text { text: "Client Info"; font.pixelSize: 14; font.bold: true; color: "#0F172A" }
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

                            // Image {
                            //     anchors.fill: parent
                            //     source: detailsPage.hostAvatar
                            //     fillMode: Image.PreserveAspectCrop
                            // }
                            Text{
                                anchors.centerIn: parent
                                text: detailsPage.clientInitial
                                color: "#2563EB"
                                font.pointSize: 16
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Text { text: detailsPage.clientName; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
                            Text { text: "📞 " + detailsPage.clientPhone; font.pixelSize: 11; color: "#64748B" }
                        }

                       // Item { Layout.fillWidth: true }
                    }
                }
            }

            // --- BOOKING TIMELINE CARD ---
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: timeCol.implicitHeight + 24
                radius: 12
                color: "#FFFFFF"
                border.color: "#E2E8F0"
                border.width: 1

                ColumnLayout {
                    id: timeCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 12

                    RowLayout {
                        spacing: 8
                        ToolButton{
                            icon.source: "qrc:/ui/assets/timeline-icon.svg"
                            icon.height: 12
                            icon.width: 12
                            background: null
                        }
                        Text { text: "Booking Timeline"; font.pixelSize: 14; font.bold: true; color: "#0F172A" }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Repeater {
                            model: [
                                { label: "Booking created", date: detailsPage.checkIn, active: true },
                                { label: "Payment received", date: "12 Sep 2026, 10:35", active: true },
                                { label: "Booking confirmed", date: "12 Sep 2026, 11:02", active: true },
                            ]

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Rectangle {
                                    implicitWidth: 8
                                    implicitHeight: 8
                                    radius: 4
                                    color: modelData.active ? "#10B981" : "#CBD5E1"
                                }

                                Text {
                                    text: modelData.label
                                    font.pixelSize: 12
                                    color: modelData.active ? "#0F172A" : "#64748B"
                                    font.bold: modelData.active
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: modelData.date
                                    font.pixelSize: 11
                                    color: "#94A3B8"
                                }
                            }
                        }
                    }
                }
            }

            // --- APPROVE ACTION BUTTON ---
            Rectangle {
                visible: detailsPage.status === "Pending"
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
                    onClicked: detailsPage.cancelBookingRequested()
                }
            }
        }

        // ------------------------------------------
        // 2. SKELETON SHIMMER OVERLAY (Parallel Layout)
        // ------------------------------------------
        ColumnLayout {
            id: skeletonContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 16
            visible: detailsPage.isLoading

            // Hero Image Placeholder
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 260
                radius: 16
                color: "#FFFFFF"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    LoadingSkeleton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        radius: 16
                        loading: detailsPage.isLoading
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.margins: 12
                        spacing: 8

                        LoadingSkeleton { Layout.preferredWidth: 200; Layout.preferredHeight: 18; loading: detailsPage.isLoading }
                        LoadingSkeleton { Layout.preferredWidth: 130; Layout.preferredHeight: 14; loading: detailsPage.isLoading }
                    }
                }
            }

            // Confirmation Banner Placeholder
            LoadingSkeleton {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                radius: 12
                loading: detailsPage.isLoading
            }

            // Cards Placeholders
            Repeater {
                model: 4
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    radius: 12
                    color: "#FFFFFF"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        LoadingSkeleton { Layout.preferredWidth: 140; Layout.preferredHeight: 16; loading: detailsPage.isLoading }
                        LoadingSkeleton { Layout.fillWidth: true; Layout.preferredHeight: 14; loading: detailsPage.isLoading }
                        LoadingSkeleton { Layout.preferredWidth: 220; Layout.preferredHeight: 14; loading: detailsPage.isLoading }
                    }
                }
            }

            // Button Placeholder
            LoadingSkeleton {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 22
                loading: detailsPage.isLoading
            }
        }
   // }
}