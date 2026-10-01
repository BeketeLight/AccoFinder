import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils

Rectangle {
    id: root
    anchors.fill: parent
    color: "#F4F6F9"

    readonly property bool isGuest: !AppSettings.isLoggedIn()
    readonly property bool isClient: AppSettings.isLoggedIn() && AppSettings.userType() === "CLIENT"
    readonly property bool isAgent: AppSettings.isLoggedIn() && AppSettings.userType() === "AGENT"

    // --- GUEST VIEW BANNER ---
    ColumnLayout {
        anchors.fill: parent
        visible: root.isGuest
        //Layout.visible: visible
        spacing: 16

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            color: "#2563EB"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: qsTr("Welcome to AccoFinder")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#FFFFFF"
                }
                Text {
                    text: qsTr("Sign in to manage or view your bookings.")
                    color: "#E0F2FE"
                }
                Button {
                    text: qsTr("Sign in / Register")
                    onClicked: NavUtils.navigateToSignIn()
                }
            }
        }
    }

    // --- LOGGED-IN ROLE ROUTER ---
    Loader {
        anchors.fill: parent
        visible: !root.isGuest
        source: {
            if (root.isAgent)  return "BookingOverviewAgentPage.qml"  ///BookingOverviewAgentPage.qml
            if (root.isClient) return "BookingOverviewClientPage.qml"//
            return ""
        }
    }
}

// import QtQuick 2.15
// import QtQuick.Controls
// import QtQuick.Layouts
// import QtQuick.Effects
// import "../components"

// Page {
//     id: detailsPage
//     width: 390
//     height: 844
//     background:Rectangle{color: "#F8F9FB"}

//     // --- DATA MODEL / PASSED PARAMETERS ---
//     property bool isLoading: false

//     property string bookingId: "BK-2026-8812"
//     property string status: "Confirmed"
//     property string houseName: "KU FUMBI HOSTELS"
//     property string location: "Lilongwe, Area 25"
//     property string reservationType: "Standard Reservation"
//     property string checkInDate: "20 Sep 2026"
//     property string bookingDate: "12 Sep 2026"
//     property string roomType: "Standard Room"
//     property string roomPrice: "MWK 40,000"
//     property string commissionPrice: "MWK 2,000"
//     property string totalPrice: "MWK 42,000"
//     property string paymentStatus: "Paid"
//     property string hostName: "Michael Chang"
//     property string hostPhone: "0999 XXX XXX"
//     property string hostAvatar: "qrc:/assets/host_avatar.png"
//     property string propertyImage: "qrc:/assets/hostel_main.jpg"

//     // --- SIGNALS ---
//     signal backRequested()
//     signal cancelBookingRequested()
//     signal contactHostRequested()
//     signal viewMapRequested()

//     // ==========================================
//     // TOP NAVIGATION HEADER
//     // ==========================================
//     header: ToolBar {
//         background: Rectangle { color: "#F8F9FB" }
//         height: 56

//         RowLayout {
//             anchors.fill: parent
//             anchors.leftMargin: 16
//             anchors.rightMargin: 16

//             Rectangle {
//                 implicitWidth: 36
//                 implicitHeight: 36
//                 radius: 18
//                 color: "transparent"

//                 Text {
//                     anchors.centerIn: parent
//                     text: "❮"
//                     font.pixelSize: 18
//                     font.bold: true
//                     color: "#0F172A"
//                 }

//                 MouseArea {
//                     anchors.fill: parent
//                     onClicked: detailsPage.backRequested()
//                 }
//             }

//             Text {
//                 text: "Booking Details"
//                 font.pixelSize: 18
//                 font.bold: true
//                 color: "#0F172A"
//                 Layout.leftMargin: 8
//             }

//             Item { Layout.fillWidth: true }

//             // Top Status Badge
//             Rectangle {
//                 implicitWidth: badgeText.implicitWidth + 24
//                 implicitHeight: 28
//                 radius: 14
//                 color: "#E6F4EA"
//                 border.color: "#A8DADC"
//                 border.width: 0.5

//                 RowLayout {
//                     anchors.centerIn: parent
//                     spacing: 6

//                     Rectangle {
//                         width: 6
//                         height: 6
//                         radius: 3
//                         color: "#1E8E3E"
//                     }

//                     Text {
//                         id: badgeText
//                         text: detailsPage.status
//                         font.pixelSize: 12
//                         font.bold: true
//                         color: "#1E8E3E"
//                     }
//                 }
//             }
//         }
//     }

