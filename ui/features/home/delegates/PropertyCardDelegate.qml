import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string propertyId: ""
    property string title: ""
    property string location: ""
    property real price: 0
    property string imageUrl: ""
    property string imageUrls: ""
    property string status: "PENDING"
    property bool isVerified: false
    property bool isInfoSectionVisible: true
    property bool insideInfoSection: false
    property var amenities: []

    property real rating: 4.5          // e.g. 4.5
    property int reviewCount: 12       // e.g. 12 reviews

    signal clicked
    signal favoriteClicked

    // Remove fixed width/height - let the GridView control this
    // width: 100  // REMOVE THIS
    // height: 240 // REMOVE THIS

    Column {
        anchors.fill: parent
        spacing: 4  // Small gap between image and price

        //IMAGE
        Rectangle {
            id: borderRect
            width: parent.width
            height: (parent.height + 10) - (root.isInfoSectionVisible ? 52 : 0)
            border.color: "#E5E7EB"
            border.width: 2.5
            radius: 8
            clip: true

            RemoteImage {
                id: img
                anchors.fill: parent
                anchors.margins: borderRect.border.width
                remoteUrl: root.imageUrl.length > 0 ? root.imageUrl : (root.imageUrls.length > 0 ? String(root.imageUrls).split(",")[0] : "")
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                opacity: status === Image.Ready ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }

                layer.enabled: true
                layer.smooth: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: mask
                }
            }

            // Rounded mask
            Rectangle {
                id: mask
                anchors.fill: parent
                anchors.margins: borderRect.border.width
                radius: 8
                visible: false
                layer.enabled: true
                layer.smooth: true
            }

            // ===== SKELETON LOADER (shown while loading) =====
            Rectangle {
                id: skeleton
                anchors.fill: parent
                anchors.margins: borderRect.border.width
                radius: 8
                visible: img.status !== Image.Ready
                color: "#E5E7EB"
                clip: true

                // Moving shimmer bar
                Rectangle {
                    id: shimmer
                    width: parent.width * 0.45
                    height: parent.height
                    color: "#F9FAFB"
                    radius: 8
                    opacity: 0.7
                    x: -width

                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        running: skeleton.visible
                        NumberAnimation {
                            from: -shimmer.width
                            to: skeleton.width
                            duration: 1000
                            easing.type: Easing.InOutQuad
                        }
                        PauseAnimation {
                            duration: 200
                        }
                    }
                }

                // Optional soft icon while loading
                // Label {
                //     anchors.centerIn: parent
                //     text: "🏠"
                //     font.pixelSize: 28
                //     opacity: 0.25
                // }
            }
            // ---- Info overlay (bottom of the image) ----
            Rectangle {
                id: insideRectangleInfo
                visible: root.insideInfoSection && img.status === Image.Ready

                // Pin to the image, not the border rectangle. Cleaner geometry and
                // it stays inside the rounded image mask.
                anchors {
                    left: img.left
                    right: img.right
                    bottom: img.bottom
                }

                // Height grows with content; padding is baked into the layout below.
                implicitHeight: insideInfoContent.implicitHeight + 28   // 14 top + 14 bottom

                // Rounded only on the bottom to match the image corners.
                radius: 8
                // Square off the top so it reads as a footer, not a floating pill.
                topLeftRadius: 0
                topRightRadius: 0

                // Dark gradient so any image behind it stays legible. Solid `#00000080`
                // also works, but a gradient reads as "designed" rather than "patched on".
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#00000000"
                    }
                    GradientStop {
                        position: 0.35
                        color: "#00000088"
                    }
                    GradientStop {
                        position: 1.0
                        color: "#000000CC"
                    }
                }

                // Content
                ColumnLayout {
                    id: insideInfoContent
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        leftMargin: 14
                        rightMargin: 14
                        bottomMargin: 12
                    }
                    spacing: 2

                    // ---- Title (top of the card, most prominent) ----
                    Label {
                        Layout.fillWidth: true
                        text: root.title.length > 0 ? root.title : "Untitled property"
                        color: "#FFFFFF"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    // ---- Location with a small pin ----
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        visible: root.location.length > 0

                        // Pin icon (unicode; swap for an SVG if you prefer)
                        Label {
                            text: "\uD83D\uDCCD"      // 📍
                            font.pixelSize: 11
                            color: "#E5E7EB"
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.location
                            color: "#E5E7EB"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // ---- Bottom row: price (left) + rating (right) ----
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 6
                        spacing: 8

                        // Price badge — a small pill that makes the number pop
                        Rectangle {
                            visible: root.price > 0
                            implicitHeight: 24
                            implicitWidth: priceLabel.implicitWidth + 16
                            radius: 12
                            color: "#2563EB"   // primary blue; swap for your brand colour

                            Label {
                                id: priceLabel
                                anchors.centerIn: parent
                                text: "MWK " + Number(root.price).toLocaleString(Qt.locale(), "f", 0)
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }   // spacer

                        // Rating badge
                        RowLayout {
                            visible: root.reviewCount > 0
                            spacing: 3
                            Layout.alignment: Qt.AlignVCenter

                            Label {
                                text: "\u2605"      // ★
                                color: "#F59E0B"
                                font.pixelSize: 13
                            }
                            Label {
                                text: root.rating.toFixed(1)
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }
                            Label {
                                text: "(" + root.reviewCount + ")"
                                color: "#D1D5DB"
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
        }

        // INFO SECTION
        Column {
            id: infoSection
            width: parent.width
            spacing: 0
            leftPadding: 2
            rightPadding: 2
            visible: root.isInfoSectionVisible

            // Price
            Label {
                width: parent.width
                text: "MWK " + Number(root.price).toLocaleString(Qt.locale(), "f", 0)
                font.pixelSize: 12
                font.bold: true
                color: "#2563EB"
                elide: Text.ElideRight
                visible: root.price ? true : false
            }

            // Location
            Label {
                width: parent.width
                text: root.location
                font.pixelSize: 11
                color: "#6B7280"
                elide: Text.ElideRight
            }

            // Property Title
            Label {
                text: root.title
                width: parent.width
                font.pixelSize: 11
                color: "#F59E0B"          // amber/gold
                elide: Text.ElideRight
            }
        }

        // ========== PRICE ==========
        // Label {
        //     width: parent.width
        //     height: 20  // Fixed height for price
        //     text: "MWK " + Number(root.price).toLocaleString(Qt.locale(), "f", 0)
        //     font.pixelSize: 14
        //     font.bold: true
        //     color: "#2563EB"
        //     elide: Text.ElideRight
        //     horizontalAlignment: Text.AlignHCenter
        //     verticalAlignment: Text.AlignVCenter
        // }
    }

    // Click area
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            NavUtils.push(Qt.resolvedUrl("./PropertyDelegateDetails.qml"), {
                propertyId: root.propertyId,
                propertyTitle: root.title,
                location: root.location,
                price: root.price,
                status: root.status,
                isVerified: root.isVerified,
                amenities: root.amenities
            });
            root.clicked();
        }
    }
}
