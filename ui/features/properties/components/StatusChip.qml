import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property string textValue: ""
    property string variant: "neutral"

    readonly property var themes: ({
        "info":    { bg: "#EFF6FF", fg: "#2563EB" },
        "success": { bg: "#ECFDF5", fg: "#16A34A" },
        "warning": { bg: "#FFFBEB", fg: "#D97706" },
        "danger":  { bg: "#FEF2F2", fg: "#DC2626" },
        "neutral": { bg: "#F3F4F6", fg: "#6B7280" }
    })
    readonly property var activeTheme: themes[variant] ? themes[variant] : themes["neutral"]

    implicitWidth: chipLabel.implicitWidth + 22
    implicitHeight: 24
    radius: 12
    color: root.activeTheme.bg

    Label {
        id: chipLabel
        anchors.centerIn: parent
        text: root.textValue
        color: root.activeTheme.fg
        font.pixelSize: 11
        font.bold: true
    }
}
