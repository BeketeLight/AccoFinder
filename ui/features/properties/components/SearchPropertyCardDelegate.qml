import QtQuick
import "../../home/delegates"

// Same PropertyCardDelegate the home feed uses, but sourcing image URLs from
// the shared MediaViewModel. PropertyListModel does not expose imageUrls, so
// the card cannot read them from the search result row — it must ask the
// media model and refresh when media arrives.
Item {
    id: root

    property string propertyId: ""
    property string propertyType: ""
    property string title: ""
    property string district: ""
    property real price: 0
    property var amenities: []
    property string status: ""
    property bool isVerified: false

    property string coverUrl: ""
    property string coverUrls: ""

    function refreshCover() {
        const media = MediaViewModel.mediaForProperty(root.propertyId);
        let primary = "";
        const all = [];
        if (media && media.length > 0) {
            for (let i = 0; i < media.length; i++) {
                const m = media[i];
                if (!m)
                    continue;
                const u = String(m.url || m.path || "");
                if (!u)
                    continue;
                all.push(u);
                if (m.isPrimary && !primary)
                    primary = u;
            }
            if (!primary)
                primary = all.length > 0 ? all[0] : "";
        }
        root.coverUrl = primary;
        root.coverUrls = all.join(",");
    }

    Component.onCompleted: {
        refreshCover();
        // Fire one media fetch if the model has nothing yet.
        const media = MediaViewModel.mediaForProperty(root.propertyId);
        if (!media || media.length === 0)
            MediaViewModel.getMediaByProperty(root.propertyId);
    }

    Connections {
        target: MediaViewModel
        function onIsLoadingChanged() {
            if (!MediaViewModel.isLoading)
                root.refreshCover();
        }
    }

    PropertyCardDelegate {
        anchors.fill: parent
        propertyId: root.propertyId
        propertyType: root.propertyType
        title: root.title
        location: root.district
        price: root.price
        imageUrl: root.coverUrl
        imageUrls: root.coverUrls
        amenities: root.amenities
        status: root.status
        isVerified: root.isVerified
        insideInfoSection: false
        isInfoSectionVisible: true
    }
}
