import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../models"

Item {
    id: root

    property string pageTitle: qsTr("Application Details")
    property AdminAgentApplicationsModel applicationsListModel: AdminAgentApplicationsModel {}
    property string applicationId: ""

    property string applicantName: ""
    property string applicantEmail: ""
    property string applicantPhone: ""
    property string preferredArea: ""
    property string appliedDate: ""
    property string adminNotes: ""
    property string rejectReason: ""
    property string status: "Pending"

    signal applicationApproved(var applicationId)
    signal applicationRejected(var applicationId)

    property bool notesSaved: false

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color successColor: "#16A34A"
    readonly property color dangerColor: "#DC2626"
    readonly property color warningColor: "#D97706"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"
    readonly property color surfaceColor: "#F9FAFB"

    function loadApplication(appId) {
        var app = root.applicationsListModel.findApplication(appId)
        if (!app) return
        root.applicationId = app.applicationId
        root.applicantName = app.name
        root.applicantEmail = app.email
        root.applicantPhone = app.phone
        root.preferredArea = app.area
        root.appliedDate = app.appliedDate
        root.adminNotes = app.notes || ""
        root.rejectReason = app.reason || ""
        root.status = app.status
        notesField.text = root.adminNotes
        root.notesSaved = true
    }

    function saveNotes() {
        root.applicationsListModel.updateNotes(root.applicationId, notesField.text)
        root.notesSaved = false
        notesHint.text = qsTr("Saving...")
        notesHint.visible = true
    }

    function confirmReject() {
        var reason = rejectReasonField.text.trim()
        if (reason.length < 5) {
            rejectError.visible = true
            return
        }
        rejectError.visible = false
        root.applicationsListModel.setStatus(root.applicationId, "Rejected", reason)
        root.status = "Rejected"
        root.rejectReason = reason
        console.log("Agent application rejected:", root.applicationId)
        root.applicationRejected(root.applicationId)
        rejectDialog.close()
    }

    Connections {
        target: AgentApplicationViewModel
        function onIsLoadingChanged(loading) {
            if (!loading && notesHint.visible && notesHint.text === qsTr("Saving...")) {
                root.notesSaved = true
                notesHint.text = qsTr("Notes saved")
                Qt.callLater(function() { notesHint.visible = false })
            }
        }
    }

    Component.onCompleted: {
        if (root.applicationId.length > 0)
            loadApplication(root.applicationId)
    }

    onApplicationIdChanged: {
        if (root.applicationId.length > 0)
            loadApplication(root.applicationId)
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: profileHeader.implicitHeight + 28
            radius: 12
            color: "#FFFFFF"
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: profileHeader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 52
                        Layout.preferredHeight: 52
                        radius: 26
                        color: "#EFF6FF"

                        Label {
                            anchors.centerIn: parent
                            text: root.applicantName.length > 0 ? root.applicantName.charAt(0) : "?"
                            color: root.primaryColor
                            font.pixelSize: 22
                            font.bold: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Label {
                            Layout.fillWidth: true
                            text: root.applicantName
                            color: "#111827"
                            font.pixelSize: 17
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.applicantEmail
                            color: root.mutedColor
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        visible: root.status === "Pending"
                        implicitHeight: 24
                        implicitWidth: statusLabel.implicitWidth + 16
                        radius: 12
                        color: "#FFFBEB"
                        border.color: "#FDE68A"
                        border.width: 1

                        Label {
                            id: statusLabel
                            anchors.centerIn: parent
                            text: root.status
                            color: "#92400E"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    Rectangle {
                        visible: root.status === "Approved"
                        implicitHeight: 24
                        implicitWidth: statusLabelA.implicitWidth + 16
                        radius: 12
                        color: "#ECFDF5"
                        border.color: "#BBF7D0"
                        border.width: 1

                        Label {
                            id: statusLabelA
                            anchors.centerIn: parent
                            text: root.status
                            color: "#166534"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    Rectangle {
                        visible: root.status === "Rejected"
                        implicitHeight: 24
                        implicitWidth: statusLabelR.implicitWidth + 16
                        radius: 12
                        color: "#FEF2F2"
                        border.color: "#FECACA"
                        border.width: 1

                        Label {
                            id: statusLabelR
                            anchors.centerIn: parent
                            text: root.status
                            color: "#B91C1C"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    Rectangle {
                        visible: root.status === "Rejected" && root.rejectReason.length > 0
                        Layout.fillWidth: true
                        implicitHeight: reasonLabel.contentHeight + 24
                        radius: 10
                        color: "#FEF2F2"
                        border.color: "#FECACA"
                        border.width: 1

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            spacing: 4

                            Label {
                                text: qsTr("Rejection reason")
                                font.pixelSize: 11
                                font.bold: true
                                color: "#B91C1C"
                            }

                            Label {
                                id: reasonLabel
                                Layout.fillWidth: true
                                text: root.rejectReason
                                color: "#7F1D1D"
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: root.borderColor
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Label { text: qsTr("Phone"); font.pixelSize: 10; color: root.mutedColor }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Label {
                                Layout.fillWidth: true
                                text: root.applicantPhone.length > 0 ? root.applicantPhone : qsTr("Not provided")
                                font.pixelSize: 12
                                color: root.textColor
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            ToolButton {
                                visible: root.applicantPhone.length > 0
                                implicitHeight: 28
                                implicitWidth: 28
                                enabled: root.applicantPhone.length > 0
                                text: qsTr("Call")
                                font.pixelSize: 11
                                onClicked: Qt.openUrlExternally("tel:" + root.applicantPhone)
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Label { text: qsTr("Preferred area"); font.pixelSize: 10; color: root.mutedColor }
                        Label { text: root.preferredArea; font.pixelSize: 12; color: root.textColor; font.bold: true }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Label { text: qsTr("Applied"); font.pixelSize: 10; color: root.mutedColor }
                        Label { text: root.appliedDate; font.pixelSize: 12; color: root.textColor; font.bold: true }
                    }
                }
            }
        }

        

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: notesSection.implicitHeight + 28
            radius: 12
            color: "#FFFFFF"
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: notesSection
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 8

                Label {
                    text: qsTr("Admin notes")
                    font.pixelSize: 14
                    font.bold: true
                    color: "#111827"
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: root.borderColor
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: notesField.implicitHeight + 20
                    radius: 8
                    color: "#FFFFFF"
                    border.color: notesField.activeFocus ? root.primaryColor : root.borderColor
                    border.width: 1

                    TextArea {
                        id: notesField
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        placeholderText: qsTr("Add internal notes about this application...")
                        wrapMode: TextArea.Wrap
                        font.pixelSize: 12
                        color: root.textColor
                        background: Item {}
                        onTextChanged: root.notesSaved = false
                    }
                }

                Label {
                    id: notesHint
                    Layout.fillWidth: true
                    visible: false
                    text: ""
                    color: root.successColor
                    font.pixelSize: 11
                }

                Button {
                    id: saveNotesButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: qsTr("Save notes")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: saveNotesButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 10
                        color: saveNotesButton.down ? root.primaryDarkColor : root.primaryColor
                    }

                    onClicked: root.saveNotes()
                }
            }
        }

        Rectangle {
            visible: root.status === "Pending"
            Layout.fillWidth: true
            implicitHeight: decisionRow.implicitHeight + 24
            radius: 12
            color: "#FFFFFF"
            border.color: root.borderColor
            border.width: 1

            RowLayout {
                id: decisionRow
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Button {
                    id: rejectButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    text: qsTr("Reject application")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: rejectButton.text
                        color: "#B91C1C"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 12
                        color: rejectButton.down ? "#FEE2E2" : "#FEF2F2"
                        border.color: "#FECACA"
                        border.width: 1
                    }

                    onClicked: {
                        rejectReasonField.text = ""
                        rejectError.visible = false
                        rejectDialog.open()
                    }
                }

                Button {
                    id: approveButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    text: qsTr("Approve & onboard")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: approveButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 12
                        color: approveButton.down ? "#15803D" : root.successColor
                    }

                    onClicked: {
                        // Approving persists the decision and promotes the
                        // applicant's existing User to AGENT on the backend.
                        root.applicationsListModel.setStatus(root.applicationId, "Approved")
                        root.status = "Approved"
                        console.log("Agent application approved:", root.applicationId)
                        root.applicationApproved(root.applicationId)
                    }
                }
            }
        }
    }

    Dialog {
        id: rejectDialog
        modal: true
        width: Math.min(parent ? parent.width - 40 : 320, 360)
        anchors.centerIn: parent
        padding: 18
        title: qsTr("Reject application")

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                Layout.fillWidth: true
                text: qsTr("Tell the agent what to fix so they can resubmit.")
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                color: "#374151"
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: rejectReasonField.implicitHeight + 20
                radius: 8
                color: "#FFFFFF"
                border.color: rejectReasonField.activeFocus || rejectError.visible ? root.primaryColor
                                      : root.borderColor
                border.width: rejectReasonField.activeFocus || rejectError.visible ? 2 : 1

                TextArea {
                    id: rejectReasonField
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    placeholderText: qsTr("Reason for rejection...")
                    wrapMode: TextArea.Wrap
                    font.pixelSize: 12
                    color: root.textColor
                    background: Item {}
                    onTextChanged: {
                        rejectError.visible = false
                    }
                }
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
                        color: root.textColor
                        font.pixelSize: 13
                    }

                    background: Rectangle {
                        radius: 8
                        color: root.surfaceColor
                        border.color: root.borderColor
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

                    onClicked: root.confirmReject()
                }
            }
        }
    }
}
