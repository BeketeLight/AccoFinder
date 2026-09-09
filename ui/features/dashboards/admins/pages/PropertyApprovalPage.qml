import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/models"
import "../../../properties/components"
import "../../../../utils/Utils.js" as Utils
import "../delegates"

Item {
    id: root

    property MyPropertiesModel listingsModel: MyPropertiesModel {}

    signal decisionMade(var propertyId, var title, var approved)
    signal reviewRequested(var propertyId)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color successColor: "#16A34A"
    readonly property color dangerColor: "#DC2626"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"
    readonly property color textColor: "#111827"

    property var pendingRejectId: ""
    property var pendingRejectTitle: ""

    function refreshQueue() {
        queueModel.clear()
        for (var i = 0; i < root.listingsModel.propertiesModel.count; i++) {
            var p = root.listingsModel.propertiesModel.get(i)
            if (String(p.status || "").toUpperCase() !== "PENDING")
                continue
            queueModel.append({
                propertyId: p.propertyId,
                title: p.title,
                district: p.district,
                village: p.village,
                price: p.price,
                landlord: p.landlord
            })
        }
        emptyState.visible = queueModel.count === 0
    }

    function confirmReject(propertyId, title) {
        pendingRejectId = propertyId
        pendingRejectTitle = title
        rejectReasonField.text = ""
        rejectError.visible = false
        rejectDialog.open()
    }

    function doReject() {
        var reason = rejectReasonField.text.trim()
        if (reason.length < 5) {
            rejectError.visible = true
            return
        }
        rejectError.visible = false
        root.listingsModel.setPropertyStatus(pendingRejectId, "REJECTED", reason)
        // Persist the decision (with the reason) on the backend so it survives a
        // refresh. setPropertyStatus only edits the local list.
        PropertyViewModel.updatePropertyStatus(pendingRejectId, "REJECTED", reason)
        console.log("Approval:", pendingRejectId, "-> REJECTED")
        root.decisionMade(pendingRejectId, pendingRejectTitle, false)
        root.refreshQueue()
        rejectDialog.close()
    }

    ListModel { id: queueModel }

    // The shared property model is populated asynchronously after the network
    // fetch resolves. Rebuild the queue whenever it changes so newly fetched
    // PENDING listings actually appear (instead of only at Component.onCompleted).
    Connections {
        target: root.listingsModel.propertiesModel
        function onCountChanged() { root.refreshQueue() }
    }

    Component.onCompleted: refreshQueue()

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Verification queue")
            }

            Rectangle {
                implicitHeight: 24
                implicitWidth: countLabel.implicitWidth + 16
                radius: 12
                color: "#FFFBEB"

                Label {
                    id: countLabel
                    anchors.centerIn: parent
                    text: String(queueModel.count)
                    color: "#B45309"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }

        Repeater {
            model: queueModel

            delegate: ApprovalRowDelegate {
                propertyId: model.propertyId
                title: model.title
                district: model.district
                village: model.village
                price: model.price
                landlord: model.landlord
                onReviewRequested: (propertyId) => root.reviewRequested(propertyId)
                onApproveRequested: (propertyId, title) => {
                    root.listingsModel.setPropertyStatus(propertyId, "VERIFIED")
                    // Persist the decision on the backend so it survives a
                    // refresh. setPropertyStatus only edits the local list.
                    PropertyViewModel.updatePropertyStatus(propertyId, "VERIFIED")
                    console.log("Approval:", propertyId, "-> VERIFIED")
                    root.decisionMade(propertyId, title, true)
                    root.refreshQueue()
                }
                onRejectRequested: (propertyId, title) => root.confirmReject(propertyId, title)
            }
        }

        Label {
            id: emptyState
            visible: false
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("No properties waiting for verification.")
            font.pixelSize: 12
            topPadding: 10
        }
    }

    Dialog {
        id: rejectDialog
        modal: true
        width: Math.min(parent ? parent.width - 40 : 320, 360)
        anchors.centerIn: parent
        padding: 18
        title: qsTr("Reject property")

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                Layout.fillWidth: true
                text: qsTr("Tell the agent what to fix so they can resubmit.")
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                color: "#374151"
            }

            TextArea {
                id: rejectReasonField
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(rejectReasonField.contentHeight + 36, 96)
                placeholderText: ""
                color: "#111827"
                font.pixelSize: 12
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                leftPadding: 14
                rightPadding: 14
                topPadding: rejectReasonField.activeFocus || rejectReasonField.text.length > 0 ? 30 : 12
                bottomPadding: 8

                property int maxLength: 500

                onTextChanged: {
                    if (text.length > maxLength) {
                        var cursorPos = cursorPosition
                        text = text.substring(0, maxLength)
                        cursorPosition = Math.min(cursorPos, text.length)
                    }
                    rejectError.visible = false
                }

                background: Item {
                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#FFFFFF"
                        border.width: rejectReasonField.activeFocus || rejectError.visible ? 2 : 1
                        border.color: rejectError.visible ? root.dangerColor
                                     : rejectReasonField.activeFocus ? root.primaryColor
                                     : "#E5E7EB"
                    }

                    Text {
                        id: rejectFloating
                        readonly property bool isFloating: rejectReasonField.activeFocus || rejectReasonField.text.length > 0
                        text: qsTr("Reason for rejection...")
                        color: rejectError.visible ? root.dangerColor
                               : rejectReasonField.activeFocus ? root.primaryColor
                               : "#6B7280"
                        font.pixelSize: isFloating ? 11 : 12
                        font.weight: isFloating ? Font.Medium : Font.Normal
                        x: 14
                        width: parent.width - 28
                        elide: Text.ElideRight

                        y: isFloating ? 8 : Math.round((parent.height - height) / 2)

                        Behavior on y {
                            NumberAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on font.pixelSize {
                            NumberAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 140
                            }
                        }
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: qsTr("%L1 / %L2 characters").arg(rejectReasonField.length).arg(rejectReasonField.maxLength)
                color: rejectReasonField.length >= rejectReasonField.maxLength ? root.dangerColor : root.mutedColor
                font.pixelSize: 10
            }

            Label {
                id: rejectError
                visible: false
                Layout.fillWidth: true
                text: qsTr("Add a reason (at least a few words) so the agent can fix it.")
                color: root.dangerColor
                font.pixelSize: 11
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Cancel")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("Cancel")
                        color: "#111827"
                        font.pixelSize: 13
                    }

                    background: Rectangle {
                        radius: 8
                        color: "#FFFFFF"
                        border.color: "#E5E7EB"
                        border.width: 1
                    }

                    onClicked: rejectDialog.reject()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Reject")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("Reject")
                        color: "#B91C1C"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: "#FEF2F2"
                        border.color: "#FECACA"
                        border.width: 1
                    }

                    onClicked: root.doReject()
                }
            }
        }
    }
}