//     // ==========================================
//     // MAIN SCROLLABLE CONTENT
//     // ==========================================
//     Flickable {
//         id: mainFlickable
//         anchors.fill: parent
//         contentHeight: mainContent.implicitHeight + 32
//         clip: true

//         // ------------------------------------------
//         // 1. POPULATED DATA VIEW
//         // ------------------------------------------
//         ColumnLayout {
//             id: mainContent
//             anchors.left: parent.left
//             anchors.right: parent.right
//             anchors.top: parent.top
//             anchors.margins: 16
//             spacing: 16
//             opacity: detailsPage.isLoading ? 0 : 1
//             visible: opacity > 0

//             Behavior on opacity {
//                 NumberAnimation { duration: 250 }
//             }

//             // --- HERO CARD: PROPERTY BANNER & TITLE ---
//             Rectangle {
//                 Layout.fillWidth: true
//                 implicitHeight: propertyColumn.implicitHeight + 16
//                 radius: 16
//                 color: "#FFFFFF"

//                 ColumnLayout {
//                     id: propertyColumn
//                     anchors.left: parent.left
//                     anchors.right: parent.right
//                     anchors.top: parent.top
//                     spacing: 12

//                     // Top Image Banner
//                     Rectangle {
//                         id: imageWrapper
//                         Layout.fillWidth: true
//                         Layout.preferredHeight: 180
//                         radius: 16
//                         clip: true

//                         Image {
//                             id: mainImg
//                             anchors.fill: parent
//                             source: detailsPage.propertyImage
//                             fillMode: Image.PreserveAspectCrop
//                             asynchronous: true
//                         }

//                         // Image Counter Tag
//                         Rectangle {
//                             anchors.right: parent.right
//                             anchors.bottom: parent.bottom
//                             anchors.margins: 12
//                             implicitWidth: 44
//                             implicitHeight: 20
//                             radius: 10
//                             color: "#80000000"

//                             Text {
//                                 anchors.centerIn: parent
//                                 text: "1/5"
//                                 font.pixelSize: 10
//                                 color: "#FFFFFF"
//                             }
//                         }
//                     }

//                     // Property Titles
//                     ColumnLayout {
//                         Layout.fillWidth: true
//                         Layout.leftMargin: 12
//                         Layout.rightMargin: 12
//                         Layout.bottomMargin: 12
//                         spacing: 4

//                         Text {
//                             text: detailsPage.houseName
//                             font.pixelSize: 16
//                             font.bold: true
//                             color: "#0F172A"
//                         }

//                         RowLayout {
//                             spacing: 4
//                             Text { text: "📍"; font.pixelSize: 11 }
//                             Text {
//                                 text: detailsPage.location
//                                 font.pixelSize: 12
//                                 color: "#64748B"
//                             }
//                         }

//                         Rectangle {
//                             implicitWidth: resText.implicitWidth + 16
//                             implicitHeight: 22
//                             radius: 6
//                             color: "#F1F5F9"
//                             Layout.topMargin: 4

//                             Text {
//                                 id: resText
//                                 anchors.centerIn: parent
//                                 text: detailsPage.reservationType
//                                 font.pixelSize: 11
//                                 color: "#475569"
//                             }
//                         }
//                     }
//                 }
//             }

//             // --- CONFIRMATION BANNER ---
//             Rectangle {
//                 Layout.fillWidth: true
//                 implicitHeight: 60
//                 radius: 12
//                 color: "#E6F4EA"

//                 RowLayout {
//                     anchors.fill: parent
//                     anchors.margins: 12
//                     spacing: 12

//                     Rectangle {
//                         implicitWidth: 32
//                         implicitHeight: 32
//                         radius: 16
//                         color: "#1E8E3E"

//                         Text {
//                             anchors.centerIn: parent
//                             text: "✓"
//                             font.pixelSize: 16
//                             font.bold: true
//                             color: "#FFFFFF"
//                         }
//                     }

//                     ColumnLayout {
//                         spacing: 2
//                         Text {
//                             text: "Booking Confirmed"
//                             font.pixelSize: 13
//                             font.bold: true
//                             color: "#1E8E3E"
//                         }
//                         Text {
//                             text: "Your reservation is confirmed."
//                             font.pixelSize: 11
//                             color: "#2D6A4F"
//                         }
//                     }
//                 }
//             }

//             // --- RESERVATION DETAILS CARD ---
//             Rectangle {
//                 Layout.fillWidth: true
//                 implicitHeight: resCol.implicitHeight + 24
//                 radius: 12
//                 color: "#FFFFFF"

//                 ColumnLayout {
//                     id: resCol
//                     anchors.left: parent.left
//                     anchors.right: parent.right
//                     anchors.top: parent.top
//                     anchors.margins: 12
//                     spacing: 12

