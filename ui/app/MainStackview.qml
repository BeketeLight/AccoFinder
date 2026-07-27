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
}
