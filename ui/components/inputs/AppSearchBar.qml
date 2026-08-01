import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // Public Properties

    property string text: ""
    property string placeholder: "Search..."
    property bool searchEnabled: true
    property int searchBarHeight: 37
    property int borderRadius: 8          // Fully rounded (Material style)

    // Colors
    property color backgroundColor: "red"
    property color textColor: "#202124"
    property color placeholderColor: "#6B7280"
    property color iconColor: "#5F6368"
    property color focusColor: "yellow"

    // Signals
    signal accepted
    signal cleared
    signal textEdited

    implicitWidth: 350
    implicitHeight: searchBarHeight

    // Background

    Rectangle {
        id: background
        anchors.fill: parent
        radius: root.borderRadius
        color: searchField.activeFocus ? root.focusColor : root.backgroundColor
        border.color: "black"

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

    // Focus border (subtle)
    Rectangle {
        anchors.fill: parent
        radius: root.borderRadius
        color: "transparent"
        border.color: searchField.activeFocus ? "#1A73E8" : "black"
        border.width: 1.5
        opacity: 0.6

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    // Content

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        anchors.bottomMargin: 2.5
        spacing: 10

        // Text Field
        TextField {
            id: searchField
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: root.text
            placeholderText: root.placeholder
            enabled: root.searchEnabled
            color: root.textColor
            placeholderTextColor: searchField.activeFocus ? "transparent" : root.placeholderColor
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

        // Flexible spacer – takes all remaining space
        Item {
            Layout.fillWidth: true
        }

        // Search Icon
        Image {
            id: notifications
            //fillMode: Image.PreserveAspectFit
            source: "qrc:/ui/assets/search-icon.svg"
            // 1. Force the size the layout will see
            // width: 24
            // height: 24
            // or if inside a Layout:
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.maximumWidth: 32
            Layout.maximumHeight: 32

            // 2. Control how the SVG is rasterized (very important for quality + size)
            sourceSize.width: 48          // 2× for retina / high-DPI
            sourceSize.height: 48

            fillMode: Image.PreserveAspectFit
            antialiasing: true
            smooth: true
            MouseArea {
                anchors.fill: parent
                onClicked: UtilsModule.NavigationUtils.navigateToNotifications()
            }
        }

        // Clear Button (X)
        Item {
            id: clearButton
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
}
