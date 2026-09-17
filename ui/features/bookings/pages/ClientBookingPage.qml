import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: clientPage
    background: Rectangle { color: "#F5F5F5" }

    // --- DUMMY DATA MODEL ---
    ListModel {
        id: clientBookingsModel
        ListElement {
            bookingId: "BK-8001"
            houseName: "MIT Hostels"
            imageUrl: "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=300"
            status: "Approved"
            dateText: "Aug 31, 2026"
            details: "2 Bedrooms • Entire Villa"
            dates: "Sep 20 - Sep 25, 2026"
            totalPrice: "MKW40000.00"
            landlordName: "MIT"
        }
        ListElement {
            bookingId: "BK-8002"
            houseName: "Maloto Affodable Hostels"
            imageUrl: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=300"
            status: "Pending"
            dateText: "Aug 30, 2026"
            details: "1 Bedroom • Studio Apartment"
            dates: "Oct 12 - Oct 15, 2026"
            totalPrice: "MKW175000.00"
            landlordName: "Maloto"
        }
        ListElement {
            bookingId: "BK-8003"
            houseName: "Mwaiwathu hostels"
            imageUrl: "https://images.unsplash.com/photo-1598228723793-52759bba239c?w=300"
            status: "Cancelled"
            dateText: "Aug 15, 2026"
            details: "1 Bedroom • Garden View"
            dates: "Aug 18 - Aug 20, 2026"
            totalPrice: "MKW50000.00"
            landlordName: "Mr Last Coin."
        }
    }

    // Dynamic filtering proxy list logic
    property string activeTab: "View all"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        // --- 2. TOP FILTER TABS ---
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 44
            color: "#FFFFFF"

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: ["View all", "Pending", "Approved", "Cancelled"]

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData
                                font.bold: clientPage.activeTab === modelData
                                font.pixelSize: 14
                                color: clientPage.activeTab === modelData ? "#000000" : "#666666"
                            }

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                implicitWidth: 30
                                implicitHeight: 3
                                color: "blue"
                                radius: 2
                                visible: clientPage.activeTab === modelData
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: clientPage.activeTab = modelData
                        }
                    }
                }
            }
        }

        // --- 3. BOOKINGS LIST ---
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            topMargin: 8
            bottomMargin: 16
            spacing: 10
            clip: true

            model: clientBookingsModel

            delegate: Rectangle {
                // Filter out non-matching tabs
                visible: clientPage.activeTab === "View all" || model.status === clientPage.activeTab
                width: listView.width
                implicitHeight: visible ? cardContent.implicitHeight + 24 : 0
                color: "#FFFFFF"

                ColumnLayout {
                    id: cardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    // Header Row: Status & Creation Date
                    RowLayout {
                        Layout.fillWidth: true

                        // Text {
                        //     text: model.status
                        //     font.bold: true
                        //     font.pixelSize: 15
                        //     color: "#000000"
                        // }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: model.status
                            font.pixelSize: 12
                            color: "#888888"
                        }
                    }

                    // Property Store Header Badge
                    RowLayout {
                        spacing: 6

                        // Rectangle {
                        //     implicitWidth: 46
                        //     implicitHeight: 18
                        //     radius: 3
                        //     color: "#FFC107"

                        //     Text {
                        //         anchors.centerIn: parent
                        //         text: "Choice"
                        //         font.pixelSize: 10
                        //         font.bold: true
                        //         color: "#000000"
                        //     }
                        // }

                        Text {
                            text: model.landlordName
                            font.bold: true
                            font.pixelSize: 14
                            color: "#000000"
                        }
                    }

                    // Main Content: Thumbnail + Info
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            implicitWidth: 80
                            implicitHeight: 80
                            radius: 8
                            color: "#F0F0F0"
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: model.imageUrl
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: model.houseName
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#222222"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "›"
                                    font.pixelSize: 14
                                    color: "#666666"
                                }
                            }

                            Text {
                                text: model.details
                                font.pixelSize: 12
                                color: "#888888"
                            }

                            Text {
                                text: "Dates: " + model.dates
                                font.pixelSize: 12
                                color: "#888888"
                            }

                            Text {
                                text: model.totalPrice
                                font.bold: true
                                font.pixelSize: 14
                                color: "#000000"
                            }
                        }
                    }

                    // Price Summary Line
                    RowLayout {
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }
                        // Text {
                        //     text: "Total for 1 stay: "
                        //     font.pixelSize: 12
                        //     color: "#000000"
                        // }
                        Text {
                            text: model.totalPrice
                            font.bold: true
                            font.pixelSize: 13
                            color: "#000000"
                        }
                    }

                    // Action Buttons Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Item { Layout.fillWidth: true }
                        //left Button
                        Rectangle {
                            implicitWidth: 100
                            implicitHeight: 32
                            radius: 16
                            border.color: "#000000"
                            border.width: 1
                            color: "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if(model.status === "Pending") return "Cancel Request"
                                    if(model.status === "Approved") return "Remove"
                                    if(model.status === "Cancelled") return "Remove"
                                }
                                font.pixelSize: 12
                                font.bold: true
                                color: "#000000"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: clientBookingsModel.remove(index)
                            }
                        }
                        //RightButtn
                        Rectangle {
                            implicitWidth: 120
                            implicitHeight: 32
                            radius: 16
                            border.color: "#2563EB"
                            border.width: 1
                            color: "transparent"

                            Text {
                                anchors.centerIn: parent
                                text:{
                                    if(model.status === "Approved") return "View details"
                                    if(model.status === "Cancelled") return "View details"
                                    if(model.status === "Pending") return "View details"
                                }
                                color: "#2563EB"
                            }
                            MouseArea{
                                anchors.fill: parent
                                /// to be used to Navigate to bookingssdetails
                            }
                        }
                    }
                }
            }
        }
    }
}



