import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../models"

Item {
    id: root

    property string pageTitle: qsTr("Application Details")
    property AdminAgentApplicationsModel applicationsListModel: AdminAgentApplicationsModel {}
    property var usersModel: null
    property var agentsModel: null
    property string applicationId: ""

    property string applicantName: ""
    property string applicantEmail: ""
    property string applicantPhone: ""
    property string preferredArea: ""
    property string appliedDate: ""
    property string nationalId: ""
    property string licenseType: ""
    property string experience: ""
    property string motivation: ""
    property string references: ""
    property var documents: []
    property string status: "Pending"

    signal applicationApproved(var applicationId)
    signal applicationRejected(var applicationId)

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
        root.nationalId = app.nationalId
        root.licenseType = app.licenseType
        root.experience = app.experience
        root.motivation = app.motivation
        root.references = app.references
        root.documents = app.documents
        root.status = app.status
    }

    function docIcon(docType) {
        if (docType.indexOf("ID") >= 0) return "\uD83E\uDEAA"
        if (docType.indexOf("License") >= 0) return "\uD83D\uDCCB"
        if (docType.indexOf("Proof") >= 0 || docType.indexOf("Address") >= 0) return "\uD83C\uDFE0"
        if (docType.indexOf("Photo") >= 0) return "\uD83D\uDCF7"
        return "\uD83D\uDCC4"
    }

    function docStatusColor(docStatus) {
        if (docStatus === "Verified") return "#16A34A"
        if (docStatus === "Pending") return "#D97706"
        return "#6B7280"
    }

    function docStatusBg(docStatus) {
        if (docStatus === "Verified") return "#ECFDF5"
        if (docStatus === "Pending") return "#FFFBEB"
        return "#F3F4F6"
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
                        Label { text: root.applicantPhone.length > 0 ? root.applicantPhone : qsTr("Not provided"); font.pixelSize: 12; color: root.textColor; font.bold: true }
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
            implicitHeight: personalSection.implicitHeight + 28
            radius: 12
            color: "#FFFFFF"
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: personalSection
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 12

                Label {
                    text: qsTr("Personal information")
                    font.pixelSize: 14
                    font.bold: true
                    color: "#111827"
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: root.borderColor
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Label { text: qsTr("National ID"); font.pixelSize: 11; color: root.mutedColor }
                        Label { text: root.nationalId.length > 0 ? root.nationalId : qsTr("Not provided"); font.pixelSize: 13; color: root.textColor }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Label { text: qsTr("License type"); font.pixelSize: 11; color: root.mutedColor }
                        Label { text: root.licenseType.length > 0 ? root.licenseType : qsTr("Not provided"); font.pixelSize: 13; color: root.textColor }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Label { text: qsTr("Experience"); font.pixelSize: 11; color: root.mutedColor }
                    Label {
                        Layout.fillWidth: true
                        text: root.experience.length > 0 ? root.experience : qsTr("Not provided")
                        font.pixelSize: 13
                        color: root.textColor
                        wrapMode: Text.WordWrap
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Label { text: qsTr("Why do you want to be an agent?"); font.pixelSize: 11; color: root.mutedColor }
                    Label {
                        Layout.fillWidth: true
                        text: root.motivation.length > 0 ? root.motivation : qsTr("Not provided")
                        font.pixelSize: 13
                        color: root.textColor
                        wrapMode: Text.WordWrap
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Label { text: qsTr("References"); font.pixelSize: 11; color: root.mutedColor }
                    Label {
                        Layout.fillWidth: true
                        text: root.references.length > 0 ? root.references : qsTr("Not provided")
                        font.pixelSize: 13
                        color: root.textColor
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: docsSection.implicitHeight + 28
            radius: 12
            color: "#FFFFFF"
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: docsSection
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: qsTr("Attached documents")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#111827"
                    }

                    Rectangle {
                        visible: root.documents.length > 0
                        implicitHeight: 20
                        implicitWidth: docCountLabel.implicitWidth + 12
                        radius: 10
                        color: "#EFF6FF"

                        Label {
                            id: docCountLabel
                            anchors.centerIn: parent
                            text: String(root.documents.length)
                            color: root.primaryColor
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: root.borderColor
                }

                Repeater {
                    model: root.documents

                    delegate: Rectangle {
                        id: docRow
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        implicitHeight: docContent.implicitHeight + 16
                        radius: 8
                        color: root.surfaceColor
                        border.color: root.borderColor
                        border.width: 1

                        RowLayout {
                            id: docContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 8
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 34
                                Layout.preferredHeight: 34
                                radius: 8
                                color: "#FFFFFF"
                                border.color: root.borderColor
                                border.width: 1

                                Label {
                                    anchors.centerIn: parent
                                    text: root.docIcon(docRow.modelData.type)
                                    font.pixelSize: 16
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    Layout.fillWidth: true
                                    text: docRow.modelData.type
                                    color: "#111827"
                                    font.pixelSize: 12
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Label {
                                    Layout.fillWidth: true
                                    text: docRow.modelData.name
                                    color: root.mutedColor
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                }
                            }

                            Rectangle {
                                implicitHeight: 20
                                implicitWidth: docStatusChip.implicitWidth + 12
                                radius: 10
                                color: root.docStatusBg(docRow.modelData.status)

                                Label {
                                    id: docStatusChip
                                    anchors.centerIn: parent
                                    text: docRow.modelData.status
                                    color: root.docStatusColor(docRow.modelData.status)
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                implicitHeight: 28
                                implicitWidth: viewBtnLabel.implicitWidth + 16
                                radius: 14
                                color: viewDocArea.pressed ? "#DBEAFE" : "#EFF6FF"
                                border.color: "#BFDBFE"
                                border.width: 1

                                Label {
                                    id: viewBtnLabel
                                    anchors.centerIn: parent
                                    text: qsTr("View")
                                    color: root.primaryColor
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                MouseArea {
                                    id: viewDocArea
                                    anchors.fill: parent
                                    onClicked: console.log("View document:", docRow.modelData.name)
                                }
                            }
                        }
                    }
                }

                Label {
                    visible: root.documents.length === 0
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("No documents attached.")
                    color: root.mutedColor
                    font.pixelSize: 12
                    topPadding: 4
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
                    }
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
                        root.applicationsListModel.setStatus(root.applicationId, "Rejected")
                        root.status = "Rejected"
                        console.log("Agent application rejected:", root.applicationId)
                        root.applicationRejected(root.applicationId)
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
                        root.applicationsListModel.setStatus(root.applicationId, "Approved")
                        root.status = "Approved"

                        if (root.usersModel) {
                            var existing = root.usersModel.findByEmail(root.applicantEmail)
                            if (existing) {
                                root.usersModel.setUserRole(existing.userId, "AGENT")
                                console.log("Updated existing user role to AGENT:", existing.userId, root.applicantEmail)
                            } else {
                                var newUserId = root.usersModel.addUser({
                                    firstName: root.applicantName.split(" ")[0],
                                    surname: root.applicantName.split(" ").slice(1).join(" "),
                                    email: root.applicantEmail,
                                    phone: root.applicantPhone,
                                    role: "AGENT",
                                    password: "12345678",
                                    residentialAddress: root.preferredArea
                                })
                                console.log("Created new user account:", newUserId, root.applicantEmail, "password: 12345678")
                            }
                        }

                        if (root.agentsModel) {
                            var agentName = root.applicantName
                            var agentEmail = root.applicantEmail
                            var agentPhone = root.applicantPhone
                            root.agentsModel.addAgent({
                                name: agentName,
                                email: agentEmail,
                                phone: agentPhone,
                                area: root.preferredArea,
                                commissionRate: 10
                            })
                            console.log("Created agent record for:", agentName, "area:", root.preferredArea)
                        }

                        console.log("Agent application approved:", root.applicationId)
                        root.applicationApproved(root.applicationId)
                    }
                }
            }
        }
    }
}
