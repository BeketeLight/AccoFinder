import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../pages"

Page {
    id: root

    property string propertyId: ""
    property string agentId: ""

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "←"
                onClicked: stackView.pop()
            }
            Label {
                text: qsTr("Write a review")
                font.bold: true
            }
        }
    }

    WriteReviewsPage {
        anchors.fill: parent
        submitting: ReviewViewModel.loading

        onSubmit: (rating, comment) => {
            ReviewViewModel.submitReview(root.propertyId, root.agentId, rating, comment);
        }

        onCancel: stackView.pop()
    }

    Connections {
        target: ReviewViewModel
        function onErrorOccurred(msg) { /* show a toast / dialog */
        }
    }

    Connections {
        target: ReviewViewModel.model
        function onCountChanged() {
            // when a new review lands, pop back to the list
            if (ReviewViewModel.model.count > 0 && !ReviewViewModel.loading)
                stackView.pop();
        }
    }
}
