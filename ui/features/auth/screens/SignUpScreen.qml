import QtQuick
import "../pages"
Item {
    id: signUpItemId
    property alias pageTitle: signUpPage.pageTitle
    property alias showHeader: signUpPage.showHeader

    function goBack() {
        signUpPage.goBack()
    }

    SignUpPage {
        id: signUpPage
        anchors.fill: parent
    }
}
