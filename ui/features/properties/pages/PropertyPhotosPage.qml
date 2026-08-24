import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../../components/inputs"
import "../components"

Item {
    id: root

    readonly property alias photosModel: photosModelId

    property var roomsModelRef: null

    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

    signal nextRequested

    implicitHeight: layout.implicitHeight

    FileDialog {
        id: photoDialog
        title: qsTr("Select property photos")
        nameFilters: [qsTr("Image files (*.png *.jpg *.jpeg *.webp)")]
        fileMode: FileDialog.OpenFiles
        onAccepted: {
            for (var i = 0; i < selectedFiles.length; i++)
                photosModelId.append({ path: selectedFiles[i].toString(), isPrimary: photosModelId.count === 0, roomId: -1 })
        }
    }

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        Label {
            text: qsTr("Property photos")
            color: root.textColor
            font.pixelSize: 22
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Upload clear photos of the property. Tap a photo to set it as the primary cover image.")
            color: root.mutedColor
            font.pixelSize: 13
            lineHeight: 1.15
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -8
        }

        Button {
            id: uploadButton
            Layout.fillWidth: true
            Layout.preferredHeight: 52

            contentItem: RowLayout {
                spacing: 10

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 14
                    color: "#EFF6FF"

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/ui/assets/camera.svg"
                        sourceSize.width: 15
                        sourceSize.height: 15
                    }
                }

                Label {
                    text: uploadButton.down ? qsTr("Selecting...") : qsTr("Upload photos")
                    color: root.primaryColor
                    font.pixelSize: 14
                    font.bold: true
                }

                Item { Layout.fillWidth: true }
            }

            background: Rectangle {
                radius: 12
                color: uploadButton.down ? "#DBEAFE" : "#EFF6FF"
                border.color: "#BFDBFE"
                border.width: 1
            }

            onClicked: photoDialog.open()
        }

        ColumnLayout {
            visible: photosModelId.count > 0
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: qsTr("Assign each photo to a room")
                color: root.textColor
                font.pixelSize: 14
                font.bold: true
            }

            Repeater {
                model: photosModelId

                delegate: Rectangle {
                    id: photoAssignCard
                    required property var model
                    required property int index
                    Layout.fillWidth: true
                    implicitHeight: photoAssignRow.implicitHeight + 20
                    radius: 12
                    color: root.surfaceColor
                    border.color: root.borderColor
                    border.width: 1

                    RowLayout {
                        id: photoAssignRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 46
                            Layout.preferredHeight: 46
                            radius: 8
                            color: root.surfaceColor
                            border.color: photoAssignCard.model.isPrimary ? "#16A34A" : root.borderColor
                            border.width: photoAssignCard.model.isPrimary ? 2 : 1
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                source: photoAssignCard.model.path
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                        }

                        AppDropdown {
                            Layout.fillWidth: true
                            label: qsTr("Photo %1 belongs to").arg(photoAssignCard.index + 1)
                            placeholder: qsTr("Select room...")
                            model: root.roomOptions()
                            fieldHeight: 42
                            fontSize: 12
                            backgroundColor: "#FFFFFF"
                            borderColor: root.borderColor
                            focusBorderColor: root.primaryColor
                            textColor: root.textColor
                            currentIndex: root.optionIndexForRoom(photoAssignCard.model.roomId)
                            onActivated: function (optionIndex) {
                                photosModelId.setProperty(photoAssignCard.index, "roomId", root.roomIdForOption(optionIndex))
                            }
                        }
                    }
                }
            }
        }

        Flow {
            visible: photosModelId.count > 0
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: ListModel {
                    id: photosModelId
                }

                delegate: Item {
                    required property var model
                    required property int index
                    width: (layout.width - 20) / 3
                    height: width * 0.85

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: root.surfaceColor
                        border.color: model.isPrimary ? "#16A34A" : root.borderColor
                        border.width: model.isPrimary ? 2 : 1

                        Image {
                            anchors.fill: parent
                            anchors.margins: 3
                            source: model.path
                            fillMode: Image.PreserveAspectCrop
                            clip: true
                            asynchronous: true
                        }

                        Rectangle {
                            visible: model.isPrimary
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 6
                            width: primaryLabel.implicitWidth + 14
                            height: 20
                            radius: 10
                            color: "#16A34A"

                            Label {
                                id: primaryLabel
                                anchors.centerIn: parent
                                text: qsTr("Primary")
                                color: "#FFFFFF"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.setPrimaryPhoto(index)
                        }
                    }

                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: -6
                        anchors.rightMargin: -6
                        width: 24
                        height: 24
                        radius: 12
                        color: removePhotoArea.containsMouse ? "#DC2626" : "#EF4444"

                        Rectangle {
                            anchors.centerIn: parent
                            width: 10
                            height: 2
                            radius: 1
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: removePhotoArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                photosModelId.remove(index)
                                if (photosModelId.count > 0 && !root.hasPrimaryPhoto())
                                    photosModelId.setProperty(0, "isPrimary", true)
                            }
                        }
                    }
                }
            }
        }

        Label {
            id: errorText
            visible: text.length > 0
            text: ""
            color: root.errorColor
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Button {
            id: continueButton
            text: qsTr("Continue")
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            Layout.topMargin: 6

            contentItem: Text {
                text: continueButton.text
                color: "#FFFFFF"
                font.pixelSize: 15
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 12
                color: continueButton.down ? "#1D4ED8" : root.primaryColor
            }

            onClicked: {
                if (photosModelId.count === 0) {
                    errorText.text = qsTr("Upload at least one photo before continuing.")
                    return
                }
                errorText.text = ""
                if (!root.hasPrimaryPhoto())
                    photosModelId.setProperty(0, "isPrimary", true)
                root.nextRequested()
            }
        }
    }

    function setPrimaryPhoto(index) {
        for (var i = 0; i < photosModelId.count; i++)
            photosModelId.setProperty(i, "isPrimary", i === index)
    }

    function roomOptions() {
        var options = [qsTr("Whole property / common areas")]
        if (root.roomsModelRef) {
            for (var i = 0; i < root.roomsModelRef.count; i++) {
                var r = root.roomsModelRef.get(i)
                options.push(qsTr("Room %1 · %2").arg(r.roomId).arg(r.roomType))
            }
        }
        return options
    }

    function roomIdForOption(optionIndex) {
        if (optionIndex <= 0 || !root.roomsModelRef)
            return -1
        if (optionIndex > root.roomsModelRef.count)
            return -1
        return root.roomsModelRef.get(optionIndex - 1).roomId
    }

    function optionIndexForRoom(roomId) {
        if (roomId === undefined || roomId < 0 || !root.roomsModelRef)
            return 0
        for (var i = 0; i < root.roomsModelRef.count; i++) {
            if (root.roomsModelRef.get(i).roomId === roomId)
                return i + 1
        }
        return 0
    }

    function hasPrimaryPhoto() {
        for (var i = 0; i < photosModelId.count; i++) {
            if (photosModelId.get(i).isPrimary)
                return true
        }
        return false
    }
}