//                     RowLayout {
//                         spacing: 8
//                         Text { text: "📄"; font.pixelSize: 14 }
//                         Text {
//                             text: "Reservation Details"
//                             font.pixelSize: 14
//                             font.bold: true
//                             color: "#0F172A"
//                         }
//                     }

//                     GridLayout {
//                         columns: 2
//                         Layout.fillWidth: true
//                         columnSpacing: 24
//                         rowSpacing: 12

//                         // Col 1
//                         ColumnLayout {
//                             spacing: 2
//                             Text { text: "Booking ID"; font.pixelSize: 11; color: "#64748B" }
//                             Text { text: detailsPage.bookingId; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
//                         }

//                         // Col 2
//                         ColumnLayout {
//                             spacing: 2
//                             Text { text: "Check-in"; font.pixelSize: 11; color: "#64748B" }
//                             Text { text: detailsPage.checkInDate; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
//                         }

//                         // Row 2 Col 1
//                         ColumnLayout {
//                             spacing: 2
//                             Text { text: "Booking date"; font.pixelSize: 11; color: "#64748B" }
//                             Text { text: detailsPage.bookingDate; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
//                         }

//                         // Row 2 Col 2
//                         ColumnLayout {
//                             spacing: 2
//                             Text { text: "Room"; font.pixelSize: 11; color: "#64748B" }
//                             Text { text: detailsPage.roomType; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
//                         }
//                     }
//                 }
//             }

//             // --- LOCATION CARD ---
//             Rectangle {
//                 Layout.fillWidth: true
//                 implicitHeight: locCol.implicitHeight + 24
//                 radius: 12
//                 color: "#FFFFFF"

//                 ColumnLayout {
//                     id: locCol
//                     anchors.left: parent.left
//                     anchors.right: parent.right
//                     anchors.top: parent.top
//                     anchors.margins: 12
//                     spacing: 12

//                     RowLayout {
//                         Layout.fillWidth: true

//                         ColumnLayout {
//                             spacing: 4
//                             RowLayout {
//                                 spacing: 6
//                                 Text { text: "📍"; font.pixelSize: 14 }
//                                 Text { text: "Location"; font.pixelSize: 14; font.bold: true; color: "#0F172A" }
//                             }
//                             Text {
//                                 text: detailsPage.location
//                                 font.pixelSize: 12
//                                 color: "#64748B"
//                                 Layout.leftMargin: 20
//                             }
//                         }

//                         Item { Layout.fillWidth: true }

//                         // Map Thumbnail
//                         Rectangle {
//                             implicitWidth: 70
//                             implicitHeight: 40
//                             radius: 6
//                             color: "#E2E8F0"
//                             clip: true

//                             Text {
//                                 anchors.centerIn: parent
//                                 text: "🗺️"
//                                 font.pixelSize: 18
//                             }
//                         }
//                     }

//                     Rectangle {
//                         Layout.fillWidth: true
//                         implicitHeight: 36
//                         radius: 18
//                         border.color: "#2563EB"
//                         border.width: 1
//                         color: "transparent"

//                         RowLayout {
//                             anchors.centerIn: parent
//                             spacing: 6
//                             Text { text: "🗺️"; font.pixelSize: 12 }
//                             Text {
//                                 text: "View on Map"
//                                 font.pixelSize: 12
//                                 font.bold: true
//                                 color: "#2563EB"
//                             }
//                         }

//                         MouseArea {
//                             anchors.fill: parent
//                             onClicked: detailsPage.viewMapRequested()
//                         }
//                     }
//                 }
//             }

//             // --- PAYMENT SUMMARY CARD ---
//             Rectangle {
//                 Layout.fillWidth: true
//                 implicitHeight: payCol.implicitHeight + 24
//                 radius: 12
//                 color: "#FFFFFF"

//                 ColumnLayout {
//                     id: payCol
//                     anchors.left: parent.left
//                     anchors.right: parent.right
//                     anchors.top: parent.top
//                     anchors.margins: 12
//                     spacing: 12

//                     RowLayout {
//                         spacing: 8
//                         Text { text: "💳"; font.pixelSize: 14 }
//                         Text { text: "Payment Summary"; font.pixelSize: 14; font.bold: true; color: "#0F172A" }
//                     }

//                     RowLayout {
//                         Layout.fillWidth: true

