import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root
    property string pageTitle: "Forgot password"
    property bool showHeader: true

    ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Label {
                text: "Lost Your Password.."
                color: "black"
                font.pixelSize: 20
                font.bold: true
            }
            Button {
                text: "Forgot"
                onClicked: {

                }
            }
            Item {
                Layout.preferredHeight: 30
            }
    }
}
