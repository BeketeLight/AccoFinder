import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property var propertiesModelRef: null
    property bool showSuperDeals: true
    property string headingText: qsTr("All Properties")
    property string renderAs: "property"

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        SuperDeals {
            visible: root.showSuperDeals
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 190 : 0
            cardWidth: 220
            cardHeight: 130
            title: qsTr("Super Deals")
            model: root.propertiesModelRef ? root.propertiesModelRef.propertiesModel : null
        }

        Label {
            text: root.headingText
            font.pixelSize: 16
            font.bold: true
            color: "#1F2937"
            Layout.fillWidth: true
            Layout.topMargin: 4
        }

        PropertyLoadingSkeleton {
            Layout.fillWidth: true
            visible: root.propertiesModelRef ? (root.propertiesModelRef.loading && root.propertiesModelRef.visibleCount === 0) : false
        }

        HomeListPage {
            Layout.fillWidth: true
            propertiesModelRef: root.propertiesModelRef
            renderAs: root.renderAs
        }

        PropertyEmptyState {
            Layout.fillWidth: true
            visible: root.propertiesModelRef ? (!root.propertiesModelRef.loading && root.propertiesModelRef.visibleCount === 0) : false
        }
    }
}
