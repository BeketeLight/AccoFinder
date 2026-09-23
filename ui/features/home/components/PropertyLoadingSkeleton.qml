import QtQuick
import QtQuick.Layouts

Item {
    id: root

    implicitHeight: 260

    readonly property int _columns: 3
    readonly property int _gap: 8

    Grid {
        anchors.fill: parent
        columns: root._columns
        columnSpacing: root._gap
        rowSpacing: root._gap

        readonly property real cellWidth: (width - columnSpacing * (root._columns - 1)) / root._columns

        Repeater {
            model: root._columns * 2

            Rectangle {
                width: parent.cellWidth
                height: width * 1.25
                radius: 12
                color: "#E5E7EB"
                border.color: "#EEF2F6"
                border.width: 1
            }
        }
    }
}
