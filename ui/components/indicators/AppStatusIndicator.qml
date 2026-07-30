import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // Public Properties

    property string status: "idle"          // "idle" | "loading" | "success" | "error" | "warning"
    property string text: ""                // Optional text
    property int size: 48                   // Size of the indicator
    property int textSize: 14
    property color textColor: "#333333"
    property int spacing: 10

    // Colors
    property color loadingColor: "#2196F3"
    property color successColor: "#4CAF50"
    property color errorColor: "#F44336"
    property color warningColor: "#FF9800"
    property color idleColor: "#9E9E9E"

    implicitWidth: Math.max(size, label.implicitWidth)
    implicitHeight: text ? size + spacing + label.implicitHeight : size

    // Indicator Content

    Item {
        id: indicator
        width: root.size
        height: root.size
        anchors.horizontalCenter: parent.horizontalCenter

        // ---- Loading State ----
        Spinner {
            anchors.fill: parent
            running: root.status === "loading"
            color: root.loadingColor
            size: root.size
            visible: root.status === "loading"
        }

        // ---- Success / Error / Warning / Idle ----
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: {
                if (root.status === "success")
                    return root.successColor;
                if (root.status === "error")
                    return root.errorColor;
                if (root.status === "warning")
                    return root.warningColor;
                return root.idleColor;
            }
            visible: root.status !== "loading"

            // Icon inside
            Text {
                anchors.centerIn: parent
                font.pixelSize: root.size * 0.55
                font.bold: true
                color: "white"
                text: {
                    if (root.status === "success")
                        return "✓";
                    if (root.status === "error")
                        return "✕";
                    if (root.status === "warning")
                        return "!";
                    return "";
                }
            }
        }
    }
    // Optional Text

    Text {
        id: label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: indicator.bottom
        anchors.topMargin: root.spacing
        text: root.text
        color: root.textColor
        font.pixelSize: root.textSize
        visible: root.text.length > 0
        horizontalAlignment: Text.AlignHCenter
    }
}
