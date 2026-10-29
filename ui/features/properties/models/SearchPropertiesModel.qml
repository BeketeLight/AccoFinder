import QtQuick

// Reactive wrapper around PropertyViewModel.searchResultModel.
//
// The C++ PropertyListModel does not expose a Q_PROPERTY for its row count,
// so reading `searchResultModel.size()` from QML returns a one-time snapshot
// that never updates. This model re-mirrors the C++ rows whenever they
// change, so `.count` is a normal QML property that any binding can observe.
//
// One instance per screen. Never shared — each search screen owns its own.
Item {
    id: root

    readonly property alias model: searchModel
    readonly property int count: searchModel.count

    ListModel {
        id: searchModel
    }
    function reload() {
        searchModel.clear();
        const src = PropertyViewModel.searchResultModel;
        const n = src ? src.size() : 0;
        console.log("[SearchModel] reload. src size:", n);
        for (let i = 0; i < n; i++) {
            const row = src.at(i);
            if (!row)
                continue;
            searchModel.append({
                propertyId: row.id || "",
                title: row.title || "",
                district: row.district || "",
                village: row.village || "",
                price: Number(row.price || 0),
                propertyType: row.propertyType || "",
                status: row.status || "",
                verificationStatus: row.verificationStatus || "",
                amenities: row.amenities || [],
                imageUrls: row.imageUrls || ""
            });
        }
        console.log("[SearchModel] reload complete. mirrored count:", searchModel.count);
    }

    Connections {
        target: PropertyViewModel.searchResultModel
        function onCountChanged() {
            console.log("[SearchModel] C++ countChanged ->", PropertyViewModel.searchResultModel.size());
            root.reload();
        }
        function onModelReset() {
            console.log("[SearchModel] C++ modelReset");
            root.reload();
        }
        function onDataChanged() {
            console.log("[SearchModel] C++ dataChanged");
            root.reload();
        }
        function onRowsInserted() {
            console.log("[SearchModel] C++ rowsInserted");
            root.reload();
        }
        function onRowsRemoved() {
            console.log("[SearchModel] C++ rowsRemoved");
            root.reload();
        }
    }

    Connections {
        target: PropertyViewModel
        function onIsSearchingChanged() {
            console.log("[SearchModel] isSearching ->", PropertyViewModel.isSearching);
            if (!PropertyViewModel.isSearching)
                root.reload();
        }
    }

    Component.onCompleted: reload()
}
