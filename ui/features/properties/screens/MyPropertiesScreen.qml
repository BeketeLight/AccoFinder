import QtQuick
import "../pages"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("My property")
    property bool showHeader: true
    property bool showBack: true
    property bool showBackButton: false
    property bool isSearchBar: false
    property int titleFontSize: 18
    property bool showBottomBorder: false

    function goBack() {
        NavUtils.pop()
    }

    Rectangle {
        anchors.fill: parent
        color: "#F8FAFC"

        MyPropertiesSection {
            id: myProperties
            anchors.fill: parent

            onAddPropertyRequested: NavUtils.navigateToAddProperty()
            onPropertyClicked: function (propertyId) {
                var payload = myProperties.payloadForId(propertyId)
                if (!payload) {
                    console.log("No property found:", propertyId)
                    return
                }
                NavUtils.push("../features/properties/screens/PropertyDetailScreen.qml",
                              { initialPayload: payload })
            }
            onDraftClicked: function (payload) {
                NavUtils.push("../features/properties/screens/PropertyDetailScreen.qml",
                              { initialPayload: payload || {} })
            }
        }
    }
}
