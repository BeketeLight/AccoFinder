import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../delegates"

Item {
    id: root

    property bool loading: false
    property alias model: reviewList.model

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: root.loading
            visible: root.loading
        }

        ListView {
            id: reviewList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true

            delegate: ReviewDelegate {}

            // Empty state
            Text {
                anchors.centerIn: parent
                visible: reviewList.count === 0 && !root.loading
                text: qsTr("No reviews yet")
                color: "#888"
            }
        }
    }
}
