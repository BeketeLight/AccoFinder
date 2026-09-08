import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import "../../utils/NavigationUtils.js" as NavUtils

// Full-screen camera capture page pushed onto the main StackView. Because it
// is a normal stack page (not a Dialog), the wizard below stays intact and the
// Android system back button simply pops this page back to the wizard - it
// never navigates away and never loses the room/form data already entered.
Page {
    id: root

    // Hide the global app header so the camera fills the whole screen.
    property bool showHeader: false
    property string hintText: qsTr("Tap the shutter to capture")

    background: Rectangle { color: "#000000" }

    // Only usable once the camera is actually active and error-free.
    property bool cameraReady: camera && camera.active && camera.error === Camera.NoError
    property bool cameraFailed: false
    property string cameraErrorText: ""

    // The add-property wizard only needs the rear camera.
    function selectedDevice() {
        for (let i = 0; i < mediaDevices.videoInputs.length; ++i) {
            const device = mediaDevices.videoInputs[i]
            if (device.position === CameraDevice.BackFace)
                return device
        }
        return mediaDevices.defaultVideoInput
    }

    // Stop the camera and return to the wizard page below.
    function closeCamera() {
        camera.active = false
        NavUtils.pop()
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"

        Camera {
            id: camera
            active: root.visible
            cameraDevice: root.selectedDevice()
            onErrorOccurred: function (error, errorString) {
                console.warn("[CameraCapture] camera error:", errorString)
                root.cameraFailed = true
                root.cameraErrorText = errorString
            }
        }

        CaptureSession {
            id: session
            camera: camera
            imageCapture: imageCapture
            videoOutput: videoOutput
        }

        ImageCapture {
            id: imageCapture
            onImageSaved: function (id, path) {
                // onImageSaved reports a plain filesystem path. Normalise it to
                // a file:// URL so QML Image and the rest of the pipeline treat
                // it exactly like a gallery pick (which arrives as file://...).
                var url = (path && path.indexOf("file:") === 0) ? path : "file://" + path
                AppSettings.setCapturedPhotoPath(url)
                root.closeCamera()
            }
            onErrorOccurred: function (id, error, errorString) {
                console.warn("[CameraCapture] capture error:", errorString)
                errorLabel.text = qsTr("Could not capture photo. Please try again.")
            }
        }

        MediaDevices {
            id: mediaDevices
        }

        // Live preview from the camera
        VideoOutput {
            id: videoOutput
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop
        }

        // Subtle gradient overlay for depth
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.7; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.4) }
            }
            z: 1
        }

        // Loading indicator
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16
            visible: !root.cameraReady
            z: 2

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                radius: 32
                color: Qt.rgba(255, 255, 255, 0.08)
                border.color: Qt.rgba(255, 255, 255, 0.2)
                border.width: 2

                Rectangle {
                    anchors.centerIn: parent
                    width: 28
                    height: 28
                    radius: 14
                    color: "transparent"
                    border.color: "#FFFFFF"
                    border.width: 3
                    opacity: 0.6

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 1200
                        loops: Animation.Infinite
                        running: !root.cameraReady
                    }
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: root.width - 80
                text: root.cameraFailed
                      ? qsTr("Camera unavailable.\n%1").arg(root.cameraErrorText)
                      : qsTr("Initializing camera…")
                color: "#FFFFFF"
                font.pixelSize: 14
                font.weight: Font.Light
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                lineHeight: 1.2
                opacity: 0.7
            }
        }

        Label {
            id: errorLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: controls.top
            anchors.bottomMargin: 12
            visible: text.length > 0 && text !== ""
            text: ""
            color: "#FCA5A5"
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width - 48
            z: 3

            background: Rectangle {
                color: Qt.rgba(0, 0, 0, 0.6)
                radius: 8
                anchors.fill: parent
                anchors.margins: -8
            }
            padding: 8
        }

        // ── Circular close button (top-right) ──────────────────────
        Item {
            width: 44
            height: 44
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 16
            z: 3

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Qt.rgba(0, 0, 0, 0.5)
                border.color: Qt.rgba(255, 255, 255, 0.15)
                border.width: 1
            }

            // Clean cross inside the round button.
            Rectangle {
                width: 18
                height: 2.5
                radius: 1.25
                color: "#FFFFFF"
                opacity: 0.9
                anchors.centerIn: parent
                rotation: 45
            }
            Rectangle {
                width: 2.5
                height: 18
                radius: 1.25
                color: "#FFFFFF"
                opacity: 0.9
                anchors.centerIn: parent
                rotation: 45
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.closeCamera()
            }
        }

        // ── Bottom hint + standard circular shutter ────────────────
        ColumnLayout {
            id: controls
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 32
            spacing: 24
            z: 3

            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.width - 32
                text: root.hintText
                color: "#FFFFFF"
                font.pixelSize: 13
                font.weight: Font.Light
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                opacity: 0.8
            }

            // Standard camera shutter: white circle with a thin ring.
            Item {
                Layout.alignment: Qt.AlignHCenter
                width: 76
                height: 76
                enabled: root.cameraReady

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: "#FFFFFF"
                    border.width: 3
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 60
                    height: 60
                    radius: width / 2
                    color: enabled ? "#FFFFFF" : Qt.rgba(255, 255, 255, 0.45)
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: enabled
                    onClicked: {
                        errorLabel.text = ""
                        imageCapture.captureToFile()
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (root.visible) {
            errorLabel.text = ""
            root.cameraFailed = false
            root.cameraErrorText = ""
            camera.active = true
        } else {
            camera.active = false
        }
    }

    Component.onDestruction: camera.active = false
}