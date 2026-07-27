import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule

Page{
    id:signInPageId
    anchors.fill: parent

    ColumnLayout{
        anchors.centerIn: parent
        width: parent.width * 0.85
        spacing: 20
        // Layout.preferredWidth: 680

        Label{
            text: "Sign Up"
            font{
                pointSize: 24
                bold: true
            }
            Layout.alignment: Qt.AlignHCenter
        }
        Item{
            Layout.preferredHeight: 50
        }


        TextField{
            id: name
            placeholderText: "Email"
            Layout.fillWidth: true

        }

        TextField{
            id: email
            placeholderText: "Email"
            Layout.fillWidth: true
        }
        TextField{
            id: residenttialAddress
            placeholderText: "Residential address"
            Layout.fillWidth: true
        }
        Button{
            id: signinButtonId
            text: "SIGN UP"
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            background: Rectangle{
                color: "#2563EB"
                radius: 10
            }
        }



    }


}
