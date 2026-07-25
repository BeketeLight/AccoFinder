import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // Public Properties

    property string text: ""
    property string placeholder: "Search..."
    property bool enabled: true
    property int height: 48
    property int borderRadius: 24          // Fully rounded (Material style)

    // Colors
    property color backgroundColor: "#F1F3F4"
    property color textColor: "#202124"
    property color placeholderColor: "#5F6368"
    property color iconColor: "#5F6368"
    property color focusColor: "#E8F0FE"

    // Signals
    signal accepted
    signal cleared
    signal textEdited

    implicitWidth: 300
    implicitHeight: height

    // Background

    Rectangle {
        id: background
        anchors.fill: parent
        radius: root.borderRadius
        color: searchField.activeFocus ? root.focusColor : root.backgroundColor

        // Soft elevation (Android style)
        layer.enabled: true
        layer.effect: Item {
            // Simple shadow simulation without GraphicalEffects
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    // Content

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 10
        spacing: 10

        // Search Icon
        Text {
            text: "🔍"
            font.pixelSize: 18
            color: root.iconColor
            Layout.alignment: Qt.AlignVCenter
            opacity: 0.7
        }

        // Text Field
        TextField {
            id: searchField
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: root.text
            placeholderText: root.placeholder
            enabled: root.enabled
            color: root.textColor
            placeholderTextColor: root.placeholderColor
            font.pixelSize: 15
            selectByMouse: true
            background: Item {}          // Remove default background
            leftPadding: 0
            rightPadding: 0
            verticalAlignment: Text.AlignVCenter

            onTextChanged: {
                root.text = text;
                root.textEdited();
            }

            onAccepted: root.accepted()
        }

        // Clear Button (X)
        Item {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter
            visible: searchField.text.length > 0
            opacity: visible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: mouseArea.containsMouse ? "#E0E0E0" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 14
                    color: root.iconColor
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        searchField.clear();
                        root.cleared();
                        searchField.forceActiveFocus();
                    }
                }
            }
        }
    }

    // Focus border (subtle)
    Rectangle {
        anchors.fill: parent
        radius: root.borderRadius
        color: "transparent"
        border.color: searchField.activeFocus ? "#1A73E8" : "transparent"
        border.width: 1.5
        opacity: 0.6

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
