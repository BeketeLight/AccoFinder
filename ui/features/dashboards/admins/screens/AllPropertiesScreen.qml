import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("All Properties")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal propertyClicked(var propertyId)

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: allPropsPage.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            AllPropertiesPage {
                id: allPropsPage
                anchors.horizontalCenter: parent.horizontalCenter
                y: 24
                width: flick.width > 48 ? Math.min(flick.width - 24, 520) : implicitWidth

                onPropertyClicked: function(propertyId) {
                    var payload = allPropsPage.propertiesModel.registrationPayloadFor(propertyId, "propertyId")
                    if (payload)
                        NavUtils.push(Qt.resolvedUrl("../features/properties/screens/PropertyDetailScreen.qml"),
                                      { initialPayload: payload })
                }
            }
        }
    }
}
