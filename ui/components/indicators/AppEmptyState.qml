import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    // Icon: leave source empty to show nothing (e.g. a check-mark "✓" text).
    property string iconSource: ""
    property string iconText: ""
    property int iconSize: 40
    property color iconBgColor: "#EFF6FF"
    property color iconBorderColor: "#BFDBFE"
    property color iconColor: "#2563EB"
    property int iconFontSize: 18
    property color titleColor: "#1F2937"
    property color subtitleColor: "#6B7280"
    property int titlePixelSize: 13
    property int subtitlePixelSize: 11
    property int spacingValue: 6

    property string title: ""
    property string subtitle: ""
    property int topMargin: 2
    property int maxSubtitleWidth: 320

    spacing: root.spacingValue
    Layout.topMargin: root.topMargin
    Layout.fillWidth: root.title.length > 0 || root.subtitle.length > 0

    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: root.iconSize
        Layout.preferredHeight: root.iconSize
        radius: root.iconSize / 2
        color: root.iconBgColor
        border.color: root.iconBorderColor
        border.width: 1

        Image {
            anchors.centerIn: parent
            visible: root.iconSource.length > 0
            source: root.iconSource
            sourceSize.width: root.iconSize / 2
            sourceSize.height: root.iconSize / 2
        }

        Label {
            anchors.centerIn: parent
            visible: root.iconText.length > 0
            text: root.iconText
            color: root.iconColor
            font.pixelSize: root.iconFontSize
            font.bold: true
        }
    }

    Label {
        Layout.fillWidth: true
        visible: root.title.length > 0
        text: root.title
        color: root.titleColor
        font.pixelSize: root.titlePixelSize
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
    }

    Label {
        Layout.fillWidth: true
        Layout.maximumWidth: root.maxSubtitleWidth
        Layout.alignment: Qt.AlignHCenter
        visible: root.subtitle.length > 0
        text: root.subtitle
        color: root.subtitleColor
        font.pixelSize: root.subtitlePixelSize
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }
}
