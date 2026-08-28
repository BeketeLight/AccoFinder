import QtQuick
import "../pages"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("Drafts")
    property bool showHeader: true
    property bool showBack: true
    property bool showBackButton: true
    property bool isSearchBar: false
    property int titleFontSize: 20
    property bool showBottomBorder: false

    function goBack() {
        NavUtils.pop()
    }

    DraftsPage {
        id: draftsPage
        anchors.fill: parent

        onResendRequested: function (key) {
            // Re-submit through DraftViewModel so the draft is removed ONLY on
            // success and kept on failure (a failed upload must stay recoverable).
            DraftViewModel.resendDraft(key)
        }

        onOpenRequested: function (key) {
            var draft = DraftViewModel.getDraft(key)
            if (!draft)
                return
            draft.draftKey = key
            NavUtils.push("../features/properties/screens/PropertyDetailScreen.qml",
                          { initialPayload: draft })
        }

        onDeleteRequested: function (key) {
            DraftViewModel.removeDraft(key)
        }
    }
}
