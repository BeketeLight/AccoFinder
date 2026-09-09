import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../components/indicators"
import "../../../components/pages"
import "../delegates"

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
    property int titleFontSize: 15
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

    function goBack() {
        NavUtils.pop()
    }

    Component.onCompleted: root.refresh()

    Connections {
        target: NotificationViewModel
        function onIsLoadingChanged(loading) { root.onRequestsSettled() }
    }

    AppScrollablePage {
        anchors.fill: parent
        pullEnabled: true
        refreshing: root.refreshing
        loading: root.loading || root.refreshing
        contentTopMargin: 20
        onRefreshRequested: root.refresh()

        ColumnLayout {
            Layout.fillWidth: true
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

                    Button {
                        visible: root.notificationsModel.unreadCount > 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        text: qsTr("Mark all as read")
                        flat: true

                        contentItem: Label {
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("Mark all as read")
                            color: root.primaryColor
                            font.pixelSize: 12
                            font.bold: true
                        }

                        background: Rectangle {
                            color: root.softBlueColor
                        }

                        onClicked: {
                            NotificationViewModel.markAllRead()
                            // Give the backend a beat to persist, then pull
                            // the fresh list so the badge and rows update.
                            Qt.callLater(function() {
                                NotificationViewModel.getNotifications()
                            })
                        }
                    }

                    Repeater {
                        model: root.notificationsModel

                        delegate: NotificationDelegate {
                            notificationId: model.id
                            title: model.title
                            message: model.message
                            unread: model.unread
                            showSeparator: index < root.notificationsModel.count - 1
                        }
                    }
                }
            }

            AppEmptyState {
                visible: root.notificationsModel.count === 0
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
                iconSource: "qrc:/ui/assets/notification.svg"
                title: qsTr("No notifications")
                subtitle: qsTr("You're all caught up for now.")
            }
        }
    }
}