// import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts
// import "../../../utils/NavigationUtils.js" as NavUtils
// Page {
//     id: agentPage
//     background: Rectangle { color: "#F5F5F5" }

//     // --- AGENT BOOKINGS DATA MODEL ---
//     ListModel {
//         id: agentBookingsModel
//         ListElement {
//             bookingId: "BK-1001"
//             houseName: "Sunset Lake Villa"
//             imageUrl: "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=300"
//             clientName: "John Doe"
//             clientPhone: "+1 555-0192"
//             status: "Pending"
//             dateRange: "Oct 12 - Oct 15, 2026"
//             price: "$450"
//             checkoutPassed: false
//         }
//         ListElement {
//             bookingId: "BK-1002"
//             houseName: "Modern Downtown Apartment"
//             imageUrl: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=300"
//             clientName: "Sarah Connor"
//             clientPhone: "+1 555-0144"
//             status: "Approved"
//             dateRange: "Nov 01 - Nov 05, 2026"
//             price: "$600"
//             checkoutPassed: false
//         }
//         ListElement {
//             bookingId: "BK-1003"
//             houseName: "Cozy Garden Studio"
//             imageUrl: "https://images.unsplash.com/photo-1598228723793-52759bba239c?w=300"
//             clientName: "Michael Smith"
//             clientPhone: "+1 555-0188"
//             status: "Approved"
//             dateRange: "Sep 01 - Sep 05, 2026"
//             price: "$180"
//             checkoutPassed: true // Ready for "Mark as Completed"
//         }
//     }

//     property string activeTab: "View all"

//     ColumnLayout {
//         anchors.fill: parent
//         spacing: 0

//         // --- FILTER TABS ---
//         Rectangle {
//             Layout.fillWidth: true
//             implicitHeight: 44
//             color: "#FFFFFF"

//             RowLayout {
//                 anchors.fill: parent
//                 spacing: 0

//                 Repeater {
//                     model: ["View all", "Pending", "Approved", "Completed", "Rejected"]

//                     Item {
//                         Layout.fillWidth: true
//                         Layout.fillHeight: true

//                         Column {
//                             anchors.centerIn: parent
//                             spacing: 4

