import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    flags: {
        if (Qt.platform.os === "android") {
            return Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint
        } else {
            return Qt.Window
        }
    }

    Component.onCompleted: {
        AppSettings.setStatusBarAppearance(Qt.rgba(0,0,0,0),true)
    }

    BusyIndicator {
        anchors.centerIn: parent
    }
}
