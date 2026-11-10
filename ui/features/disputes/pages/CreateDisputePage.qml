import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts
// import "../../../features/properties/components"
// import "../../../utils/Utils.js" as Formator
// import "../../../components/inputs"
// import "../../../utils/NavigationUtils.js" as NavUtils

// Page {
//     id: root

//     // Must exist so push({ ... }) can assign them
//     property string bookingId: ""
//     property string propertyImage: ""
//     property string propertyLocation: ""
//     property string houseName: ""
//     property string landlord: ""
//     property string hostName: ""
//     property string status: ""
//     property string bookingDate: ""
//     property real price: 0.0

//     property string pageTitle: qsTr("Raise a dispute")
//     property bool showHeader: true
//     property bool showBack: true
//     property bool isSearchBar: false
//     property bool collapsible: false
//     property bool transparentHeader: false

//     property string issueText: ""

//     function goBack() { NavUtils.pop() }

//     // ... form UI using root.bookingId, root.houseName, etc.
//     ScrollView {
//             id: mainScrollView
//             anchors.fill: parent
//             contentWidth: availableWidth
//             clip: true

//             ColumnLayout {
//                 width: Math.min(mainScrollView.availableWidth - 32, 600)
//                 anchors.horizontalCenter: parent.horizontalCenter
//                 anchors.top: parent.top
//                 anchors.topMargin: 16
//                 spacing: 16

//                 // 1. Info Banner
//                 Rectangle {
//                     Layout.fillWidth: true
//                     implicitHeight: infoLayout.implicitHeight + 24
//                     color: "#EFF6FF"
//                     radius: 12
//                     border.color: "#BFDBFE"

//                     RowLayout {
//                         id: infoLayout
//                         anchors.fill: parent
//                         anchors.margins: 12
//                         spacing: 12

//                         ToolButton {
//                             icon.source: "qrc:/ui/assets/global-icons/information-icon.svg"
//                             icon.width: 16
//                             icon.height: 16
//                             background: null
//                             icon.color: "#111111"
//                             Layout.alignment: Qt.AlignTop
//                         }

//                         ColumnLayout {
//                             Layout.fillWidth: true
//                             spacing: 2

//                             Text {
//                                 text: "Your dispute will be reviewed by AccoFinder team."
//                                 font.pixelSize: 13
//                                 font.bold: true
//                                 color: "#1E40AF"
//                                 wrapMode: Text.WordWrap
//                                 Layout.fillWidth: true
//                             }

//                             Text {
//                                 text: "We'll get back to you as soon as possible."
//                                 font.pixelSize: 12
//                                 color: "#3B82F6"
//                                 wrapMode: Text.WordWrap
//                                 Layout.fillWidth: true
//                             }
//                         }
//                     }
//                 }

//                 // 2. Booking Context Card
//                 ColumnLayout {
//                     Layout.fillWidth: true
//                     spacing: 6

//                     SectionHeader{
//                         Layout.fillWidth: true
//                         title: qsTr("Booking details")
//                     }

//                     Rectangle {
//                         Layout.fillWidth: true
//                         implicitHeight: bookingColumn.implicitHeight + 20
//                         color: "#FFFFFF"
//                         radius: 12
//                         border.color: "#E2E8F0"



//                         ColumnLayout {
//                             id: bookingColumn
//                             anchors.fill: parent
//                             anchors.margins: 10
//                             spacing: 2
//                             RowLayout{
//                                 Text{
//                                     text:qsTr("Booking ID:")
//                                     font.pixelSize: 13
//                                     color: "#64748B"
//                                 }
//                                 Item{Layout.preferredWidth: 90}
//                                 Text {
//                                     text: root.bookingId
//                                     font.pixelSize: 14
//                                     color: "#64748B"
//                                     elide: Text.ElideRight
//                                     Layout.fillWidth: true
//                                 }
//                             }
//                             RowLayout{
//                                 Text{
//                                     text:qsTr("Property:")
//                                     font.pixelSize: 13
//                                     color: "#64748B"
//                                 }
//                                 Item{Layout.preferredWidth: 100}
//                                 Text {
//                                     text: root.houseName
//                                     font.pixelSize: 14
//                                     color: "#64748B"
//                                     elide: Text.ElideRight
//                                     Layout.fillWidth: true
//                                 }
//                             }
//                             RowLayout{
//                                 Text{
//                                     text:qsTr("Booking Date:")
//                                     font.pixelSize: 13
//                                     color: "#64748B"
//                                 }
//                                 Item{Layout.preferredWidth: 70}
//                                 Text {
//                                     text: root.bookingDate
//                                     font.pixelSize: 14
//                                     font.bold: false
//                                     color: "#64748B"
//                                     elide: Text.ElideRight
//                                     Layout.fillWidth: true
//                                 }
//                             }
//                         }
//                     }
//                 }

//                 // 3. Issue Selection Dropdown
//                 ColumnLayout {
//                     Layout.fillWidth: true
//                     spacing: 6
//                     SectionHeader{
//                         Layout.fillWidth: true
//                         title: qsTr("Payment")
//                     }
//                     Rectangle {
//                         Layout.fillWidth: true
//                         implicitHeight: bookingCol.implicitHeight + 20
//                         color: "#FFFFFF"
//                         radius: 12
//                         border.color: "#E2E8F0"

