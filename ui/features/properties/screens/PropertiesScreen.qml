import QtQuick
import QtQuick.Controls
import "../pages"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root
    //property string pageTitle: "Properties.."
    property bool showHeader: true
    property bool showBackButton: false
    property bool isSearchBar: true
    property bool searchReadOnly: true
    function onSearchBarTapped(){
        console.log("SearchBar Tapped")
        NavUtils.navigateToSearchScreen()
    }
    property Component rightComponentAction: Component {
            Item {
                implicitWidth: 36
                implicitHeight: 36

                ToolButton {
                   anchors.centerIn: parent
                    icon.color: "black"
                    icon.height: 24
                    icon.width: 24
                    icon.source: "qrc:/ui/assets/notification.svg"
                }
            }
        }
    PropertiesPage{
        anchors.fill: parent
    }
}
//=======================================IMPLEMENT ME
