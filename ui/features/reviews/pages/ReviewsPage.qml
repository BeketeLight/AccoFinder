import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property real averageRating: 0
    property int reviewCount: 0
    property bool canReview: false
    property string canReviewReason: ""
    property bool loading: false

    property alias model: listPage.model

    signal writeRequested
    signal refreshRequested

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        ReviewHeader {
            average: root.averageRating
            count: root.reviewCount
            Layout.fillWidth: true
        }

        // Only visible when the user is eligible
        Button {
            visible: root.canReview
            text: qsTr("Write a review")
            Layout.fillWidth: true
            onClicked: root.writeRequested()
        }

        // Why they can't review (optional UX touch)
        Text {
            visible: !root.canReview && root.canReviewReason === "no-booking"
            text: qsTr("Book this property to leave a review")
            color: "#888"
        }
        Text {
            visible: root.canReviewReason === "already-reviewed"
            text: qsTr("You've already reviewed this property")
            color: "#888"
        }

        ReviewsListPage {
            id: listPage
            Layout.fillWidth: true
            Layout.fillHeight: true
            loading: root.loading
        }
    }
}
