import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/inputs"
import "../../../components/buttons"
import "../../../utils" as UtilsModule

Page {
    id: root

    // Passed in from the booking flow
    property string bookingId: ""
    property real amount: 0

    // Selected method. Empty means nothing chosen yet.
    property string selectedMethod: ""

    signal paymentSubmitted(string bookingId, real amount, string method)

    header: ToolBar {
        background: Rectangle {
            color: "#FFFFFF"
        }
        contentHeight: 56
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16
            ToolButton {
                implicitWidth: 40
                implicitHeight: 40
                Image {
                    width: 24
                    height: 24
                    source: "qrc:/ui/assets/back.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                }
                onClicked: UtilsModule.NavigationUtils.pop()
            }
            Label {
                Layout.fillWidth: true
                text: qsTr("Make a payment")
                font.pixelSize: 16
                font.bold: true
                color: "#1F2937"
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    background: Rectangle {
        color: "#FFFFFF"
    }

    ScrollView {
        anchors.fill: parent
        clip: true

        // Wrapper item gives the ColumnLayout padding (24 sides, 24 top,
        // 32 bottom) because ColumnLayout itself has no padding properties.
        Item {
            width: root.width
            implicitHeight: contentColumn.implicitHeight + 24 + 32

            ColumnLayout {
                id: contentColumn
                x: 24
                y: 24
                width: parent.width - 48
                spacing: 20

                // ---- Amount summary card ----
                AppTextInput {
                    id: summary
                    placeholder: "Amount due"
                    label: "Amount"
                    fieldHeight: 65
                    fieldWidth: contentColumn.width
                }

                // ---- Method picker ----
                Label {
                    text: qsTr("Choose payment method")
                    color: "#1F2937"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.topMargin: 4
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 10
                    rowSpacing: 10

                    Repeater {
                        model: [
                            {
                                key: "airtel",
                                label: qsTr("Airtel Money"),
                                icon: "qrc:/ui/assets/payment/airtel.png"
                            },
                            {
                                key: "tnm",
                                label: qsTr("TNM Mpamba"),
                                icon: "qrc:/ui/assets/payment/tnm.svg"
                            },
                            {
                                key: "card",
                                label: qsTr("Card / Bank"),
                                icon: "qrc:/ui/assets/payment/PayChangu.png"
                            }
                        ]

                        delegate: Rectangle {
                            required property var model
                            Layout.fillWidth: true
                            implicitHeight: 96
                            radius: 14
                            color: root.selectedMethod === model.key ? Qt.rgba(0.14, 0.39, 0.92, 0.10) : "#F5F5F5"
                            border.width: root.selectedMethod === model.key ? 2 : 1
                            border.color: root.selectedMethod === model.key ? "#2563EB" : "#E5E7EB"

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Image {
                                    Layout.alignment: Qt.AlignHCenter
                                    source: model.icon
                                    sourceSize.width: 36
                                    sourceSize.height: 36
                                    fillMode: Image.PreserveAspectFit
                                }
                                Label {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: model.label
                                    color: "#1F2937"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedMethod = model.key
                            }
                        }
                    }
                }

                // ---- Pay button ----
                AppPrimaryButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    customText: qsTr("Pay MK %1").arg(root.amount.toLocaleString(Qt.locale("en_MW"), 'f', 0))
                    customBackgroundColor: "#2563EB"
                    customRadius: 14
                    customTextColor: "#FFFFFF"
                    enabled: root.selectedMethod.length > 0 && root.amount > 0 && !PaymentController.isLoading

                    onClicked: root.paymentSubmitted(root.bookingId, root.amount, root.selectedMethod)
                }

                // ---- Hint ----
                Label {
                    Layout.fillWidth: true
                    text: qsTr("You will receive a prompt on your phone to authorize the payment.")
                    color: "#6B7280"
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                // Bottom spacer so the last child does not butt against the
                // scroll edge when the content is shorter than the viewport.
                Item {
                    Layout.preferredHeight: 8
                }
            }
        }
    }

    // Blocking spinner while the backend processes
    Rectangle {
        anchors.fill: parent
        visible: PaymentController.isLoading
        color: Qt.rgba(1, 1, 1, 0.6)
        z: 100

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 12

            BusyIndicator {
                running: true
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: qsTr("Processing payment…")
                color: "#1F2937"
                font.pixelSize: 14
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
