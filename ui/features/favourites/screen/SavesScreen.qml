import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../../components/pages"
import "../../../components/indicators"
import "../../../components/dialogs"
import "../../home/delegates"
import "../../home/components"
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../utils/ImageUtils.js" as ImageUtils

Item {
    id: root
    objectName: "SavesScreen"
    // Reached from the footer's Saves tab, which is a root-level destination
    // rather than a pushed page, so the header hides the back arrow.
    property string pageTitle: qsTr("Saves")
    property bool showHeader: true
    property bool showBack: false
    property bool showBackButton: false
    property bool showBottomBorder: true
    property bool isSearchBar: false
    property int titleFontSize: 15

    // Rebuilt from AppSettings on every favourites change.
    property var savedPropertyIds: []
    property var savedRoomIds: []
    property int currentTab: 0     // 0 = Properties, 1 = Rooms

    function reload() {
        savedPropertyIds = AppSettings.favoritePropertyIds;
        savedRoomIds = AppSettings.favoriteRoomIds;
    }

    Connections {
        target: AppSettings
        function onUserSessionChanged() {
            root.reload();
        }
        function onFavoritesChanged() {
            root.reload();
        }   // if you add one later
        function onRoomFavoritesChanged() {
            root.reload();
        }
    }

    Component.onCompleted: reload()

    Rectangle {
        anchors.fill: parent
        color: "#F8FAFC"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // =========================================================
        // TAB STRIP
        // =========================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: "#FFFFFF"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: "#E5E7EB"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 4

                Repeater {
                    model: [
                        {
                            text: qsTr("Properties"),
                            count: root.savedPropertyIds.length
                        },
                        {
                            text: qsTr("Rooms"),
                            count: root.savedRoomIds.length
                        }
                    ]

                    delegate: Item {
                        required property var model
                        required property int index
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        readonly property bool selected: root.currentTab === index

                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4
                            anchors.leftMargin: 2
                            anchors.rightMargin: 2
                            radius: 10
                            color: parent.selected ? "#EFF6FF" : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            Label {
                                text: model.text
                                font.pixelSize: 13
                                font.weight: parent.parent.selected ? Font.DemiBold : Font.Medium
                                color: parent.parent.selected ? "#2563EB" : "#6B7280"
                            }

                            Rectangle {
                                visible: model.count > 0
                                implicitWidth: countLabel.implicitWidth + 12
                                implicitHeight: 18
                                radius: 9
                                color: parent.parent.selected ? "#2563EB" : "#E5E7EB"

                                Label {
                                    id: countLabel
                                    anchors.centerIn: parent
                                    text: model.count
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: parent.parent.selected ? "#FFFFFF" : "#4B5563"
                                }
                            }
                        }

                        // Underline
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 2
                            color: parent.selected ? "#2563EB" : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTab = index
                        }
                    }
                }
            }
        }

        // =========================================================
        // CONTENT
        // =========================================================
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.currentTab

            // ===================== TAB 0 — PROPERTIES =====================
            AppScrollablePage {
                contentTopMargin: 12

                // -------- Empty state --------
                AppEmptyState {
                    Layout.fillWidth: true
                    Layout.topMargin: 60
                    visible: root.savedPropertyIds.length === 0
                    iconSource: "qrc:/ui/assets/favorite-outline.svg"
                    title: qsTr("No saved properties yet")
                    subtitle: qsTr("Tap the heart on a property to save it here for later.")
                }

                // -------- List --------
                Repeater {
                    model: root.savedPropertyIds

                    delegate: Item {
                        required property string modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 240

                        // The card itself
                        PropertyCardDelegate {
                            id: propertyCard
                            anchors.fill: parent
                            propertyId: modelData
                            // Title / location / price / image are populated
                            // lazily by the shared PropertiesModel — bind them
                            // from that model if you have one, or leave these
                            // for a snapshot-based approach.
                            title: {
                                if (!root.propertySnapshotFor)
                                    return "";
                                var snap = root.propertySnapshotFor(modelData);
                                return snap && snap.title ? snap.title : "";
                            }
                            location: ""
                            price: 0
                            imageUrl: ""
                            imageUrls: ""
                            isInfoSectionVisible: true
                            insideInfoSection: false
                        }

                        // Remove-from-saves button (top-right of the card)
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 8
                            color: "#FFFFFF"
                            border.color: "#E5E7EB"
                            border.width: 1

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/ui/assets/favorite-filled.svg"
                                sourceSize.width: 18
                                sourceSize.height: 18
                                width: 18
                                height: 18
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var ids = AppSettings.favoritePropertyIds;
                                    var idx = ids.indexOf(modelData);
                                    if (idx >= 0) {
                                        ids.splice(idx, 1);
                                        AppSettings.setFavoritePropertyIds(ids);
                                        root.reload();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ===================== TAB 1 — ROOMS =====================
            AppScrollablePage {
                contentTopMargin: 12

                // -------- Empty state --------
                AppEmptyState {
                    Layout.fillWidth: true
                    Layout.topMargin: 60
                    visible: root.savedRoomIds.length === 0
                    iconSource: "qrc:/ui/assets/save-icon.svg"
                    title: qsTr("No saved rooms yet")
                    subtitle: qsTr("Tap the bookmark on a room to save it here for later.")
                }

                // -------- List --------
                Repeater {
                    model: root.savedRoomIds

                    delegate: Item {
                        required property string modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 116

                        readonly property var snap: AppSettings.favoriteRoomSnapshot(modelData)

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: "#FFFFFF"
                            border.color: "#E5E7EB"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 12

                                // Thumbnail
                                Rectangle {
                                    Layout.preferredWidth: 96
                                    Layout.preferredHeight: 96
                                    radius: 10
                                    color: "#F1F3F4"
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: snap && snap.imageUrl ? ImageUtils.cachedSource(snap.imageUrl) : ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        visible: status === Image.Ready

                                        // Rounded mask
                                        layer.enabled: true
                                        layer.effect: MultiEffect {
                                            maskEnabled: true
                                            maskSource: roomThumbMask
                                        }
                                    }

                                    Rectangle {
                                        id: roomThumbMask
                                        anchors.fill: parent
                                        radius: 10
                                        visible: false
                                        layer.enabled: true
                                    }

                                    // Placeholder while loading
                                    Label {
                                        anchors.centerIn: parent
                                        visible: !parent.children[0].visible
                                        text: "🛏️"
                                        font.pixelSize: 28
                                        opacity: 0.35
                                    }

                                    // Availability badge
                                    Rectangle {
                                        visible: snap !== undefined
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 6
                                        height: 18
                                        radius: 9
                                        width: availLabel.implicitWidth + 12
                                        color: !snap ? "#9CA3AF" : (snap.available === false) ? "#EF4444" : (snap.holdActive === true) ? "#F59E0B" : "#22C55E"

                                        Label {
                                            id: availLabel
                                            anchors.centerIn: parent
                                            text: !snap ? "" : (snap.available === false) ? qsTr("Booked") : (snap.holdActive === true) ? qsTr("On Hold") : qsTr("Open")
                                            color: "#FFFFFF"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }
                                    }
                                }

                                // Details
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 3

                                    Label {
                                        Layout.fillWidth: true
                                        text: snap && snap.type ? snap.type : qsTr("Room")
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        color: "#1F2937"
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        visible: snap && snap.title && snap.title.length > 0
                                        text: snap && snap.title ? snap.title : ""
                                        font.pixelSize: 12
                                        color: "#6B7280"
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        visible: snap && snap.location && snap.location.length > 0

                                        Image {
                                            source: "qrc:/ui/assets/location-2955.svg"
                                            sourceSize.width: 12
                                            sourceSize.height: 12
                                            width: 12
                                            height: 12
                                            fillMode: Image.PreserveAspectFit
                                        }
                                        Label {
                                            Layout.fillWidth: true
                                            text: snap && snap.location ? snap.location : ""
                                            font.pixelSize: 11
                                            color: "#9CA3AF"
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Label {
                                        text: snap && snap.price ? "MWK " + Number(snap.price).toLocaleString(Qt.locale(), "f", 0) : ""
                                        font.pixelSize: 15
                                        font.bold: true
                                        color: "#2563EB"
                                    }
                                }

                                // Remove button
                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    Layout.alignment: Qt.AlignTop
                                    radius: 16
                                    color: "#FFFFFF"
                                    border.color: "#E5E7EB"
                                    border.width: 1

                                    Image {
                                        anchors.centerIn: parent
                                        source: "qrc:/ui/assets/favorite-filled.svg"
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        width: 18
                                        height: 18
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            AppSettings.toggleFavoriteRoom(modelData);
                                            root.reload();
                                        }
                                    }
                                }
                            }

                            // Whole-card tap — opens the room detail page.
                            MouseArea {
                                anchors.fill: parent
                                z: -1
                                onClicked: {
                                    NavUtils.push(Qt.resolvedUrl("../../home/delegates/QuartersDetailDelegate.qml"), {
                                        quarterId: snap.quarterId,
                                        propertyId: snap.propertyId,
                                        quarterType: snap.type,
                                        quarterTitle: snap.title,
                                        quarterPrice: snap.price,
                                        location: snap.location,
                                        roomImage: snap.imageUrl,
                                        isquarterAvailable: snap.available === undefined ? true : snap.available,
                                        isOnHold: snap.holdActive === true
                                    });
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
