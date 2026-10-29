import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../pages"
import "../../../components/inputs"
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root
    objectName: "SearchPropertiesScreen"

    property string pageTitle: qsTr("Search")
    property bool showHeader: false
    property bool showBack: true
    property bool isSearchBar: false

    property string searchText: ""
    property string propertyType: ""
    property string district: ""
    property string village: ""
    property var amenities: []
    property real minPrice: 0
    property real maxPrice: 0
    property int page: 1
    readonly property int pageSize: 20
    readonly property bool priceFilterEnabled: true

    readonly property bool hasQuery: searchText.trim().length > 0 || propertyType.length > 0 || district.length > 0 || village.length > 0 || amenities.length > 0 || (priceFilterEnabled && (minPrice > 0 || maxPrice > 0))

    Timer {
        id: debounce
        interval: 300
        repeat: false
        onTriggered: root.runSearch(1)
    }

    function runSearch(targetPage) {
        console.log("[Search] runSearch. search:", searchText, "type:", propertyType, "district:", district, "village:", village, "amenities:", amenities, "price:", minPrice, "–", maxPrice);
        root.page = targetPage || 1;
        PropertyViewModel.searchProperties(root.searchText.trim(), root.propertyType.trim(), root.district.trim(), root.village.trim(), root.amenities, root.minPrice, root.maxPrice, root.page, root.pageSize);
    }

    function resetFilters() {
        searchText = "";
        propertyType = "";
        district = "";
        village = "";
        amenities = [];
        minPrice = 0;
        maxPrice = 0;
        PropertyViewModel.clearSearch();
    }

    Component.onDestruction: PropertyViewModel.clearSearch()

    background: Rectangle {
        color: "#FFFFFF"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Layout.margins: 10

        // ---- Header & Search Bar ----
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: "#FFFFFF"
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#E5E7EB"
            }
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                ToolButton {
                    icon.source: "qrc:/ui/assets/back-icons.svg"
                    icon.color: "#111111"
                    icon.height: 16
                    icon.width: 10
                    background: null
                    onClicked: NavUtils.pop()
                }

                AppSearchBar {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    placeholder: qsTr("Search by location or title")
                    text: root.searchText
                    readOnly: false
                    onTextEdited: {
                        root.searchText = text;
                        debounce.restart();
                    }
                    onCleared: {
                        root.searchText = "";
                        debounce.stop();
                        root.runSearch(1);
                    }
                    onAccepted: {
                        debounce.stop();
                        root.runSearch(1);
                    }
                }
            }
        }

        // ---- Filter Chips Row ----
        SearchFiltersRow {
            id: filtersRow
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            priceEnabled: root.priceFilterEnabled
            onFiltersChanged: {
                // Copy the values the user just set, then re-run.
                root.propertyType = filtersRow.selectedType;
                root.district = filtersRow.selectedDistrict;
                root.village = filtersRow.selectedVillage;
                root.amenities = filtersRow.selectedAmenities;
                root.minPrice = filtersRow.selectedMinPrice;
                root.maxPrice = filtersRow.selectedMaxPrice;
                root.runSearch(1);
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#F5F5F5"
        }

        // ---- Results View, Loading & Empty States ----
        SearchPropertiesPage {
            Layout.fillWidth: true
            Layout.fillHeight: true
            isSearching: PropertyViewModel.isSearching
            hasQuery: root.hasQuery
            pageSize: root.pageSize
            onLoadMoreRequested: root.runSearch(root.page + 1)
        }
    }
}
