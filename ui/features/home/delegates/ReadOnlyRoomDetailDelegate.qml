import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../../utils/ImageUtils.js" as ImageUtils
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../utils/Utils.js" as Utils
import "../../../components/indicators/"
import "../../properties/components"

Page {
    id: root
    // ========== HEADER CONTROL ==========
    property string pageTitle: ""
    property bool isSearchBar: true
    property bool showBack: true
    property bool showHeader: true
    property bool searchReadOnly: false

    // ========== ROOMREADONLY DATA ==========
    property string roomType: ""
    // Media - images and videos
    property string roomImage: ""
    property var mediaList: []

    // ========== SIGNALS ==========
    signal backRequested

    // Helper function to handle JS arrays, strings, or ListModels
    function getMediaArray() {
        if (Array.isArray(mediaList) && mediaList.length > 0) {
            return mediaList;
        } else if (typeof mediaList === "string" && mediaList.length > 0) {
            return [mediaList];
        } else if (roomImage.length > 0) {
            return [roomImage];
        }
        return [];
    }

    function goBack() {
        root.backRequested();
        NavUtils.pop();
    }

    background: Rectangle {
        color: "#FFFFFF"
    }

    // ========== CONTENT ==========
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

            // ===== MEDIA CAROUSEL =====
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 300

                SwipeView {
                    id: mediaSwipe
                    anchors.fill: parent
                    clip: true

                    Repeater {
                        id: mediaModel
                        model: root.getMediaArray()

                        Item {
                            required property var modelData

                            property bool isVideo: typeof modelData === "string" && modelData.match(/\.(mp4|mov|avi|mkv|webm)$/i) !== null
                            Image {
                                id: pageImage
                                anchors.fill: parent
                                source: isVideo ? "" : ImageUtils.cachedSource(modelData)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: !isVideo

                                Rectangle {
                                    anchors.fill: parent
                                    color: "#F5F5F5"
                                    visible: parent.status !== Image.Ready
                                    Label {
                                        anchors.centerIn: parent
                                        text: "🖼️"
                                        font.pixelSize: 40
                                        opacity: 0.3
                                    }
                                }
                            }
                            // Shimmer while photo loads
                            Rectangle {
                                id: skeleton
                                anchors.fill: parent
                                visible: !isVideo && pageImage.status !== Image.Ready
                                color: "#E5E7EB"
                                clip: true

                                Rectangle {
                                    id: shimmer
                                    width: parent.width * 0.45
                                    height: parent.height
                                    color: "#F9FAFB"
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
                            }

                            // Video placeholder
                            Rectangle {
                                anchors.fill: parent
                                color: "#1A1A1A"
                                visible: isVideo

                                Label {
                                    anchors.centerIn: parent
                                    text: "▶️"
                                    font.pixelSize: 60
                                    color: "white"
                                }

                                Label {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.margins: 20
                                    text: "Video"
                                    color: "white"
                                    font.pixelSize: 14
                                    opacity: 0.7
                                }
                            }
                        }
                    }
                }
                // Media counter
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
                        text: (mediaSwipe.currentIndex + 1) + " / " + Math.max(mediaSwipe.count, 1)
                        color: "white"
                        font.pixelSize: 12
                    }
                }

                // Media type indicator
                Rectangle {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 20
                    anchors.bottomMargin: 12
                    height: 24
                    radius: 12
                    color: "#80000000"
                    width: mediaTypeText.width + 16

                    Label {
                        id: mediaTypeText
                        anchors.centerIn: parent
                        text: mediaSwipe.currentItem ? (mediaSwipe.currentItem.isVideo ? "🎥 Video" : "📷 Photo") : "📷 Photo"
                        color: "white"
                        font.pixelSize: 12
                    }
                }
            }
            // Bottom spacer
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
            }
        }
    }

    Component.onCompleted: {
        if (root.propertyId.length > 0) {
            ReviewViewModel.loadForProperty(root.propertyId);
            ReviewViewModel.loadSummary(root.propertyId);
            if (AppSettings.isLoggedIn()) {
                ReviewViewModel.checkCanReview(root.propertyId);
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
