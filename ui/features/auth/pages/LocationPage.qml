import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property string location: locationField.text
    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

    signal nextRequested

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        Label {
            text: "Where are you looking?"
            color: root.textColor
            font.pixelSize: 26
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "Enter your area so we can show properties near you."
            color: root.mutedColor
            font.pixelSize: 14
            lineHeight: 1.15
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -6
        }

        AuthInfoCard {
            cardColor: "#EFF6FF"
            cardBorderColor: "#BFDBFE"
            accentColor: root.primaryColor
            message: "Use a suburb, town, or campus area you search around most often."
            messageColor: "#1E40AF"
            cardHeight: 70
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 7

            AuthTextField {
                id: locationField
                label: "Your area"
                placeholder: "e.g. Mzuzu, Zomba Town"
                required: true
            }
        }

        AuthErrorLabel {
            id: errorText
        }

        AuthContinueButton {
            id: continueButton
            onClicked: {
                if (locationField.text.trim().length === 0) {
                    errorText.text = "Enter the area you want to search in.";
                    return;
                }

                errorText.text = "";
                root.nextRequested();
            }
        }
    }
}