//                         ColumnLayout {
//                             spacing: 6
//                             RowLayout {
//                                 Text { text: "Room price"; font.pixelSize: 12; color: "#64748B" }
//                                 Item { Layout.fillWidth: true }
//                                 Text { text: detailsPage.roomPrice; font.pixelSize: 12; font.bold: true; color: "#0F172A" }
//                             }
//                             RowLayout {
//                                 Text { text: "Commission"; font.pixelSize: 12; color: "#64748B" }
//                                 Item { Layout.fillWidth: true }
//                                 Text { text: detailsPage.commissionPrice; font.pixelSize: 12; font.bold: true; color: "#0F172A" }
//                             }
//                         }

//                         Rectangle {
//                             implicitWidth: 1
//                             implicitHeight: 36
//                             color: "#E2E8F0"
//                             Layout.leftMargin: 12
//                             Layout.rightMargin: 12
//                         }

//                         ColumnLayout {
//                             spacing: 4
//                             Text { text: "Payment status"; font.pixelSize: 11; color: "#64748B" }

//                             Rectangle {
//                                 implicitWidth: payStatusText.implicitWidth + 20
//                                 implicitHeight: 22
//                                 radius: 11
//                                 color: "#E6F4EA"

//                                 RowLayout {
//                                     anchors.centerIn: parent
//                                     spacing: 4
//                                     Text { text: "✓"; font.pixelSize: 10; color: "#1E8E3E"; font.bold: true }
//                                     Text {
//                                         id: payStatusText
//                                         text: detailsPage.paymentStatus
//                                         font.pixelSize: 11
//                                         font.bold: true
//                                         color: "#1E8E3E"
//                                     }
//                                 }
//                             }
//                         }
//                     }

//                     Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#F1F5F9" }

//                     RowLayout {
//                         Layout.fillWidth: true
//                         Text { text: "Total"; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
//                         Item { Layout.fillWidth: true }
//                         Text { text: detailsPage.totalPrice; font.pixelSize: 15; font.bold: true; color: "#0F172A" }
//                     }
//                 }
//             }

//             // --- PROPERTY HOST CARD ---
//             Rectangle {
//                 Layout.fillWidth: true
//                 implicitHeight: hostRow.implicitHeight + 24
//                 radius: 12
//                 color: "#FFFFFF"

//                 ColumnLayout {
//                     id: hostCol
//                     anchors.left: parent.left
//                     anchors.right: parent.right
//                     anchors.top: parent.top
//                     anchors.margins: 12
//                     spacing: 8

//                     RowLayout {
//                         spacing: 8
//                         Text { text: "👤"; font.pixelSize: 14 }
//                         Text { text: "Property Host"; font.pixelSize: 14; font.bold: true; color: "#0F172A" }
//                     }

//                     RowLayout {
//                         id: hostRow
//                         Layout.fillWidth: true
//                         spacing: 12

//                         Rectangle {
//                             implicitWidth: 44
//                             implicitHeight: 44
//                             radius: 22
//                             color: "#E2E8F0"
//                             clip: true

//                             Image {
//                                 anchors.fill: parent
//                                 source: detailsPage.hostAvatar
//                                 fillMode: Image.PreserveAspectCrop
//                             }
//                         }

//                         ColumnLayout {
//                             spacing: 2
//                             Text { text: detailsPage.hostName; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
//                             Text { text: "📞 " + detailsPage.hostPhone; font.pixelSize: 11; color: "#64748B" }
//                         }

//                         Item { Layout.fillWidth: true }

//                         Rectangle {
//                             implicitWidth: 110
//                             implicitHeight: 32
//                             radius: 16
//                             border.color: "#2563EB"
//                             border.width: 1
//                             color: "transparent"

//                             RowLayout {
//                                 anchors.centerIn: parent
//                                 spacing: 4
//                                 Text { text: "📞"; font.pixelSize: 11 }
//                                 Text { text: "Contact Host"; font.pixelSize: 11; font.bold: true; color: "#2563EB" }
//                             }

//                             MouseArea {
//                                 anchors.fill: parent
//                                 onClicked: detailsPage.contactHostRequested()
//                             }
//                         }
//                     }
//                 }
//             }

//             // --- BOOKING TIMELINE CARD ---
//             Rectangle {
//                 Layout.fillWidth: true
//                 implicitHeight: timeCol.implicitHeight + 24
//                 radius: 12
//                 color: "#FFFFFF"

//                 ColumnLayout {
//                     id: timeCol
//                     anchors.left: parent.left
//                     anchors.right: parent.right
//                     anchors.top: parent.top
//                     anchors.margins: 12
//                     spacing: 12

//                     RowLayout {
//                         spacing: 8
//                         Text { text: "🕐"; font.pixelSize: 14 }
//                         Text { text: "Booking Timeline"; font.pixelSize: 14; font.bold: true; color: "#0F172A" }
//                     }

