import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../components/indicators"

Item {
    id: root

    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softBlueColor: "#EFF6FF"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"
    readonly property color pageColor: "#F8FAFC"

    property string pageTitle: qsTr("Notifications")
    property bool showHeader: true
    property bool showBack: true
    property bool showBackButton: false
    property bool isSearchBar: false
    property int titleFontSize: 18
    property bool showBottomBorder: false

    readonly property var notificationsModel: NotificationViewModel.notificationListModel

    property bool refreshing: false
    property bool loading: false
    property double _refreshStart: 0
    property int _minVisible: 600

    readonly property bool busy: NotificationViewModel.isLoading

    Timer {
        id: hideLoaderTimer
        interval: root._minVisible
        repeat: false
        onTriggered: root.loading = false
    }

    function refresh() {
        if (root.refreshing || root.loading)
            return
        root._refreshStart = Date.now()
        root.refreshing = true
        root.loading = true
        NotificationViewModel.getNotifications()
    }

    function onRequestsSettled() {
        if (root.busy)
            return
        root.refreshing = false
        var elapsed = Date.now() - root._refreshStart
        var remain = root._minVisible - elapsed
        if (remain > 0) {
            hideLoaderTimer.interval = remain
            hideLoaderTimer.restart()
        } else {
            hideLoaderTimer.stop()
            root.loading = false
        }
    }

    property bool pullArmed: false

    function armIfPulled() {
        if (flick.dragging && flick.contentY <= -56)
            root.pullArmed = true
    }

    function handlePullRelease() {
        if (root.pullArmed && !root.refreshing && !root.loading) {
            root.refresh()
            flick.returnToBounds()
        }
        root.pullArmed = false
    }

    function goBack() {
        NavUtils.pop()
    }

    Component.onCompleted: root.refresh()

    Connections {
        target: NotificationViewModel
        function onIsLoadingChanged(loading) { root.onRequestsSettled() }
    }

    Rectangle {
        anchors.fill: parent
        color: root.pageColor

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: contentColumn.implicitHeight + 48
            clip: true
            boundsBehavior: Flickable.DragAndOvershootBounds

            onContentYChanged: root.armIfPulled()
            onDragEnded: root.handlePullRelease()

            ScrollBar.vertical: ScrollBar { }

            ColumnLayout {
                id: contentColumn
                x: Math.max(12, (flick.width - 520) / 2)
                y: 20
                width: Math.min(flick.width - 24, 520)
                spacing: 16

                Rectangle {
                    visible: root.notificationsModel.count > 0
                    Layout.fillWidth: true
                    implicitHeight: notifCol.implicitHeight
                    radius: 12
                    color: root.surfaceColor
                    border.color: root.borderColor
                    border.width: 1

                    ColumnLayout {
                        id: notifCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 0

                        Repeater {
                            model: root.notificationsModel

                            delegate: ColumnLayout {
                                required property var model
                                required property int index
                                Layout.fillWidth: true
                                spacing: 0

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: notifRow.implicitHeight + 20
                                    color: model.unread ? root.softBlueColor : "transparent"

                                    RowLayout {
                                        id: notifRow
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10

                                        Rectangle {
                                            Layout.preferredWidth: 8
                                            Layout.preferredHeight: 8
                                            radius: 4
                                            color: model.unread ? root.primaryColor : "transparent"
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1

                                            Label {
                                                Layout.fillWidth: true
                                                text: model.title
                                                color: root.textColor
                                                font.pixelSize: 13
                                                font.bold: model.unread
                                                elide: Text.ElideRight
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                text: model.message
                                                color: root.mutedColor
                                                font.pixelSize: 11
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    visible: index < root.notificationsModel.count - 1
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 1
                                    color: root.borderColor
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    visible: root.notificationsModel.count === 0
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    spacing: 6

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: root.softBlueColor
                        border.color: "#BFDBFE"
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            source: "qrc:/ui/assets/notification.svg"
                            sourceSize.width: 20
                            sourceSize.height: 20
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("No notifications")
                        color: root.textColor
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("You're all caught up for now.")
                        color: root.mutedColor
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        // Non-blocking spinner centered on the page, shown on first load and
        // whenever a pull-to-refresh triggers a backend call.
        AppSpinner {
            visible: root.loading || root.refreshing
            anchors.centerIn: parent
            z: 20
            size: 32
            lineWidth: 3
            color: root.primaryColor
            running: root.loading || root.refreshing
        }
    }
}
