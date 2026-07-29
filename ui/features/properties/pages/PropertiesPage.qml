import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule
Page{
    id:homePageId
    anchors.fill: parent
    focus: true

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
            // contentHeight: 20
        }

        RowLayout{
            id: rowlayoutId
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 40
                leftMargin: 10
                rightMargin: 0
            }
            spacing: 20


            Label{
                text: "All"
                font.pointSize: 14
            }
            Label{
                text: "Houses"
                font.pointSize: 14
            }
            Label{
                text: "Hostels"
                font.pointSize: 14
            }
        }
        Item{
            Layout.preferredHeight: 50
        }
        ColumnLayout {
            anchors {
                top: rowlayoutId.top
                left: rowlayoutId.left
                right: rowlayoutId.right
                topMargin: 40
                leftMargin: 24
                rightMargin: 24
            }

            spacing: 2
            Layout.fillWidth: true

            Rectangle{
                width:200
                height: 120
                color: "yellowgreen"
                border.color: "black"
                radius: 5

                MouseArea{
                    anchors.fill: parent
                    onClicked: UtilsModule.NavigationUtils.navigateToPropertyDetails()
                }
            }
            ColumnLayout {
                // Layout.rightMargin: 5

                spacing: 4

                Label {
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                  }

                  Label {
                    text: "Chikanda, Zomba"
                    font.pixelSize: 12
                    color: "#777"
                }

                Label {
                    text: "MK 85,000 / month"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#0066FF"
                }
           }
        }
}