import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("AccoFinder")
    property bool showHeader: true
    property bool showBackButton: false
    property bool isSearchBar: false
    property int titleFontSize: 25
    property bool showBottomBorder: false
    property bool searchReadOnly: true

    readonly property bool isAgentUser: AppSettings.userType() === "AGENT"
                                        || AppSettings.userType() === "ADMIN"

    function onSearchBarTapped() {
        NavUtils.navigateToSearchScreen()
    }

    property Component rightComponentAction: Component {
        Item {
            implicitWidth: 36
            implicitHeight: 36

            ToolButton {
                anchors.centerIn: parent
                icon.color: "#1F2937"
                icon.height: 24
                icon.width: 24
                icon.source: "qrc:/ui/assets/notification.svg"
                onClicked: NavUtils.navigateToNotifications()
            }
        }
    }

    PropertiesPage {
        id: propertiesPage
        anchors.fill: parent
        visible: root.isAgentUser

        onAddPropertyRequested: NavUtils.navigateToAddProperty()
        onAttentionClicked: function (propertyTitle) {
            var payload = propertiesPage.listModel.registrationPayloadFor(propertyTitle, "title")
            if (!payload) {
                console.log("No property found for attention item:", propertyTitle)
                return
            }
            NavUtils.push("../features/properties/screens/PropertyDetailScreen.qml",
                          { initialPayload: payload })
        }
        onPropertyClicked: function (propertyId) {
            var payload = propertiesPage.listModel.registrationPayloadFor(propertyId, "propertyId")
            if (!payload) {
                console.log("No property found:", propertyId)
                return
            }
            NavUtils.push("../features/properties/screens/PropertyDetailScreen.qml",
                          { initialPayload: payload })
        }
        onBookingClicked: NavUtils.navigateToBookings()
        onNotificationClicked: NavUtils.navigateToNotifications()
        onDisputeClicked: NavUtils.navigateToDisputes()
    }

    Rectangle {
        anchors.fill: parent
        visible: !root.isAgentUser
        color: "#F8FAFC"

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width - 48, 360)
            spacing: 14

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 72
                Layout.preferredHeight: 72
                radius: 20
                color: "#EFF6FF"
                border.color: "#BFDBFE"
                border.width: 1

                Rectangle {
                    anchors.centerIn: parent
                    width: 26
                    height: 20
                    radius: 4
                    color: "transparent"
                    border.color: "#2563EB"
                    border.width: 2.5

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: -8
                        width: 14
                        height: 12
                        radius: 7
                        color: "transparent"
                        border.color: "#2563EB"
                        border.width: 2.5
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Agent access only")
                color: "#1F2937"
                font.pixelSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Property management is available to agents and administrators. Sign in with an agent account to continue.")
                color: "#6B7280"
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Button {
                id: signInGateButton
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 180
                Layout.preferredHeight: 46
                text: qsTr("Sign in as agent")

                contentItem: Label {
                    text: signInGateButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 12
                    color: signInGateButton.down ? "#1D4ED8" : "#2563EB"
                }

                onClicked: NavUtils.resetToSignIn()
            }
        }
    }
}
