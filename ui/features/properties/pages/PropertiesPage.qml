import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../home/components"
import "../../../utils" as UtilsModule

Page {
    id: root

    property string pageTitle: "Properties.."
    property bool showBack: false
    property Component leftComponentAction: null
    property Component rightComponentAction: null
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            Label {
                text: qsTr("Properties")
                font.bold: true
            }
            Item {
                Layout.fillWidth: true
            }
            ToolButton {
                text: qsTr("Add")
                onClicked: root.addPropertyRequested()
            }
        }
    }

    PropertiesListPage {
        anchors.centerIn: parent
    }
}
