import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../inputs"

ToolBar{
id: root
//global properties to be used
property string title: ""
property bool isSearchBar: false
property bool showBackButton: false
property Component leftAction: null
property Component rightAction: null
property bool searchReadOnly: false // exposing readonly for searchBar

signal backClicked()
signal searchBarTapped()

background: Rectangle{
    color: "#FFFFFF"
    Rectangle{
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: "#E0E0E0"
    height: 1
    }
}
RowLayout{
    anchors.fill: parent
    anchors.leftMargin: 8
    anchors.rightMargin: 12

//loader for Avatar loading
    Loader{
              sourceComponent: root.leftAction
                             ? root.leftAction
                             : (root.showBackButton ? backButtonComponent: null)
              // 2. Hide completely when no component is loaded
                  visible: status === Loader.Ready && item !== null

                  // 3. Set width/height to 0 when empty so it takes ZERO layout space
                  Layout.preferredWidth: visible ? (item ? item.implicitWidth : 36) : 0
                  Layout.preferredHeight: visible ? (item ? item.implicitHeight : 36) : 0
                  Layout.alignment: Qt.AlignVCenter

          }

    Component{
    id: backButtonComponent
        ToolButton{
            implicitHeight: 48
            implicitWidth: 48
            icon.source: "qrc:/ui/assets/back-icons.svg"
            icon.color: "#111111"
            icon.height: 16
            icon.width: 10
            visible: true
            onClicked: root.backClicked()
        }
    }
    Layout.fillHeight: true
    Layout.preferredWidth:  150
    //show when isSearchBar is set to false
    Label{
        text: root.title
        font.pixelSize: 18
        font.bold: true
        color: "#111111"
        visible: !root.isSearchBar
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        Layout.fillWidth: true
    }
    //show when isSearchbar set true
    AppSearchBar{
        id: searchBar
        Layout.alignment: Qt.AlignVCenter

        Layout.fillWidth: true
        visible: root.isSearchBar
        readOnly: root.searchReadOnly// binding readonly
        onSearchBarTapped: root.searchBarTapped()
    }

    Loader{
        Layout.alignment: Qt.AlignRight
        sourceComponent: root.rightAction
        //visible: status === Loader.Ready &&  item !== null
        visible: status === Loader.Ready && sourceComponent !== null
        Layout.preferredWidth: visible ? (item ? item.implicitWidth : 36) : 0
        Layout.preferredHeight: visible ? (item ? item.implicitHeight : 36) : 0
    }
}

}