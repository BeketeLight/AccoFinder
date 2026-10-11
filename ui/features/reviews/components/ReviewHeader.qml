import QtQuick 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    property real average: 0
    property int count: 0

    RowLayout {
        spacing: 8

        Text {
            text: "★ " + root.average.toFixed(1)
            font.pixelSize: 22
            font.bold: true
        }

        StarRating {
            value: root.average
            starSize: 20
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: "(" + root.count + " review" + (root.count === 1 ? "" : "s") + ")"
            color: "#666"
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
