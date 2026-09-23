import QtQuick
import QtQuick.Layouts
import "../../../components/indicators"

AppEmptyState {
    Layout.fillWidth: true
    Layout.topMargin: 24

    iconSource: "qrc:/ui/assets/properties-icon.svg"
    title: qsTr("Nothing here yet")
    subtitle: qsTr("There are no listings to show in this category right now.")
}
