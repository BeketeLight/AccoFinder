import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../../../components/inputs"
import "../../models"

Item {
    id: root

    property AdminAgentsModel agentsModel: AdminAgentsModel {}
    property string pageTitle: qsTr("Register Agent")

    signal agentRegistered(var payload)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color successColor: "#16A34A"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"
    readonly property color errorColor: "#DC2626"

    function submit() {
        nameInput.error = false
        emailInput.error = false
        areaDropdown.borderColor = root.borderColor
        rateInput.error = false
        nameError.text = ""
        emailError.text = ""
        areaError.text = ""
        rateError.text = ""

        var valid = true
        if (nameInput.text.trim().length < 3) {
            nameError.text = qsTr("Enter the agent's full name")
            nameInput.error = true
            valid = false
        }
        if (!emailInput.text.includes("@") || emailInput.text.trim().length < 5) {
            emailError.text = qsTr("Enter a valid email address")
            emailInput.error = true
            valid = false
        }
        if (areaDropdown.currentIndex < 0) {
            areaError.text = qsTr("Select an assigned area")
            areaDropdown.borderColor = root.errorColor
            valid = false
        }
        var rate = parseFloat(rateInput.text)
        if (isNaN(rate) || rate <= 0 || rate > 50) {
            rateError.text = qsTr("Commission must be between 1 and 50")
            rateInput.error = true
            valid = false
        }
        if (!valid)
            return

        var payload = {
            agentId: agentsModel.nextAgentId(),
            name: nameInput.text.trim(),
            email: emailInput.text.trim().toLowerCase(),
            phone: phoneInput.text.trim(),
            area: areaDropdown.currentText,
            commissionRate: Math.round(rate),
            active: true
        }

        agentsModel.addAgent(payload)
        console.log("Agent account created:", JSON.stringify(payload))
        successBanner.visible = true
        successTimer.restart()
        root.agentRegistered(payload)

        nameInput.text = ""
        emailInput.text = ""
        phoneInput.text = ""
        rateInput.text = ""
        areaDropdown.currentIndex = -1
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        SectionHeader {
            Layout.fillWidth: true
            title: qsTr("Agent details")
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: formColumn.implicitHeight + 28
            radius: 12
            color: "#FFFFFF"
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: formColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 10

                AppTextInput {
                    id: nameInput
                    label: qsTr("Full name")
                    placeholder: qsTr("e.g. Chilumba Chirwa")
                    required: true
                    fieldHeight: 48
                    backgroundColor: "#FFFFFF"
                    textColor: root.textColor
                    labelColor: root.textColor
                    placeholderColor: "#9CA3AF"
                    borderColor: root.borderColor
                    focusColor: root.primaryColor
                    errorColor: root.errorColor
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                }

                Label {
                    id: nameError
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: ""
                    color: root.errorColor
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }

                AppTextInput {
                    id: emailInput
                    label: qsTr("Email")
                    placeholder: qsTr("agent@accofinder.mw")
                    required: true
                    fieldHeight: 48
                    backgroundColor: "#FFFFFF"
                    textColor: root.textColor
                    labelColor: root.textColor
                    placeholderColor: "#9CA3AF"
                    borderColor: root.borderColor
                    focusColor: root.primaryColor
                    errorColor: root.errorColor
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                }

                Label {
                    id: emailError
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: ""
                    color: root.errorColor
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }

                AppTextInput {
                    id: phoneInput
                    label: qsTr("Phone (optional)")
                    placeholder: qsTr("+265 99x xxx xxx")
                    fieldHeight: 48
                    backgroundColor: "#FFFFFF"
                    textColor: root.textColor
                    labelColor: root.textColor
                    placeholderColor: "#9CA3AF"
                    borderColor: root.borderColor
                    focusColor: root.primaryColor
                    errorColor: root.errorColor
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                }

                AppDropdown {
                    id: areaDropdown
                    label: qsTr("Assigned area")
                    placeholder: qsTr("Select district...")
                    model: ["Lilongwe", "Blantyre", "Mzuzu", "Zomba", "Kasungu", "Salima", "Mangochi"]
                    fieldHeight: 48
                    backgroundColor: "#FFFFFF"
                    borderColor: root.borderColor
                    focusBorderColor: root.primaryColor
                    textColor: root.textColor
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                }

                Label {
                    id: areaError
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: ""
                    color: root.errorColor
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }

                AppTextInput {
                    id: rateInput
                    label: qsTr("Commission rate (%)")
                    placeholder: qsTr("e.g. 10")
                    required: true
                    fieldHeight: 48
                    backgroundColor: "#FFFFFF"
                    textColor: root.textColor
                    labelColor: root.textColor
                    placeholderColor: "#9CA3AF"
                    borderColor: root.borderColor
                    focusColor: root.primaryColor
                    errorColor: root.errorColor
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                }

                Label {
                    id: rateError
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: ""
                    color: root.errorColor
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }

                Button {
                    id: createAgentButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    Layout.topMargin: 4
                    padding: 0
                    text: qsTr("Create agent account")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: createAgentButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 15
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 12
                        color: createAgentButton.down ? root.primaryDarkColor : root.primaryColor
                    }

                    onClicked: root.submit()
                }
            }
        }

        Rectangle {
            id: successBanner
            visible: false
            Layout.fillWidth: true
            implicitHeight: successRow.implicitHeight + 24
            radius: 12
            color: "#ECFDF5"
            border.color: "#BBF7D0"
            border.width: 1

            RowLayout {
                id: successRow
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    radius: 13
                    color: root.successColor

                    Label {
                        anchors.centerIn: parent
                        text: "✓"
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Agent account created. Login details were emailed to them.")
                    color: "#166534"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    Timer {
        id: successTimer
        interval: 4000
        onTriggered: successBanner.visible = false
    }
}
