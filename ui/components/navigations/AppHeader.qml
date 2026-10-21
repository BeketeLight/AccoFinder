import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../inputs"

ToolBar {
    id: root

    property string title: ""
    property bool isSearchBar: false
    property bool showBackButton: false
    property Component leftAction: null
    property Component rightAction: null
    property bool searchReadOnly: false
    property int titleFontSize: 15
    property bool showBottomBorder: true
    //For collapsible header use leftAction(define name + notificationBell)
    //or for bell you can also use rightAction
    //Then stet searchBar to true
    property bool transparentHeader: false
    property bool collapsible: false
    property real scrollY: 0
    // Collapsible header
    readonly property real expandedHeight: 110
    readonly property real collapsedHeight: 56
    // Solid bar: normal pages always; overlay pages after scroll
    readonly property bool solidHeader:{
        if(!transparentHeader) return true
        return scrollY > 40
    }
    readonly property real collapseDistance: 48
    readonly property real collapseProgress: {
        if (!collapsible) return 0
        return Math.min(1, Math.max(0, scrollY / collapseDistance))
    }
    //Signals
    signal backClicked()
    signal searchBarTapped()
    signal menuButtonClicked()

    implicitHeight: {
        if (root.collapsible) {
            // Logo + search
            return expandedHeight - (expandedHeight - collapsedHeight) * collapseProgress
        }
        // single toolbar row
        return 56
    }
    clip: true
    Behavior on implicitHeight {
        NumberAnimation { duration: 40; easing.type: Easing.OutCubic }
    }

    background: Rectangle {
        color: root.transparentHeader && !root.solidHeader
             ? "transparent"
             : "#FFFFFF"

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#E0E0E0"
            // bottomborder only when the bar is solid
            visible: root.showBottomBorder && root.solidHeader
                     && (!root.collapsible || root.collapseProgress > 0.05)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 12
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        spacing: 0

        // Collapsible arrangments:
        Item {
            id: topSlot
            Layout.fillWidth: true
            visible: root.collapsible
            Layout.preferredHeight: root.collapsible
                ? Math.round(44 * (1 - root.collapseProgress))
                : 0
            Layout.maximumHeight: Layout.preferredHeight
            clip: true

            RowLayout {
                width: parent.width
                height: 44
                y: parent.height - height
                opacity: 1 - root.collapseProgress
                spacing: 4

                Loader {
                    sourceComponent: root.leftAction
                        ? root.leftAction
                        : (root.showBackButton ? backButtonComponent : null)
                    visible: status === Loader.Ready && item !== null
                    Layout.preferredWidth: visible ? (item ? item.implicitWidth : 36) : 0
                    Layout.preferredHeight: visible ? (item ? item.implicitHeight : 36) : 0
                    Layout.alignment: Qt.AlignVCenter
                }

                Label {
                    text: root.title
                    font.pixelSize: root.titleFontSize
                    font.bold: true
                    color: "#111111"
                    visible: root.title.length > 0
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Item { Layout.fillWidth: true; visible: root.title.length === 0 }

                Loader {
                    sourceComponent: root.rightAction
                    visible: status === Loader.Ready && sourceComponent !== null
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.preferredWidth: visible ? (item ? item.implicitWidth : 36) : 0
                }
            }
        }

        // ── SEARCH + BACK on one row (non-collapsible pages) ──
        //    OR search alone under collapsed home header
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: {
                if (root.isSearchBar)
                    return 48
                if (!root.collapsible)
                    return 48   // title-only toolbar height
                return 0
            }
            Layout.maximumHeight: Layout.preferredHeight
            spacing: 4
            visible: Layout.preferredHeight > 0

            // Back only when NOT collapsible (detail / list pages)
            Loader {
                sourceComponent: (!root.collapsible && root.showBackButton && !root.leftAction)
                    ? backButtonComponent
                    : ((!root.collapsible && root.leftAction) ? root.leftAction : null)
                visible: status === Loader.Ready && item !== null
                Layout.preferredWidth: visible ? (item ? item.implicitWidth : 40) : 0
                Layout.preferredHeight: visible ? (item ? item.implicitHeight : 40) : 0
                Layout.alignment: Qt.AlignVCenter
            }

            // Title when no search (simple pages)
            Label {
                text: root.title
                font.pixelSize: root.titleFontSize
                font.bold: true
                color: "#111111"
                visible: !root.isSearchBar && root.title.length > 0
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            AppSearchBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                visible: root.isSearchBar
                readOnly: root.searchReadOnly
                onSearchBarTapped: root.searchBarTapped()
            }
            // Right actions on non-collapsible pages
            Loader {
                sourceComponent: !root.collapsible ? root.rightAction : null
                visible: status === Loader.Ready && sourceComponent !== null
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                Layout.preferredWidth: visible ? (item ? item.implicitWidth : 36) : 0
            }
        }
    }
    Component {
        id: backButtonComponent
        ToolButton {
            implicitHeight: 40
            implicitWidth: 40
            icon.source: "qrc:/ui/assets/back-icons.svg"
            icon.color: root.transparentHeader && !root.solidHeader
                      ? "#FFFFFF" : "#111111"
            icon.height: 16
            icon.width: 10
            onClicked: root.backClicked()
        }
    }
}