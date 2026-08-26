import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string text: ""
    property string placeholder: "Search..."
    property string label: ""
    property bool readOnly: false
    property int fieldHeight: 44
    property int borderRadius: 22
    property int horizontalPadding: 14
    property int floatingLabelTopMargin: 5

    property color backgroundColor: "#FFFFFF"
    property color textColor: "#1F2937"
    property color labelColor: "#5F6368"
    property color placeholderColor: "#9AA0A6"
    property color borderColor: "#E5E7EB"
    property color focusColor: "#2563EB"
    property color iconColor: "#9CA3AF"

    signal textEdited
    signal cleared
    signal accepted
    signal tapped
    signal searchBarTapped

    implicitWidth: 350
    implicitHeight: {
        var h = fieldHeight
        if (label.length > 0)
            h += labelItem.implicitHeight + 6
        return h
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        Text {
            id: labelItem
            Layout.fillWidth: true
            text: root.label
            font.pixelSize: 13
            font.weight: Font.Medium
            color: root.labelColor
            visible: root.label.length > 0
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.fieldHeight
            radius: root.borderRadius
            color: root.backgroundColor
            border.color: searchField.activeFocus ? root.focusColor : root.borderColor
            border.width: searchField.activeFocus ? 2 : 1

            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: root.horizontalPadding
                anchors.rightMargin: root.horizontalPadding
                spacing: 8

                // Search icon (magnifying glass)
                Item {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16

                    Rectangle {
                        x: 0.5
                        y: 0.5
                        width: 11
                        height: 11
                        radius: 5.5
                        color: "transparent"
                        border.color: root.iconColor
                        border.width: 1.7
                    }

                    Rectangle {
                        width: 6
                        height: 1.7
                        radius: 0.85
                        color: root.iconColor
                        rotation: 45
                        transformOrigin: Item.Left
                        x: 10.2
                        y: 10.2
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    TextField {
                        id: searchField
                        anchors.fill: parent
                        text: root.text
                        placeholderText: ""
                        enabled: !root.readOnly
                        color: root.textColor
                        font.pixelSize: 13
                        selectByMouse: true
                        verticalAlignment: Text.AlignVCenter

                        leftPadding: 0
                        rightPadding: 0
                        topPadding: isFloating ? root.floatingLabelTopMargin + 14 : 0
                        bottomPadding: isFloating ? 8 : 0
                        background: null

                        readonly property bool isFloating: activeFocus || text.length > 0

                        onTextChanged: {
                            if (root.text !== text)
                                root.text = text
                            root.textEdited()
                        }
                        onAccepted: root.accepted()
                    }

                    Text {
                        id: floatingLabel
                        text: root.placeholder
                        visible: root.placeholder.length > 0
                        color: searchField.activeFocus ? root.focusColor : root.placeholderColor
                        font.pixelSize: searchField.isFloating ? 11 : 13
                        font.weight: searchField.isFloating ? Font.Medium : Font.Normal

                        x: 0
                        width: parent.width
                        elide: Text.ElideRight

                        y: searchField.isFloating
                           ? root.floatingLabelTopMargin
                           : Math.round((parent.height - height) / 2)

                        Behavior on y {
                            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                        }
                        Behavior on font.pixelSize {
                            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 140 }
                        }
                    }
                }

                // Clear button (X)
                Item {
                    visible: searchField.text.length > 0
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            searchField.clear()
                            root.cleared()
                            searchField.forceActiveFocus()
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 13
                        height: 1.7
                        radius: 0.85
                        color: root.iconColor
                        rotation: 45
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 13
                        height: 1.7
                        radius: 0.85
                        color: root.iconColor
                        rotation: -45
                    }
                }
            }
        }
    }

    onTextChanged: {
        if (searchField.text !== root.text)
            searchField.text = root.text
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.readOnly
        onClicked: {
            root.tapped()
            root.searchBarTapped()
        }
    }
}
