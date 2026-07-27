import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule
Page{
    id:homePageId

    // :ToolBar{
    //     background: Rectangle{
    //         color: "white"
    //     }
        // RowLayout{
        //     anchors.fill: parent
        //     width: parent.width * 0.85
        header:TextField{
                id:searchbarId
                implicitHeight: 40
                Layout.preferredWidth: 300
                placeholderText: qsTr("Search proprties..")
                color: "#1e1e1e"
                background: Rectangle{
                    color: "#e1e1e1"
                    radius: 10
                }
                Image {
                    id:searchIcon
                    anchors{
                        right: parent.right
                        rightMargin: 15
                        verticalCenter: parent.verticalCenter
                    }
                    source: "qrc:/ui/assets/search.png"
                    width: 20
                    height: 20
                    fillMode: Image.PreserveAspectFit
                }


        }

        contentItem: RowLayout{
            spacing: 20

            Label{
                text: "All"
                font.pointSize: 12
            }
            Label{
                text: "House"
                font.pointSize: 12
            }
            Label{
                text: "Hostel"
                font.pointSize: 12
            }
        }


}