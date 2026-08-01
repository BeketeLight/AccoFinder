import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../screens"
//import "../components"
import "../../home/components"
import "../../../utils/NavigationUtils.js" as NavUtils
Page{
    id: root
    // anchors.fill: parent

    // header: AuthHeaderComponent{
    // }
    ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Label {
                text: "Welcome to AccoFinder"
                color: "black"
                font.pixelSize: 20
                font.bold: true
            }

            Button {
                text: "Register New Account"
                onClicked: {
                    // Pushes onto mainStack -> covers the footer!
                    NavUtils.navigateToSignUp()
                }
            }

            Button {
                text: "Sign In"
                onClicked: {
                    NavUtils.navigateToSignIn()
                }
            }
    }
}
