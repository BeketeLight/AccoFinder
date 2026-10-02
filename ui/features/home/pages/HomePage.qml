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
        spacing: 3

        // Only show the section when there is at least one recent property
        readonly property int recentCount: root.propertiesModelRef ? root.propertiesModelRef.recentsPropertiesModel.count : 0

        SuperDeals {
            id: superDeals
            Layout.fillWidth: true
            Layout.preferredHeight: superDeals.visible ? (superDeals.cardHeight + 10 + 26 + 8 + 8) : 0

            visible: contentColumn.recentCount >= 1
            cardWidth: 260
            cardHeight: 160                        // the height of one card, not the whole block
            infoSectionVisible: false
            title: qsTr("New in the last 24 hours")
            model: root.propertiesModelRef ? root.propertiesModelRef.recentsPropertiesModel : null
        }

        Rectangle {
            Layout.fillWidth: true
            height: 6
            color: "#E5E7EB"
        }

        Label {
            text: root.headingText
            font.pixelSize: 16
            font.bold: true
            color: "#1F2937"
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 6
            color: "#E5E7EB"
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
