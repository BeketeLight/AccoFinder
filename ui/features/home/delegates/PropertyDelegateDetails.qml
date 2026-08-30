import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import "../../../components/inputs"
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root

    // ========== CONTROL THE SHARED APP HEADER ==========
    property string pageTitle: ""
    property bool isSearchBar: true
    property bool showBack: true
    property bool showHeader: true
    property bool searchReadOnly: false

    function onSearchBarTapped() {
        root.searchRequested();
    }

    function goBack() {
        root.backRequested();
        NavUtils.pop();
    }

    // ========== DATA (pass from Screen) ==========
    property string propertyId: ""
    property string propertyTitle: "Modern 2 Bedroom Apartment"
    property string location: "Area 47, Lilongwe"
    property real price: 450000
    property string status: "Available"
    property bool isVerified: true
    property string description: "Spacious and well-lit apartment located in a quiet neighborhood. Close to shops, schools and public transport. Ideal for small families or professionals."
    property int bedrooms: 2
    property int bathrooms: 1
    property string size: "85 m²"
    property string agentName: "John Banda"
    property string agentPhone: "+265 999 123 456"

    // Signals
    signal backRequested
    signal bookRequested
    signal contactRequested
    signal favoriteToggled
    signal searchRequested

    background: Rectangle {
        color: "#FFFFFF"
    }

    // ========== SCROLLABLE CONTENT ==========
    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: contentColumn
            width: flickable.width
            spacing: 0

            // ========== IMAGE CAROUSEL ==========
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 320

                SwipeView {
                    id: imageSwipe
                    anchors.fill: parent
                    clip: true

                    // Example images (replace with real model later)
                    Repeater {
                        model: 4
                        Rectangle {
                            color: "#F5F5F5"
                            Label {
                                anchors.centerIn: parent
                                text: "🏠\nPhoto " + (index + 1)
                                font.pixelSize: 28
                                horizontalAlignment: Text.AlignHCenter
                                color: "#9CA3AF"
                            }
                        }
                    }
                }

                // Image counter
                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 12
                    height: 24
                    radius: 12
                    color: "#80000000"
                    width: counterText.width + 16

                    Label {
                        id: counterText
                        anchors.centerIn: parent
                        text: (imageSwipe.currentIndex + 1) + " / " + imageSwipe.count
                        color: "white"
                        font.pixelSize: 12
                    }
                }

                // Status badge
                // Rectangle {
                //     // anchors.right: parent.right
                //     // anchors.top: parent.top
                //     // anchors.margins: 12
                //     anchors.centerIn: parent
                //     height: 26
                //     radius: 8
                //     color: "red"
                //     //color: root.status === "Available" ? "#DCFCE7" : root.status === "Booked" ? "#FEE2E2" : "#FEF3C7"

                //     Label {
                //         anchors.centerIn: parent
                //         leftPadding: 10
                //         rightPadding: 10
                //         text: root.status
                //         font.pixelSize: 12
                //         font.bold: true
                //         color: root.status === "Available" ? "#16A34A" : root.status === "Booked" ? "#DC2626" : "#D97706"
                //     }
                // }
            }

            // ========== MAIN INFO ==========
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 10

                // Title
                Label {
                    text: root.propertyTitle
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: "#1F2937"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                // Location
                RowLayout {
                    spacing: 4
                    Label {
                        text: "📍"
                        font.pixelSize: 14
                    }
                    Label {
                        text: root.location
                        font.pixelSize: 14
                        color: "#6B7280"
                    }
                }

                // Price
                Label {
                    text: "MWK " + Number(root.price).toLocaleString(Qt.locale(), "f", 0)
                    font.pixelSize: 26
                    font.bold: true
                    color: "#2563EB"          // Primary
                }

                // Quick specs
                RowLayout {
                    spacing: 16
                    Layout.topMargin: 4

                    SpecItem {
                        icon: "🛏"
                        label: root.bedrooms + " Beds"
                    }

                    SpecItem {
                        icon: "🛁"
                        label: root.bathrooms + " Baths"
                    }

                    SpecItem {
                        icon: "📐"
                        label: root.size
                    }

                    Label {
                        visible: root.isVerified
                        text: "✓ Verified"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#22C55E"
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 8
                color: "#F5F5F5"
            }

            // ========== DESCRIPTION ==========
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 8

                Label {
                    text: "Description"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#1F2937"
                }

                Label {
                    text: root.description
                    font.pixelSize: 14
                    color: "#4B5563"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    lineHeight: 1.35
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 8
                color: "#F5F5F5"
            }

            // ========== AGENT ==========
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 10

                Label {
                    text: "Listed by"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#1F2937"
                }

                RowLayout {
                    spacing: 12

                    Rectangle {
                        width: 48
                        height: 48
                        radius: 24
                        color: "#DBEAFE"

                        Label {
                            anchors.centerIn: parent
                            text: root.agentName.charAt(0)
                            font.pixelSize: 20
                            font.bold: true
                            color: "#2563EB"
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Label {
                            text: root.agentName
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            color: "#1F2937"
                        }
                        Label {
                            text: "Property Agent"
                            font.pixelSize: 13
                            color: "#6B7280"
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "Contact"
                        flat: true
                        onClicked: root.contactRequested()

                        background: Rectangle {
                            radius: 8
                            color: "#EFF6FF"
                            border.color: "#2563EB"
                        }
                        contentItem: Label {
                            text: parent.text
                            color: "#2563EB"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // Bottom spacing so content is not hidden behind footer
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
            }
        }
    }

    // ========== STICKY BOTTOM ACTION BAR ==========
    footer: ToolBar {
        height: 72
        background: Rectangle {
            color: "#FFFFFF"
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: "#E5E7EB"
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            // Contact button (secondary)
            Button {
                Layout.preferredWidth: 120
                Layout.fillHeight: true
                text: "Contact"

                background: Rectangle {
                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#2563EB"
                    border.width: 1.5
                }
                contentItem: Label {
                    text: parent.text
                    color: "#2563EB"
                    font.pixelSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: root.contactRequested()
            }

            // Book Now (primary)
            Button {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Book Now"

                background: Rectangle {
                    radius: 12
                    color: "#2563EB"          // Primary
                }
                contentItem: Label {
                    text: parent.text
                    color: "#FFFFFF"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: root.bookRequested()
            }
        }
    }

    // ========== HELPER ==========
    component SpecItem: RowLayout {
        property string icon
        property string label
        spacing: 4

        Label {
            text: icon
            font.pixelSize: 14
        }
        Label {
            text: label
            font.pixelSize: 13
            color: "#4B5563"
        }
    }
}
