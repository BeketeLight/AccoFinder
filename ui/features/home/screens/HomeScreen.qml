import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../../../utils" as UtilsModule
import "../../../app"
import "../pages"

Item {
    id: rootId
    objectName: "HomeScreen"
    anchors.fill: parent
    property bool showHeader: false
    HomePage {

        anchors.fill: parent
    }
}
