import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"

Page {
    id: root

    property string propertyId: ""

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "←"
                onClicked: stackView.pop()      // assumes a StackView in scope
            }
            Label {
                text: qsTr("Reviews")
                font.bold: true
            }
        }
    }

    ReviewsPage {
        anchors.fill: parent
        model: ReviewViewModel.model
        loading: ReviewViewModel.loading
        averageRating: ReviewViewModel.averageRating
        reviewCount: ReviewViewModel.reviewCount
        canReview: ReviewViewModel.canReview
        canReviewReason: ReviewViewModel.canReviewReason

        onWriteRequested: stackView.push(writeScreenComponent)
    }

    Component {
        id: writeScreenComponent
        WriteReviewScreen {
            // propertyId: root.propertyId
        }
    }

    Component.onCompleted: {
        ReviewViewModel.loadForProperty(root.propertyId);
        ReviewViewModel.loadSummary(root.propertyId);
        ReviewViewModel.checkCanReview(root.propertyId);
    }

    Component.onDestruction: {
        ReviewViewModel.model.clear();
    }
}
