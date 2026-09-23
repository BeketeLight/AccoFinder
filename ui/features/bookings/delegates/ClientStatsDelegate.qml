import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../models"
Rectangle {
    id: delegateRoot

    // --- REQUIRED MODEL PROPERTIES ---
    property string bookingId: ""
    property string houseName: ""
    property string imageUrl: ""
    property string status: ""
    property string dateText: ""
    property string details: ""
    property string dates: ""
    property string totalPrice: ""
    property string landlordName: ""

    // --- ACTIVE FILTER PROP (FOR INLINE LISTVIEW FILTERING) ---
    property string activeFilter: "View all"

    // --- INTERACTION SIGNALS ---
    signal removeRequested()
    signal viewDetailsRequested()

    // --- VISIBILITY & LAYOUT BEHAVIOR ---
    visible: activeFilter === "View all" || status === activeFilter
    width: ListView.view ? ListView.view.width : parent.width
    implicitHeight: visible ? cardContent.implicitHeight + 24 : 0
    color: "#FFFFFF"

    ColumnLayout {
        id: cardContent
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // --- 1. HEADER ROW: STATUS & CREATION DATE ---
        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            Text {
                text: delegateRoot.status
                font.pixelSize: 12
                font.bold: true
                color: {
                    switch(delegateRoot.status) {
                        case "Approved": return "#16A34A"
                        case "Pending": return "#D97706"
                        case "Cancelled": return "#DC2626"
                        default: return "#888888"
                    }
                }
            }
        }

        // --- 2. LANDLORD / STORE BADGE ---
        RowLayout {
            spacing: 6

            Text {
                text: delegateRoot.landlordName
                font.bold: true
                font.pixelSize: 14
                color: "#000000"
            }
        }

        // --- 3. MAIN CONTENT: THUMBNAIL & PROPERTY INFO ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                id: imageContainer
                implicitWidth: 80
                implicitHeight: 80
                radius: 8
                color: "#F0F0F0"
                clip: true

                Image {
                    id: propImage
                    anchors.fill: parent
                    source: delegateRoot.imageUrl
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

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: delegateRoot.houseName
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
                    text: delegateRoot.details
                    font.pixelSize: 12
                    color: "#888888"
                }

                Text {
                    text: "Date: " + delegateRoot.dates
                    font.pixelSize: 12
                    color: "#888888"
                }

                Text {
                    text:delegateRoot.totalPrice
                    font.bold: true
                    font.pixelSize: 14
                    color: "#000000"
                }
            }
        }

        // // --- 4. PRICE SUMMARY LINE ---
        // RowLayout {
        //     Layout.fillWidth: true

        //     Item { Layout.fillWidth: true }

        //     Text {
        //         text: delegateRoot.totalPrice
        //         font.bold: true
        //         font.pixelSize: 13
        //         color: "#000000"
        //     }
        // }

        // --- 5. DYNAMIC ACTION BUTTONS ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Item { Layout.fillWidth: true }

            // Left Action Button (Remove / Cancel Request)
            Rectangle {
                implicitWidth: 110
                implicitHeight: 32
                radius: 16
                border.color: "#000000"
                border.width: 1
                color: leftBtnArea.pressed ? "#F1F5F9" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: delegateRoot.status === "Pending" ? "Cancel Request" : "Remove"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#000000"
                }

                MouseArea {
                    id: leftBtnArea
                    anchors.fill: parent
                    onClicked: delegateRoot.removeRequested()
                }
            }

            // Right Action Button (View Details)
            Rectangle {
                implicitWidth: 120
                implicitHeight: 32
                radius: 16
                border.color: "#2563EB"
                border.width: 1
                color: rightBtnArea.pressed ? "#EFF6FF" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "View details"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#2563EB"
                }

                MouseArea {
                    id: rightBtnArea
                    anchors.fill: parent
                    onClicked: delegateRoot.viewDetailsRequested()
                }
            }
        }
    }
}