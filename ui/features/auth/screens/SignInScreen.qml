import QtQuick
import "../pages"
Item {
    id: signItemId
    property alias pageTitle: signInPage.pageTitle
    property alias showHeader: signInPage.showHeader

    SignInPage {
        id: signInPage
        anchors.fill: parent
    }
}
