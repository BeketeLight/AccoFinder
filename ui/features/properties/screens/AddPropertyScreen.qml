import QtQuick
import "../pages"

Item {
    id: addItemdId

    property alias pageTitle: addPropertyPage.pageTitle
    property alias showHeader: addPropertyPage.showHeader

    function goBack() {
        addPropertyPage.goBack()
    }

    AddPropertiesPage {
        id: addPropertyPage
        anchors.fill: parent

        onPropertySubmitted: function (payload) {
            console.log("Property submitted for verification:", JSON.stringify(payload.name))
        }

        onDraftSaved: function (payload) {
            console.log("Property draft saved:", JSON.stringify(payload.name))
        }
    }
}
