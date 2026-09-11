import QtQuick

Image {
    id: root

    property string remoteUrl: ""

    source: remoteUrl.length > 0 ? "image://cached/" + encodeURIComponent(remoteUrl) : ""

    asynchronous: true
    cache: true
    fillMode: Image.PreserveAspectCrop

    // Optional: a subtle fade-in when a remote image arrives, so cards
    // don't pop. The delegate's skeleton sits behind this and disappears
    // automatically once status === Image.Ready.
    opacity: (source.toString().length === 0 || status === Image.Ready) ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }
}
