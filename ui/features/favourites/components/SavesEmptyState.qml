import QtQuick
import QtQuick.Layouts
import "../../../components/indicators"

// One empty state component for both tabs — the caller passes the icon and
// copy so we don't duplicate AppEmptyState twice in the page.
AppEmptyState {
    id: root

    property string kind: "property"   // "property" | "room"

    Layout.fillWidth: true
    Layout.topMargin: 60

    iconSource: root.kind === "room" ? "qrc:/ui/assets/save-icon.svg" : "qrc:/ui/assets/favorite-outline.svg"

    title: root.kind === "room" ? qsTr("No saved rooms yet") : qsTr("No saved properties yet")

    subtitle: root.kind === "room" ? qsTr("Tap the bookmark on a room to save it here for later.") : qsTr("Tap the heart on a property to save it here for later.")
}
