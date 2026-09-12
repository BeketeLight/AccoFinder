import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils
Rectangle {
    id: root

    // --- CUSTOMIZABLE HEADER PROPERTIES ---
    property string titleText: "Booking Disputes"
    property string subtitleText: "Track disputes related to your bookings."
    property string headerIconSource: "qrc:/ui/assets/disputes-warning-icon.svg"
    property color headerIconBgColor: "#EEF2FE"
    property color headerIconTintColor: "#2563EB"

    // --- CUSTOMIZABLE BOTTOM ACTION BUTTON ---
    //property bool showBottomButton: true
   // property string bottomButtonText: "View all disputes"
    // property bool showViewAll: true
    //     property string viewAllText: "View all"
    //signal viewAllClicked()
    //signal bottomButtonClicked()
    property bool showViewAll: true
      property string viewAllText: "View all"
      signal viewAllClicked(string filter)

    // --- DATA MODEL FOR STAT COLUMNS ---
    // Pass custom titles, counts, colors, icons, and click actions dynamically!
    property var statsModel: [
        {
            title: "Active Disputes",
            count: 2,
            iconSourceImage: "",
            iconColor: "",
            iconBg: "#FEE2E2",
            badgeBg: "#FFE4E6",
            badgeTextColor: "#E11D48",
            actionId: "active"
        },
        {
            title: "Resolved Disputes",
            count: 4,
            iconSourceImage: "",
            iconColor: "",
            iconBg: "#DCFCE7",
            badgeBg: "#DCFCE7",
            badgeTextColor: "#16A34A",
            actionId: "resolved"
        },
        {
            title: "All Disputes",
            count: 6,
            iconSourceImage: "",
            iconColor: "",
            iconBg: "#EFF6FF",
            badgeBg: "#EFF6FF",
            badgeTextColor: "#2563EB",
            actionId: "all"
        }
    ]

    // Signal triggered when any stat column is clicked
    signal statItemClicked(string actionId, int index)

    // Layout configuration
    implicitWidth: 365
    implicitHeight: 220
    radius: 16
    color: "#FFFFFF"
    border.color: "#EAEFF5"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // --- TOP HEADER SECTION ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            // Dynamic Header Icon Container
            Rectangle {
                Layout.preferredWidth: 52
                Layout.preferredHeight: 52
                radius: width / 2
                color: root.headerIconBgColor

                ToolButton {
                    anchors.centerIn: parent
                    icon.source: root.headerIconSource
                    icon.height: 28
                    icon.width: 28
                    icon.color: root.headerIconTintColor
                    background: null
                    enabled: false // Used purely as a styled icon view
                }
            }

            // Title & Subtitle
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: root.titleText
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: "#0F172A"
                }

                Text {
                    Layout.fillWidth: true
                    text: root.subtitleText
                    font.pixelSize: 13
                    color: "#64748B"
                    wrapMode: Text.WordWrap
                }
            }
            Text {
                            visible: root.showViewAll

                            text: root.viewAllText
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: viewAllMouseArea.containsMouse ? "#1D4ED8" : "#2563EB"
                            Layout.alignment: Qt.AlignTop | Qt.AlignRight

                            MouseArea {
                                id: viewAllMouseArea
                                anchors.fill: parent
                                anchors.margins: -4 // Expands click target for easier tapping
                                //hoverEnabled: true
                                //cursorShape: Qt.PointingHandCursor
                                onClicked:root.viewAllClicked("All")
                            }
                        }
        }

        // --- MIDDLE DYNAMIC STATS COLUMNS SECTION ---
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Repeater {
                model: root.statsModel

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    // Stat Column Item
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            // Circle Icon / Symbol
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 44
                                Layout.preferredHeight: 44
                                radius: width / 2
                                color: modelData.iconBg || "#F1F5F9"

                                // Text {
                                //     anchors.centerIn: parent
                                //     text: modelData.icon || ""
                                //     font.pixelSize: 18
                                //     font.weight: Font.Bold
                                //     color: modelData.badgeTextColor || "#0F172A"
                                // }
                                ToolButton{
                                    anchors.centerIn: parent
                                    icon.source: modelData.iconSourceImage
                                    icon.height: 22
                                    icon.width: 22
                                    icon.color: modelData.iconColor
                                    background: null
                                    enabled: true
                                }
                            }

                            // Title Label
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.title || ""
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: "#0F172A"
                                horizontalAlignment: Text.AlignHCenter
                            }

                            // Count Badge Pill
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 26
                                Layout.preferredHeight: 26
                                radius: 13
                                color: modelData.badgeBg || "#F1F5F9"

                                Text {
                                    anchors.centerIn: parent
                                    text: (modelData.count !== undefined) ? modelData.count.toString() : "0"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: modelData.badgeTextColor || "#0F172A"
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.statItemClicked(modelData.actionId || "", index)
                            }
                        }
                    }

                    // Vertical Divider (drawn after each column except the last one)
                    Rectangle {
                        visible: index < root.statsModel.length - 1
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 60
                        Layout.alignment: Qt.AlignVCenter
                        color: "#F1F5F9"
                    }
                }
            }
        }
    }
}