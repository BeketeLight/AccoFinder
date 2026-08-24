import QtQuick
import "../pages"
import "../../../utils/NavigationUtils.js" as NavUtils

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

        onRegistrationFinished: function (payload) {
            NavUtils.replace("../features/properties/screens/PropertyDetailScreen.qml",
                             { initialPayload: payload })
        }
    }
}
