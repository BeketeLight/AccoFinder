import QtQuick
import "../pages"
Item {
    id: signItemId
    property alias pageTitle: signInPage.pageTitle
    property alias showHeader: signInPage.showHeader
    property alias showBottomBorder: signInPage.showBottomBorder

    SignInPage {
        id: signInPage
        anchors.fill: parent
    }
}