//                             Text {
//                                 text: modelData
//                                 font.bold: agentPage.activeTab === modelData
//                                 font.pixelSize: 13
//                                 color: agentPage.activeTab === modelData ? "#000000" : "#666666"
//                             }

//                             Rectangle {
//                                 anchors.horizontalCenter: parent.horizontalCenter
//                                 implicitWidth: 28
//                                 implicitHeight: 3
//                                 color: "#000000"
//                                 visible: agentPage.activeTab === modelData
//                             }
//                         }

//                         MouseArea {
//                             anchors.fill: parent
//                             onClicked: agentPage.activeTab = modelData
//                         }
//                     }
//                 }
//             }
//         }

//         // --- BOOKINGS LIST ---
//         ListView {
//             id: listView
//             Layout.fillWidth: true
//             Layout.fillHeight: true
//             topMargin: 8
//             bottomMargin: 16
//             spacing: 10
//             clip: true

//             model: agentBookingsModel

//             delegate: Rectangle {
//                 visible: agentPage.activeTab === "View all" || model.status === agentPage.activeTab
//                 width: listView.width
//                 implicitHeight: visible ? cardContent.implicitHeight + 24 : 0
//                 color: "#FFFFFF"

//                 ColumnLayout {
//                     id: cardContent
//                     anchors.fill: parent
//                     anchors.margins: 12
//                     spacing: 10

//                     // Header Row: Status Badge & Booking ID
//                     RowLayout {
//                         Layout.fillWidth: true

//                         Rectangle {
//                             implicitWidth: statusText.implicitWidth + 14
//                             implicitHeight: 22
//                             radius: 11
//                             color: model.status === "Pending" ? "#FEF3C7" :
//                                   (model.status === "Approved" ? "#DCFCE7" :
//                                   (model.status === "Completed" ? "#E0F2FE" : "#FEE2E2"))

//                             Text {
//                                 id: statusText
//                                 anchors.centerIn: parent
//                                 text: model.status
//                                 font.pixelSize: 11
//                                 font.bold: true
//                                 color: model.status === "Pending" ? "#D97706" :
//                                       (model.status === "Approved" ? "#16A34A" :
//                                       (model.status === "Completed" ? "#0284C7" : "#E11D48"))
//                             }
//                         }

//                         Item { Layout.fillWidth: true }

//                         Text {
//                             text: model.bookingId
//                             font.pixelSize: 12
//                             color: "#888888"
//                         }
//                     }

//                     // Main Content: Property Image + Client Details
//                     RowLayout {
//                         Layout.fillWidth: true
//                         spacing: 12

//                         Rectangle {
//                             implicitWidth: 80
//                             implicitHeight: 80
//                             radius: 16
//                             color: "#F0F0F0"
//                             clip: true

//                             Image {
//                                 anchors.fill: parent
//                                 source: model.imageUrl
//                                 fillMode: Image.PreserveAspectCrop
//                             }
//                         }

//                         ColumnLayout {
//                             Layout.fillWidth: true
//                             spacing: 3

//                             Text {
//                                 text: model.houseName
//                                 font.pixelSize: 14
//                                 font.bold: true
//                                 color: "#0F172A"
//                             }

//                             Text {
//                                 text: "Client: " + model.clientName
//                                 font.pixelSize: 12
//                                 font.bold: true
//                                 color: "#334155"
//                             }

//                             Text {
//                                 text: "Dates: " + model.dateRange
//                                 font.pixelSize: 12
//                                 color: "#64748B"
//                             }

//                             Text {
//                                 text: "Total: " + model.price
//                                 font.pixelSize: 13
//                                 font.bold: true
//                                 color: "#0F172A"
//                             }
//                         }
//                     }

//                     // ACTION BUTTONS ROW (Mapped to Table Tasks)
//                     RowLayout {
//                         Layout.fillWidth: true
//                         spacing: 6

