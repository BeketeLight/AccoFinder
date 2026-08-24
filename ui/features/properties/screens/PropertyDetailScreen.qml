import QtQuick 2.15
import "../pages"
Item {
    id:propertiesdetailsId

    property var initialPayload: null

    PropertyDetailsPage{
        id: detailPage
        anchors.fill: parent
        Component.onCompleted: {
            if (initialPayload)
                detailPage.applyPayload(initialPayload)
        }
    }
}