//                     ColumnLayout {
//                         Layout.fillWidth: true
//                         spacing: 10

//                         Repeater {
//                             model: [
//                                 { label: "Booking created", date: "12 Sep 2026, 10:32", active: true },
//                                 { label: "Payment received", date: "12 Sep 2026, 10:35", active: true },
//                                 { label: "Booking confirmed", date: "12 Sep 2026, 11:02", active: true },
//                                 { label: "Check-in", date: "20 Sep 2026", active: false }
//                             ]

//                             RowLayout {
//                                 Layout.fillWidth: true
//                                 spacing: 12

//                                 Rectangle {
//                                     implicitWidth: 8
//                                     implicitHeight: 8
//                                     radius: 4
//                                     color: modelData.active ? "#10B981" : "#CBD5E1"
//                                 }

//                                 Text {
//                                     text: modelData.label
//                                     font.pixelSize: 12
//                                     color: modelData.active ? "#0F172A" : "#64748B"
//                                     font.bold: modelData.active
//                                 }

//                                 Item { Layout.fillWidth: true }

//                                 Text {
//                                     text: modelData.date
//                                     font.pixelSize: 11
//                                     color: "#94A3B8"
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }

//             // --- CANCEL ACTION BUTTON ---
//             Rectangle {
//                 Layout.fillWidth: true
//                 implicitHeight: 44
//                 radius: 22
//                 border.color: "#F43F5E"
//                 border.width: 1
//                 color: "transparent"

//                 RowLayout {
//                     anchors.centerIn: parent
//                     spacing: 6
//                     Text { text: "🗑️"; font.pixelSize: 13 }
//                     Text {
//                         text: "Cancel Booking"
//                         font.pixelSize: 13
//                         font.bold: true
//                         color: "#F43F5E"
//                     }
//                 }

//                 MouseArea {
//                     anchors.fill: parent
//                     onClicked: detailsPage.cancelBookingRequested()
//                 }
//             }
//         }

//         // ------------------------------------------
//         // 2. SKELETON SHIMMER OVERLAY (Parallel Layout)
//         // ------------------------------------------
//         ColumnLayout {
//             id: skeletonContent
//             anchors.left: parent.left
//             anchors.right: parent.right
//             anchors.top: parent.top
//             anchors.margins: 16
//             spacing: 16
//             visible: detailsPage.isLoading

//             // Hero Image Placeholder
//             Rectangle {
//                 Layout.fillWidth: true
//                 implicitHeight: 260
//                 radius: 16
//                 color: "#FFFFFF"

//                 ColumnLayout {
//                     anchors.fill: parent
//                     spacing: 12

//                     LoadingSkeleton {
//                         Layout.fillWidth: true
//                         Layout.preferredHeight: 180
//                         radius: 16
//                         loading: detailsPage.isLoading
//                     }

//                     ColumnLayout {
//                         Layout.fillWidth: true
//                         Layout.margins: 12
//                         spacing: 8

//                         LoadingSkeleton { Layout.preferredWidth: 200; Layout.preferredHeight: 18; loading: detailsPage.isLoading }
//                         LoadingSkeleton { Layout.preferredWidth: 130; Layout.preferredHeight: 14; loading: detailsPage.isLoading }
//                     }
//                 }
//             }

//             // Confirmation Banner Placeholder
//             LoadingSkeleton {
//                 Layout.fillWidth: true
//                 Layout.preferredHeight: 60
//                 radius: 12
//                 loading: detailsPage.isLoading
//             }

//             // Cards Placeholders
//             Repeater {
//                 model: 4
//                 Rectangle {
//                     Layout.fillWidth: true
//                     implicitHeight: 120
//                     radius: 12
//                     color: "#FFFFFF"

//                     ColumnLayout {
//                         anchors.fill: parent
//                         anchors.margins: 12
//                         spacing: 12

//                         LoadingSkeleton { Layout.preferredWidth: 140; Layout.preferredHeight: 16; loading: detailsPage.isLoading }
//                         LoadingSkeleton { Layout.fillWidth: true; Layout.preferredHeight: 14; loading: detailsPage.isLoading }
//                         LoadingSkeleton { Layout.preferredWidth: 220; Layout.preferredHeight: 14; loading: detailsPage.isLoading }
//                     }
//                 }
//             }

//             // Button Placeholder
//             LoadingSkeleton {
//                 Layout.fillWidth: true
//                 Layout.preferredHeight: 44
//                 radius: 22
//                 loading: detailsPage.isLoading
//             }
//         }
//     }
// }