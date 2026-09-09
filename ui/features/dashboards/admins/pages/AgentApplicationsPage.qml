import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../models"
import "../delegates"

Item {
    id: root

    property string pageTitle: qsTr("Agent Applications")
    property AdminAgentApplicationsModel applicationsListModel: AdminAgentApplicationsModel {}

    signal viewApplicationRequested(var applicationId)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        SectionHeader {
            Layout.fillWidth: true
            title: qsTr("Pending applications")
        }

        Repeater {
            model: root.applicationsListModel.applicationsModel

            delegate: AgentApplicationDelegate {
                applicationId: model.applicationId
                name: model.name
                email: model.email
                phone: model.phone
                area: model.area
                appliedDate: model.appliedDate
                status: model.status
                onViewRequested: (applicationId) => root.viewApplicationRequested(applicationId)
            }
        }

        Label {
            visible: root.applicationsListModel.applicationsModel.count === 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("No pending agent applications.")
            color: root.mutedColor
            font.pixelSize: 12
            topPadding: 8
        }
    }
}
