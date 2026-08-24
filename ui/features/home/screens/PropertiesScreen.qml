import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../models"

Item {
    id: root

    // ========== MODEL ==========
    PropertyListModel {
        id: propertyModel
    }

    // ========== MAIN CONTENT ==========
    PropertiesPage {
        id: propertiesPage
        anchors.fill: parent
        model: propertyModel

        onPropertyClicked: function (propertyId) {
            console.log("Open property details:", propertyId);
        // Later: stackView.push(propertyDetailScreen, { propertyId: propertyId })
        }

        onFavoriteClicked: function (propertyId) {
            console.log("Toggle favorite:", propertyId);
        // Later: call a favorite service / update model
        }

        onCategorySelected: function (categoryName) {
            console.log("Filter by category:", categoryName);
            // Simple example filter (client-side)
            // For production you should filter in C++ or use a SortFilterProxyModel
            filterByCategory(categoryName);
        }
    }

    // ========== SIMPLE CLIENT-SIDE FILTER (optional helper) ==========
    function filterByCategory(categoryName) {
        if (categoryName === "All") {
            // Reset to full model – easiest way with ListModel is to rebuild
            // or keep an original copy. For now just log.
            console.log("Show all properties");
            return;
        }

        // Example: you can later implement real filtering
        console.log("Would filter properties where category ===", categoryName);
    }

    // ========== PUBLIC API (optional) ==========
    function refresh() {
        // Later: call backend to reload properties
        console.log("Refreshing properties...");
    }
}
