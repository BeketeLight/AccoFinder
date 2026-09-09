import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"

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

                    delegate: DraftCardDelegate {
                        draftKey: modelData
                        draftTitle: (function(){ var d = root.draftsCache[modelData]; return (d && (d.title || "Untitled property")) }())
                        propertyType: (function(){ var d = root.draftsCache[modelData]; return (d && d.propertyType) || "" }())
                        locationVisible: (function(){ var d = root.draftsCache[modelData]; return d && (d.physicalAddress && (d.physicalAddress.district || d.physicalAddress.village)) }())
                        locationText: (function() {
                            var d = root.draftsCache[modelData]
                            var a = d && d.physicalAddress ? d.physicalAddress : {}
                            var parts = []
                            if (a.district) parts.push(a.district)
                            if (a.village) parts.push(a.village)
                            return parts.join(" · ")
                        }())
                        onResendRequested: (key) => root.resendRequested(key)
                        onDeleteRequested: (key) => root.deleteRequested(key)
                    }
                }
            }
        }
    }
}
