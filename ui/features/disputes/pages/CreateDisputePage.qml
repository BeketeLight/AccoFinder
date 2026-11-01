import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/inputs"
import "../../../components/pages"
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root

    // Assigned by NavUtils.navigateToRaiseDispute
    property string bookingId: ""
    property string propertyImage: ""
    property string propertyLocation: ""
    property string houseName: ""
    property string landlord: ""
    property string hostName: ""
    property string status: ""
    property string bookingDate: ""

    property string pageTitle: qsTr("Report a problem")
    property bool showHeader: true
    property bool showBack: true
    property bool isSearchBar: false
    property bool collapsible: false
    property bool transparentHeader: false

    property string issueText: ""
    property string actionError: ""
    property bool submitting: false

    function goBack() { NavUtils.pop() }

    readonly property color primaryColor: "#2563EB"
    readonly property color dangerColor: "#DC2626"
    readonly property color mutedColor: "#6B7280"

    AppScrollablePage {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                visible: root.actionError.length > 0
                implicitHeight: errLabel.implicitHeight + 16
                radius: 8
                color: "#FEF2F2"
                border.color: "#FECACA"

                Label {
                    id: errLabel
                    anchors.fill: parent
                    anchors.margins: 8
                    text: root.actionError
                    color: root.dangerColor
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: infoCol.implicitHeight + 24
                radius: 12
                color: "#FFFFFF"
                border.color: "#E5E7EB"
                border.width: 1

                ColumnLayout {
                    id: infoCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 6

                    Label {
                        Layout.fillWidth: true
                        text: root.houseName.length > 0 ? root.houseName : qsTr("Booking")
                        color: "#111827"
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Label {
                        Layout.fillWidth: true
                        visible: root.propertyLocation.length > 0
                        text: root.propertyLocation
                        color: root.mutedColor
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        Layout.fillWidth: true
                        visible: root.bookingDate.length > 0
                        text: qsTr("Booking: %1").arg(root.bookingDate)
                        color: root.mutedColor
                        font.pixelSize: 11
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Describe the problem")
                color: "#111827"
                font.pixelSize: 14
                font.bold: true
            }

            TextArea {
                id: issueField
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                placeholderText: qsTr("Tell us what went wrong (at least 10 characters)")
                text: root.issueText
                onTextChanged: root.issueText = text
                wrapMode: TextEdit.Wrap
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("%1 / 10 minimum").arg(root.issueText.trim().length)
                color: root.issueText.trim().length < 10 ? root.dangerColor : root.mutedColor
                font.pixelSize: 11
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                enabled: !root.submitting && root.issueText.trim().length >= 10 && root.bookingId.length > 0
                text: root.submitting ? qsTr("Submitting…") : qsTr("Submit dispute")

                contentItem: Label {
                    text: parent.text
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 10
                    color: parent.enabled ? (parent.down ? "#1D4ED8" : "#2563EB") : "#93C5FD"
                }

                onClicked: {
                    root.actionError = ""
                    root.submitting = true
                    DisputesListViewModel.raiseDispute(root.bookingId, root.issueText.trim())
                }
            }
        }
    }

    Connections {
        target: DisputesListViewModel

        function onIsLoadingChanged(loading) {
            if (!loading && root.submitting) {
                // Success path: view model clears loading after raise. We can't
                // distinguish success/failure here, so pop on the next tick if no
                // error was reported.
                Qt.callLater(function() {
                    if (root.submitting && root.actionError.length === 0) {
                        root.submitting = false
                        NavUtils.pop()
                    }
                })
            }
        }

        function onDisputeError(error) {
            root.submitting = false
            root.actionError = String(error || qsTr("Failed to raise dispute"))
        }
    }
}
