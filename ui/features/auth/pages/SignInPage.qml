import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../screens"
import "../../home/components"
import "../../../utils" as UtilsModule

Page{
    id: rootId
    header:AccountScreen{
        //anchors.fill: parent
    }
    footer:FooterComponent{
        currentIndex: 3
    }
}


// Page {
//     id: signInPage
//     anchors.fill: parent

//     // ===== HEADER WITH BACK BUTTON =====
//     header: ToolBar {
//         background: Rectangle {
//             color: "white"
//         }

//         contentHeight: 56

//         RowLayout {
//             anchors.fill: parent
//             anchors.leftMargin: 8
//             anchors.rightMargin: 16

//             // Back Button
//             ToolButton {

//                 Image {
//                     id: home
//                     source: "qrc:/ui/assets/drawing.svg"
//                     fillMode: Image.PreserveAspectFit
//                     width: 24
//                     height: 24
//                     Layout.leftMargin: 24
//                     Layout.preferredHeight: 24
//                     Layout.preferredWidth: 24
//                     sourceSize.width: 48
//                     sourceSize.height: 48
//                     //Layout.alignment: Qt.AlignHCenter
//                     antialiasing: true
//                     smooth: true
//                     Layout.alignment: Qt.AlignHCenter

//                     MouseArea{
//                         anchors.fill: parent
//                         onClicked: UtilsModule.NavigationUtils.pop()
//                     }
//                 }
//                 onClicked: UtilsModule.NavigationUtils.pop()
//             }

//             Item { Layout.fillWidth: true }
//         }
//     }

//     // ===== MAIN CONTENT =====
//     ColumnLayout {
//         anchors {
//             top: parent.top
//             left: parent.left
//             right: parent.right
//             topMargin: 40
//             leftMargin: 24
//             rightMargin: 24
//         }
//         spacing: 28

//         Label {
//             text: "SignIn for AccoFinder"
//             font.pixelSize: 26
//             font.bold: true
//             color: "#1a1a1a"
//             Layout.fillWidth: true
//         }

//         TextField{
//             id: email
//             placeholderText: "Email"
//             Layout.fillWidth: true

//         }

//         TextField{
//             id: password
//             placeholderText: "Password"
//             Layout.fillWidth: true
//         }
//         Button{
//             id: signinButtonId
//             text: "SIGN IN"
//             Layout.fillWidth: true
//             Layout.preferredHeight: 50
//             background: Rectangle{
//                 color: "#2563EB"
//                 radius: 10
//             }
//         }
//         Item{
//             Layout.preferredHeight: 40
//         }
//         Label{
//             text: "Sign Up"
//             color: "#2563EB"
//             font{
//                 pointSize: 12
//                 bold: true
//             }
//             Layout.alignment: Qt.AlignHCenter
//             MouseArea{
//                 anchors.fill: parent
//                 onClicked: UtilsModule.NavigationUtils.navigateToSignUp()
//             }
//         }
//     }

//}
