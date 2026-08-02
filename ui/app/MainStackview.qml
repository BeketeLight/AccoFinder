import QtQuick 2.15
import QtQuick.Controls.Material
import "../utils/NavigationUtils.js" as NavUtils
import "../features/home/components"
Item{
    id: root
    readonly property alias depth : mainStackview.depth //exposing MainStackview depth to main.qml
    property alias stackView: mainStackview
    StackView {
        id: mainStackview
        anchors.fill: parent

        Component.onCompleted: {
            NavUtils.init(mainStackview)
        }
    }
}

