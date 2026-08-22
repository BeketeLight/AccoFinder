import QtQuick
import QtQuick.Controls
import "../utils/NavigationUtils.js" as NavUtils
import "../features/home/components"
Item{
    id: root
    property alias depth : mainStackview.depth //exposing MainStackview depth to main.qml
    property alias stackView: mainStackview
    property alias currentItem: mainStackview.currentItem
    property string initialPage: "../features/auth/pages/CreateAccountPage.qml"
    Rectangle{ //opaque background for stakview footer wont be visible on push/pop
        anchors.fill: parent
        color: "#FFFFFF"
        visible: root.depth > 0
    }
    StackView {
        id: mainStackview
        anchors.fill: parent
        clip: true
        //Transitions on push/pop
        pushEnter: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "scale"
                        from: 0.92
                        to: 1.0
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                pushExit: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 1.0
                        to: 0.0
                        duration: 200
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        property: "scale"
                        from: 1.0
                        to: 0.96
                        duration: 200
                        easing.type: Easing.InQuad
                    }
                }
                popEnter: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "scale"
                        from: 0.96
                        to: 1.0
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }
                popExit: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 1.0
                        to: 0.0
                        duration: 180
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        property: "scale"
                        from: 1.0
                        to: 0.92
                        duration: 180
                        easing.type: Easing.InQuad
                    }
                }
        Component.onCompleted: {
            NavUtils.init(mainStackview)

            // if(root.initialPage !==""){
            //     mainStackview.push(root.initialPage, {}, StackView.Immediate)
            // }
        }
    }
}

