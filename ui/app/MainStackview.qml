import QtQuick 2.15
import QtQuick.Controls.Material
import "../utils" as UtilsModule
StackView{
    id: mainStackviewId
    anchors.fill: parent
    initialItem: "./ui/features/home/screens/HomeScreen.qml"


    Component.onCompleted: {
        UtilsModule.NavigationUtils.init(mainStackviewId)
        console.log("NavigationUtils executed >>>")
    }
    focus: true
    Keys.onBackPressed: function(event) {
        if(mainStackviewId.depth > 1){
            mainStackviewId.pop()
            event.accepted = true
        }else{
            var current = currentItem
            if(current && current.objectName === "HomeScreen"){
                event.accepted = false
            }else{
                UtilsModule.NavigationUtils.replace("../features/home/screens/HomeScreen.qml")
                event.accepted = true
            }
        }
    }
}
