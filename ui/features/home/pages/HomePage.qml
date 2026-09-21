import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../delegates"

Item {
    id: root

    // Injected by HomeScreen.
    property var propertiesModelRef: null

    // Which chip is active. Drives both the filter and the Super Deals
    // visibility.
    property string selectedCategory: "All"
    readonly property var categories: ["All", "Hostels", "Quarters", "House"]

    // "All" maps to "ALL"; the rest map to the backend's enum values.
    function filterFor(category) {
        switch (category) {
        case "Hostels":
            return "HOSTEL";
        case "Quarters":
            return "QUARTER";
        case "House":
            return "WHOLE";
        default:
            return "ALL";
        }
    }

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        // ---------- Category chips ----------
        // Full-bleed row of chips. Because AppScrollablePage centers its
        // content column at 520px max, the chips sit within that column
        // rather than bleeding edge-to-edge — consistent with the rest of
        // the app's dashboard sections.
        Item {
            Layout.fillWidth: true
            implicitHeight: 44

            PropertyCategoryRow {
                id: categoryRow
                anchors.fill: parent
                model: ListModel {
                    ListElement {
                        name: "All"
                    }
                    ListElement {
                        name: "Hostels"
                    }
                    ListElement {
                        name: "Quarters"
                    }
                    ListElement {
                        name: "House"
                    }
                }
                currentIndex: root.categories.indexOf(root.selectedCategory)
                onCategoryClicked: function (index, name) {
                    root.selectedCategory = name;
                    if (root.propertiesModelRef)
                        root.propertiesModelRef.setFilter(root.filterFor(name));
                }
            }
        }

        // ---------- Super Deals (only on All) ----------
        SuperDeals {
            visible: root.selectedCategory === "All"
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 190 : 0
            cardWidth: 220
            cardHeight: 130
            infoSectionVisible: false
            title: qsTr("Super Deals")
            model: root.propertiesModelRef ? root.propertiesModelRef.propertiesModel : null
        }

        // ---------- Section header ----------
        Label {
            text: root.selectedCategory === "All" ? qsTr("All Properties") : qsTr(root.selectedCategory)
            font.pixelSize: 16
            font.bold: true
            color: "#1F2937"
            Layout.fillWidth: true
            Layout.topMargin: 4
        }

        // ---------- The grid (or skeleton, or empty state) ----------
        PropertyLoadingSkeleton {
            Layout.fillWidth: true
            visible: root.propertiesModelRef ? (root.propertiesModelRef.loading && root.propertiesModelRef.visibleCount === 0) : false
        }

        HomeListPage {
            Layout.fillWidth: true
            implicitHeight: _implicitContentHeight()
            propertiesModelRef: root.propertiesModelRef
            renderAs: root.selectedCategory === "Quarters" ? "quarter" : "property"

            // HomeListPage exposes the computed height of its Flow so the
            // outer AppScrollablePage column sizes itself correctly.
            function _implicitContentHeight() {
                return 0;
            }   // placeholder — see file 7
        }

        PropertyEmptyState {
            Layout.fillWidth: true
            visible: root.propertiesModelRef ? (!root.propertiesModelRef.loading && root.propertiesModelRef.visibleCount === 0) : false
        }
    }
}
