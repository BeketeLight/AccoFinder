import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // Public Properties

    property string label: ""                    // Optional label above
    property string placeholder: "Select..."
    property var model: []                       // List of options
    property int currentIndex: -1
    property string currentText: currentIndex >= 0 ? model[currentIndex] : ""
    property bool required: false

    // Styling
    property color backgroundColor: "#FFFFFF"
    property color borderColor: "#CCCCCC"
    property color focusBorderColor: "#2196F3"
    property color textColor: "#333333"
    property color placeholderColor: "#999999"
    property int borderRadius: 8
    property int fontSize: 14
    property int fieldHeight: 42

    // Signals
    signal activated(int index)

    implicitWidth: 250
    implicitHeight: label ? labelItem.height + 6 + combo.height : combo.height

    // Label

    Text {
        id: labelItem
        text: root.label + (root.required ? " *" : "")
        font.pixelSize: 13
        color: "#555555"
        visible: root.label.length > 0
    }

    // ComboBox

    ComboBox {
        id: combo
        anchors.top: root.label ? labelItem.bottom : parent.top
        anchors.topMargin: root.label ? 6 : 0
        width: parent.width
        height: root.fieldHeight
        model: root.model
        currentIndex: root.currentIndex
        enabled: root.enabled

        // Sync
        onActivated: function (index) {
            root.currentIndex = index;
            root.activated(index);
        }

        onCurrentIndexChanged: {
            root.currentIndex = currentIndex;
            root.currentIndexChanged();
        }

        // Placeholder when nothing selected
        contentItem: Text {
            leftPadding: 12
            rightPadding: combo.indicator.width + 12
            text: combo.displayText || root.placeholder
            font.pixelSize: root.fontSize
            color: combo.displayText ? root.textColor : root.placeholderColor
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            radius: root.borderRadius
            color: root.enabled ? root.backgroundColor : "#F5F5F5"
            border.color: combo.activeFocus ? root.focusBorderColor : root.borderColor
            border.width: combo.activeFocus ? 2 : 1
        }

        indicator: Item {
            width: 30
            height: parent.height
            anchors.right: parent.right

            Text {
                anchors.centerIn: parent
                text: "▼"
                font.pixelSize: 10
                color: root.enabled ? "#666666" : "#AAAAAA"
            }
        }

        popup: Popup {
            y: combo.height + 4
            width: combo.width
            implicitHeight: Math.min(contentItem.implicitHeight + 2, 280)
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: combo.popup.visible ? combo.delegateModel : null
                currentIndex: combo.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator {}
            }

            background: Rectangle {
                radius: root.borderRadius
                color: root.backgroundColor
                border.color: root.borderColor
                border.width: 1
            }
        }

        delegate: ItemDelegate {
            width: combo.width
            height: 40

            contentItem: Text {
                text: modelData
                color: root.textColor
                font.pixelSize: root.fontSize
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
            }

            background: Rectangle {
                color: highlighted ? "#E3F2FD" : "transparent"
            }
        }
    }
}
