import QtQuick
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../components/pages"

Item {
    id: root

    property string pageTitle: qsTr("All Properties")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal propertyClicked(var propertyId)

    AppScrollablePage {
        anchors.fill: parent
        loading: PropertyViewModel.isLoading

        AllPropertiesPage {
            id: allPropsPage
            Layout.fillWidth: true

            onPropertyClicked: function(propertyId) {
                var payload = allPropsPage.propertiesModel.registrationPayloadFor(propertyId, "propertyId")
                if (payload)
                    NavUtils.push(Qt.resolvedUrl("../../../properties/screens/PropertyDetailScreen.qml"),
                                  { initialPayload: payload })
            }
        }
    }
}