//                         ColumnLayout {
//                             id: bookingCol
//                             anchors.fill: parent
//                             anchors.margins: 10
//                             spacing: 2
//                             RowLayout{
//                                 Text{
//                                     text:qsTr("Amount Paid:")
//                                     font.pixelSize: 12
//                                     font.bold: false
//                                     color: "#64748B"
//                                 }
//                                 Item{Layout.preferredWidth: 150}
//                                 Text {
//                                     text: Formator.formatCurrency(root.price)
//                                     font.pixelSize: 14
//                                     font.bold: false
//                                     color: "#64748B"
//                                     elide: Text.ElideRight
//                                     Layout.fillWidth: true
//                                 }
//                             }
//                         }
//                     }
//                 }

//                 ColumnLayout {
//                     Layout.fillWidth: true
//                     spacing: 6
//                     SectionHeader{
//                         Layout.fillWidth: true
//                         title: qsTr("Hoster")
//                     }
//                     Rectangle {
//                         Layout.fillWidth: true
//                         implicitHeight: bookingOwner.implicitHeight + 20
//                         color: "#FFFFFF"
//                         radius: 12
//                         border.color: "#E2E8F0"

//                         ColumnLayout {
//                             id: bookingOwner
//                             anchors.fill: parent
//                             anchors.margins: 10
//                             spacing: 2
//                             RowLayout{
//                                 Text{
//                                     text:qsTr("Name:")
//                                     font.pixelSize: 12
//                                     font.bold: false
//                                     color: "#64748B"
//                                 }
//                                 Item{Layout.preferredWidth: 180}
//                                 Text {
//                                     text: root.hostName
//                                     font.pixelSize: 14
//                                     font.bold: false
//                                     color: "#64748B"
//                                     elide: Text.ElideRight
//                                     Layout.fillWidth: true
//                                 }
//                             }
//                         }
//                     }
//                 }

//                 // 4. Description Field
//                 ColumnLayout {
//                     Layout.fillWidth: true
//                     spacing: 6

//                     // Text {
//                     //     text: ""
//                     //     font.pixelSize: 14
//                     //     font.bold: true
//                     //     color: "#475569"
//                     // }

//                     // Rectangle {
//                     //     Layout.fillWidth: true
//                     //     implicitHeight: 120
//                     //     color: "#FFFFFF"
//                     //     radius: 8
//                     //     border.color: descriptionArea.activeFocus ? "#2563EB" : "#CBD5E1"
//                     //     border.width: descriptionArea.activeFocus ? 2 : 1

//                         AppTextInput{
//                             id: descriptionField
//                             label: "Description "
//                             required: true
//                             Layout.fillWidth: true
//                             fieldHeight: 120
//                             placeholder: "Describe your issue in details..."

//                         }
//                         // ScrollView {
//                         //     anchors.fill: parent
//                         //     anchors.margins: 8
//                         //     clip: true

//                         //     TextArea {
//                         //         id: descriptionArea
//                         //         placeholderText: "Describe your issue in detail..."
//                         //         placeholderTextColor: "#94A3B8"
//                         //         font.pixelSize: 14
//                         //         color: "#0F172A"
//                         //         wrapMode: TextEdit.Wrap
//                         //         selectByMouse: true

//                         //         onTextChanged: {
//                         //             if (text.length > 1000) {
//                         //                 text = text.substring(0, 1000)
//                         //             }
//                         //         }
//                         //     }
//                         // }
//                     //}

//                     Text {
//                         Layout.alignment: Qt.AlignRight
//                         text: descriptionArea.text.length + "/1000"
//                         font.pixelSize: 11
//                         color: "#94A3B8"
//                     }
//                 }

//                 Item { Layout.preferredHeight: 8 }

//                 // 5. Submit Button
//                 Button {
//                     id: submitButton
//                     Layout.fillWidth: true
//                     implicitHeight: 48

//                     enabled: issueComboBox.currentIndex > 0 && descriptionArea.text.trim().length > 0

//                     contentItem: Text {
//                         text: "Submit"
//                         font.pixelSize: 15
//                         font.bold: true
//                         color: "#FFFFFF"
//                         horizontalAlignment: Text.AlignHCenter
//                         verticalAlignment: Text.AlignVCenter
//                     }

//                     background: Rectangle {
//                         color: submitButton.enabled
//                                ? (submitButton.pressed ? "#1D4ED8" : "#2563EB")
//                                : "#94A3B8"
//                         radius: 8
//                     }

//                     onClicked: {
//                         root.disputeSubmitted(
//                             root.bookingId,
//                             issueComboBox.currentText,
//                             descriptionArea.text
//                         )

//                         // Transition to step 4 (Dispute Submitted confirmation screen)
//                         if (typeof NavUtils !== "undefined") {
//                             NavUtils.push("qrc:/ui/pages/DisputeSubmittedPage.qml", {
//                                 bookingId: root.bookingId,
//                                 disputeId: "DISP-007"
//                             })
//                         }
//                     }
//                 }

//                 Item { Layout.preferredHeight: 16 }
//             }
//         }
// }
Item{}