import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 350
    height: 190
    anchors {
        right: parent.right
        left: parent.left
    }
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

            Label {
                text: (dealsSwipe.currentIndex + 1) + " / " + dealsSwipe.count
                font.pixelSize: 13
                color: "#6B7280"
            }
        }

        // SwipeView
        SwipeView {
            id: dealsSwipe
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            padding: 12
            spacing: 5

            Repeater {
                model: dummyDeals

                Rectangle {
                    width: dealsSwipe.width - 24
                    height: dealsSwipe.height
                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#E5E7EB"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        // Image
                        Rectangle {
                            Layout.preferredWidth: 120
                            Layout.fillHeight: true
                            radius: 8
                            color: "#F5F5F5"
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: model.imageUrl
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                        }

                        // Info
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4

                            Label {
                                text: "MWK " + Number(model.price).toLocaleString(Qt.locale(), "f", 0)
                                font.pixelSize: 15
                                font.bold: true
                                color: "#2563EB"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Label {
                                text: model.title
                                font.pixelSize: 13
                                color: "#1F2937"
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Label {
                                text: model.location
                                font.pixelSize: 12
                                color: "#6B7280"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }
                }
            }
        }

        // Dots
        PageIndicator {
            Layout.alignment: Qt.AlignHCenter
            count: dealsSwipe.count
            currentIndex: dealsSwipe.currentIndex

            delegate: Rectangle {
                width: 7
                height: 7
                radius: 4
                color: index === dealsSwipe.currentIndex ? "#2563EB" : "#D1D5DB"
            }
        }
    }
}
