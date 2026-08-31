import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Full-screen photo viewer for reviewing property images.
//
// Shows one image at a time with:
//   - flick / prev / next buttons to browse through the images
//   - pinch to zoom and drag to pan while zoomed in
//   - double-tap to toggle zoom
//   - a close (X) button to dismiss
//
// Remote image URLs are routed through the CachedImageProvider
// ("image://cached/"), so the lightbox reuses the pixels already decoded
// by the thumbnails — it opens instantly with no second network request.
//
// Usage:
//   AppImageLightbox {
//       id: viewer
//       images: someListOrModel  // urls or {url|path} maps
//       title: "Property photos"
//   }
//   viewer.openAt(index)   // or viewer.open = true
Item {
    id: root

    property var images: []
    property int currentIndex: 0
    property string title: ""
    property bool open: false

    readonly property bool hasImages: !!root.images && root.images.length > 0

    signal closed

    function wrapRemote(src) {
        if (!src) return ""
        var s = String(src)
        if (s.indexOf("http://") === 0 || s.indexOf("https://") === 0)
            return "image://cached/" + encodeURIComponent(s)
        return s
    }
    function sourceOf(item) {
        if (item === undefined || item === null)
            return ""
        if (typeof item === "string")
            return wrapRemote(item)
        return wrapRemote(item.url || item.path || "")
    }
    readonly property string currentSource: root.hasImages
        ? sourceOf(root.images[root.currentIndex]) : ""

    function openAt(index) {
        if (!root.hasImages)
            return
        root.currentIndex = Math.max(0, Math.min(root.images.length - 1, index || 0))
        root.resetView()
        root.open = true
    }
    function show() { root.openAt(root.currentIndex) }

    function openWithImages(newImages, index) {
        if (!newImages || !newImages.length)
            return
        root.images = newImages
        root.currentIndex = Math.max(0, Math.min(newImages.length - 1, index || 0))
        root.resetView()
        root.open = true
    }

    function resetView() {
        root.viewScale = 1.0
        root.viewX = 0
        root.viewY = 0
    }

    function prevImage() {
        if (!root.hasImages)
            return
        root.currentIndex = root.currentIndex <= 0 ? root.images.length - 1 : root.currentIndex - 1
        root.resetView()
    }
    function nextImage() {
        if (!root.hasImages)
            return
        root.currentIndex = (root.currentIndex + 1) % root.images.length
        root.resetView()
    }

    function close() {
        if (!root.open)
            return
        root.open = false
        root.resetView()
        root.closed()
    }

    property real viewScale: 1.0
    property real viewX: 0
    property real viewY: 0

    Item {
        anchors.fill: parent
        visible: root.open
        z: 1000

        Rectangle {
            anchors.fill: parent
            color: "#EA000000"
            MouseArea { anchors.fill: parent; onClicked: root.close() }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Header: title + counter + close ────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                color: "#99000000"
                z: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 8
                    spacing: 8
                    z: 2

                    Label {
                        Layout.fillWidth: true
                        text: root.title
                        color: "#FFFFFF"
                        font.pixelSize: 15
                        font.bold: true
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Label {
                        visible: root.hasImages && root.images.length > 1
                        text: (root.currentIndex + 1) + " / " + root.images.length
                        color: "#D1D5DB"
                        font.pixelSize: 12
                    }

                    ToolButton {
                        text: "\u2715"
                        font.pixelSize: 18
                        contentItem: Label {
                            text: parent.text
                            color: "#FFFFFF"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle { color: "transparent" }
                        onClicked: root.close()
                    }
                }
            }

            // ── Stage: the zoomable image ──────────────────────────────────
            Item {
                id: stage
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                z: 1

                DragHandler {
                    id: flick
                    target: null
                    enabled: root.viewScale <= 1.0
                    property real totalDx: 0
                    xAxis.onActiveValueChanged: function (delta) { flick.totalDx += delta }
                    onActiveChanged: {
                        if (flick.active) {
                            flick.totalDx = 0
                        } else if (Math.abs(flick.totalDx) > 50) {
                            if (flick.totalDx < 0) root.nextImage()
                            else root.prevImage()
                        }
                    }
                }

                Image {
                    id: img

                    anchors.centerIn: parent
                    width: Math.min(parent.width, implicitWidth)
                    height: Math.min(parent.height, implicitHeight)
                    fillMode: Image.PreserveAspectFit
                    source: root.currentSource
                    asynchronous: true
                    smooth: true
                    visible: status !== Image.Null
                    sourceSize.width: 2048
                    sourceSize.height: 2048

                    scale: root.viewScale
                    transformOrigin: Item.Center

                    PinchHandler {
                        id: pinch
                        target: null
                        scaleAxis.enabled: true
                        scaleAxis.minimum: 1.0
                        scaleAxis.maximum: 5.0
                        onScaleChanged: function (delta) {
                            root.viewScale = Math.max(1.0, Math.min(5.0, root.viewScale * delta))
                        }
                    }

                    DragHandler {
                        id: panDrag
                        target: null
                        enabled: root.viewScale > 1.0
                        xAxis.onActiveValueChanged: function (delta) { root.viewX += delta }
                        yAxis.onActiveValueChanged: function (delta) { root.viewY += delta }
                    }

                    TapHandler {
                        id: tapZoom
                        onDoubleTapped: {
                            if (root.viewScale > 1.0) {
                                root.viewScale = 1.0
                                root.viewX = 0
                                root.viewY = 0
                            } else {
                                root.viewScale = 2.5
                                root.viewX = 0
                                root.viewY = 0
                            }
                        }
                    }
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    running: img.status === Image.Loading
                    visible: running
                }
                Label {
                    anchors.centerIn: parent
                    visible: img.status === Image.Error
                    text: qsTr("Could not load image")
                    color: "#FCA5A5"
                    font.pixelSize: 14
                }
            }

            // ── Footer: prev / next ────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 68
                color: "#99000000"
                visible: root.hasImages && root.images.length > 1
                z: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Button {
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 42
                        text: qsTr("\u2039 Previous")
                        enabled: root.currentIndex > 0
                        contentItem: Label {
                            text: parent.text
                            color: "#2563EB"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 21
                            color: "#EFF6FF"
                            border.color: "#BFDBFE"
                        }
                        onClicked: root.prevImage()
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 42
                        text: qsTr("Next \u203A")
                        enabled: root.currentIndex < root.images.length - 1
                        contentItem: Label {
                            text: parent.text
                            color: "#2563EB"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 21
                            color: "#EFF6FF"
                            border.color: "#BFDBFE"
                        }
                        onClicked: root.nextImage()
                    }
                }
            }
        }
    }
}