//                         // Contact Client Button (Any status)
//                         Rectangle {
//                             implicitWidth: 90
//                             implicitHeight: 32
//                             radius: 16
//                             border.color: "#CBD5E1"
//                             color: "transparent"

//                             // Text {
//                             //     anchors.centerIn: parent
//                             //     text: "💬 Contact"
//                             //     font.pixelSize: 11
//                             //     font.bold: true
//                             //     color: "#334155"
//                             // }
//                             ToolButton{
//                                 anchors.centerIn: parent
//                                 icon.source: "qrc:/ui/assets/message-icon.svg"
//                                 icon.width: 16
//                                 icon.height: 16
//                                 background: null
//                             }

//                             MouseArea {
//                                 anchors.fill: parent
//                                 onClicked: console.log("Contacting: " + model.clientPhone)
//                             }
//                         }

//                         // View Details Button (Any status)
//                         Rectangle {
//                             implicitWidth: 80
//                             implicitHeight: 32
//                             radius: 16
//                             border.color: "#CBD5E1"
//                             color: "transparent"

//                             Text {
//                                 anchors.centerIn: parent
//                                 text: "Details"
//                                 font.pixelSize: 11
//                                 font.bold: true
//                                 color: "#334155"
//                             }
//                             MouseArea{
//                                 anchors.fill: parent
//                                 onClicked: NavUtils.navigateToBookingDetails()
//                             }
//                         }

//                         Item { Layout.fillWidth: true }

//                         // --- CONDITIONAL AGENT ACTIONS ---

//                         // Action: Reject (Pending)
//                         Rectangle {
//                             visible: model.status === "Pending"
//                             implicitWidth: 70
//                             implicitHeight: 32
//                             radius: 16
//                             border.color: "#E11D48"
//                             color: "transparent"

//                             Text {
//                                 anchors.centerIn: parent
//                                 text: "Reject"
//                                 font.pixelSize: 11
//                                 font.bold: true
//                                 color: "#E11D48"
//                             }

//                             MouseArea {
//                                 anchors.fill: parent
//                                 onClicked: agentBookingsModel.setProperty(index, "status", "Rejected")
//                             }
//                         }

//                         // Action: Approve (Pending)
//                         Rectangle {
//                             visible: model.status === "Pending"
//                             implicitWidth: 80
//                             implicitHeight: 32
//                             radius: 16
//                             color: "#16A34A"

//                             Text {
//                                 anchors.centerIn: parent
//                                 text: "Approve"
//                                 font.pixelSize: 11
//                                 font.bold: true
//                                 color: "#FFFFFF"
//                             }

//                             MouseArea {
//                                 anchors.fill: parent
//                                 onClicked: agentBookingsModel.setProperty(index, "status", "Approved")
//                             }
//                         }

//                         // Action: Cancel (Approved/Confirmed)
//                         Rectangle {
//                             visible: model.status === "Approved" && !model.checkoutPassed
//                             implicitWidth: 70
//                             implicitHeight: 32
//                             radius: 16
//                             border.color: "#E11D48"
//                             color: "transparent"

//                             Text {
//                                 anchors.centerIn: parent
//                                 text: "Cancel"
//                                 font.pixelSize: 11
//                                 font.bold: true
//                                 color: "#E11D48"
//                             }

//                             MouseArea {
//                                 anchors.fill: parent
//                                 onClicked: agentBookingsModel.setProperty(index, "status", "Cancelled")
//                             }
//                         }

//                         // Action: Mark as Completed (Post Checkout)
//                         Rectangle {
//                             visible: model.status === "Approved" && model.checkoutPassed
//                             implicitWidth: 120
//                             implicitHeight: 32
//                             radius: 16
//                             color: "#0284C7"

//                             Text {
//                                 anchors.centerIn: parent
//                                 text: "Mark Completed"
//                                 font.pixelSize: 11
//                                 font.bold: true
//                                 color: "#FFFFFF"
//                             }

//                             MouseArea {
//                                 anchors.fill: parent
//                                 onClicked: agentBookingsModel.setProperty(index, "status", "Completed")
//                             }
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }