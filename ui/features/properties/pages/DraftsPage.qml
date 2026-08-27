import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root

    signal resendRequested(var key)
    signal openRequested(var key)
    signal deleteRequested(var key)

    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color pageColor: "#FFFFFF"
    property color surfaceColor: "#F5F5F5"
    property color softBlueColor: "#EFF6FF"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"

    property var draftsCache: ({})

    function refresh() {
        root.draftsCache = DraftViewModel.allDrafts() || {}
        emptyState.visible = Object.keys(root.draftsCache).length === 0
    }

    Component.onCompleted: root.refresh()

    Connections {
        target: DraftViewModel
        function onDraftsChanged() { root.refresh() }
    }

    background: Rectangle { color: root.pageColor }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        ColumnLayout {
            id: emptyState
            Layout.fillWidth: true
            spacing: 10
            visible: false

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 72
                Layout.preferredHeight: 72
                radius: 36
                color: root.softBlueColor
                border.color: "#BFDBFE"
                border.width: 1

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/ui/assets/save-icon.svg"
                    sourceSize.width: 34
                    sourceSize.height: 34
                }
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("No drafts yet")
                color: root.textColor
                font.pixelSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                Layout.fillWidth: true
                Layout.maximumWidth: 300
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("When a property fails to upload it is saved here so you can resend it later.")
                color: root.mutedColor
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: listColumn.implicitHeight
            clip: true

            ColumnLayout {
                id: listColumn
                width: parent.width
                spacing: 10

                Repeater {
                    model: Object.keys(root.draftsCache)

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: cardColumn.implicitHeight + 24
                        radius: 14
                        color: root.pageColor
                        border.color: root.borderColor
                        border.width: 1

                        ColumnLayout {
                            id: cardColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 14
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Label {
                                    Layout.fillWidth: true
                                    text: {
                                        var d = root.draftsCache[modelData]
                                        return (d && (d.title || "Untitled property"))
                                    }
                                    color: root.textColor
                                    font.pixelSize: 15
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Label {
                                    text: {
                                        var d = root.draftsCache[modelData]
                                        return (d && d.propertyType) || ""
                                    }
                                    color: root.primaryColor
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            Label {
                                Layout.fillWidth: true
                                visible: (function(){ var d = root.draftsCache[modelData]; return d && (d.physicalAddress && (d.physicalAddress.district || d.physicalAddress.village)) }())
                                text: {
                                    var d = root.draftsCache[modelData]
                                    var a = d && d.physicalAddress ? d.physicalAddress : {}
                                    var parts = []
                                    if (a.district) parts.push(a.district)
                                    if (a.village) parts.push(a.village)
                                    return parts.join(" · ")
                                }
                                color: root.mutedColor
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Button {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 38
                                    text: qsTr("Resend")

                                    contentItem: Label {
                                        text: parent.text
                                        color: "#FFFFFF"
                                        font.pixelSize: 13
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        radius: 10
                                        color: parent.down ? "#1D4ED8" : root.primaryColor
                                    }
                                    onClicked: root.resendRequested(modelData)
                                }

                                Button {
                                    Layout.preferredHeight: 38
                                    Layout.preferredWidth: 72
                                    text: qsTr("Delete")

                                    contentItem: Label {
                                        text: parent.text
                                        color: "#B91C1C"
                                        font.pixelSize: 13
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        radius: 10
                                        color: parent.down ? "#FEE2E2" : "#FEF2F2"
                                        border.color: "#FECACA"
                                        border.width: 1
                                    }
                                    onClicked: root.deleteRequested(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
