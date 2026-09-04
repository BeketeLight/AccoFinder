import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root
    width: 355
    height: 190

    Layout.alignment: Qt.AlignHCenter
    // ========== DUMMY DATA ==========
    ListModel {
        id: dummyDeals

        ListElement {
            propertyId: "deal_1"
            title: "Modern 2 Bedroom Apartment"
            location: "Area 47, Lilongwe"
            price: 450000
            imageUrl: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&h=400&fit=crop"
        }
        ListElement {
            propertyId: "deal_2"
            title: "Spacious 3 Bedroom House"
            location: "Nyambadwe, Blantyre"
            price: 780000
            imageUrl: "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop"
        }
        ListElement {
            propertyId: "deal_3"
            title: "Luxury Studio Apartment"
            location: "City Centre, Lilongwe"
            price: 320000
            imageUrl: "https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=600&h=400&fit=crop"
        }
        ListElement {
            propertyId: "deal_4"
            title: "Executive 2 Bedroom Flat"
            location: "Area 10, Lilongwe"
            price: 550000
            imageUrl: "https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=600&h=400&fit=crop"
        }
    }

    // Fixed card width
    readonly property int cardWidth: 220
    readonly property int cardSpacing: 12

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Label {
                text: "🔥 Super Deals"
                font.pixelSize: 16
                font.bold: true
                color: "#1F2937"
                Layout.fillWidth: true
            }
        }

        // Horizontal ListView with peek effect
        ListView {
            id: dealsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 12
            clip: true
            model: dummyDeals

            // === This creates the peek effect ===
            preferredHighlightBegin: (width - root.cardWidth) / 2
            preferredHighlightEnd: (width - root.cardWidth) / 2 /*+ root.cardWidth*/
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 250
            snapMode: ListView.SnapToItem

            delegate: Item {
                width: root.cardWidth          // full card width
                height: dealsList.height
                Rectangle {
                    id: borderRect
                    anchors.fill: parent
                    border.color: "#E5E7EB"
                    color: "transparent"
                    border.width: 1.5
                    radius: 16

                    // Rounded Image
                    Image {
                        id: img
                        anchors.fill: parent
                        anchors.margins: borderRect.border.width
                        source: model.imageUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true

                        layer.enabled: true
                        layer.smooth: true
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: mask
                        }
                        clip: true
                    }

                    // Mask
                    Rectangle {
                        id: mask
                        anchors.fill: parent
                        anchors.margins: borderRect.border.width
                        radius: 16
                        color: "black"
                        visible: false
                        layer.enabled: true
                        layer.smooth: true
                    }
                }
            }
        }
    }
}
