import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule

Page {
    id: root

    // Passed in from the caller
    property string bookingId: ""
    property string paymentId: ""
    property real amount: 0

    // Live status read from PaymentController. When the controller emits
    // paymentLoaded or paymentCreated, we update these.
    property int status: 0
    property string method: ""
    property string transactionRef: ""
    property string statusMessage: ""

    readonly property string statusLabel: {
        switch (root.status) {
        case 0:
            return "Processing";
        case 1:
            return "Pending";
        case 2:
            return "Paid";
        case 3:
            return "Failed";
        case 4:
            return "Refunded";
        default:
            return "Awaiting payment";
        }
    }
    readonly property color statusColor: {
        switch (root.status) {
        case 0:
            return "#2563EB";
        case 1:
            return "#F59E0B";
        case 2:
            return "#22C55E";
        case 3:
            return "#EF4444";
        case 4:
            return "#6B7280";
        default:
            return "#2563EB";
        }
    }

    signal payNowClicked

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
                text: qsTr("Payment status")
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

        ColumnLayout {
            width: root.width
            spacing: 20
            topPadding: 32
            leftPadding: 24
            rightPadding: 24
            bottomPadding: 32

            // ---- Status circle ----
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 96
                Layout.preferredHeight: 96
                radius: 48
                color: Qt.rgba(root.statusColor.r, root.statusColor.g, root.statusColor.b, 0.12)
                border.color: root.statusColor
                border.width: 2

                Label {
                    anchors.centerIn: parent
                    text: {
                        switch (root.status) {
                        case 2:
                            return "✓";
                        case 3:
                            return "✕";
                        case 1:
                            return "…";
                        case 4:
                            return "↺";
                        default:
                            return "MK";
                        }
                    }
                    color: root.statusColor
                    font.pixelSize: 36
                    font.bold: true
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.statusLabel
                color: root.statusColor
                font.pixelSize: 20
                font.bold: true
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                text: root.statusMessage.length > 0 ? root.statusMessage : qsTr("Your payment details are shown below.")
                color: "#6B7280"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            // ---- Details card ----
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: details.implicitHeight + 32
                radius: 16
                color: "#F5F5F5"
                border.color: "#E5E7EB"

                ColumnLayout {
                    id: details
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 10

                        Label {
                            text: qsTr("Amount")
                            color: "#6B7280"
                            font.pixelSize: 12
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignRight
                            text: "MK " + root.amount.toLocaleString(Qt.locale("en_MW"), 'f', 0)
                            color: "#1F2937"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                        }

                        Label {
                            visible: root.method.length > 0
                            text: qsTr("Method")
                            color: "#6B7280"
                            font.pixelSize: 12
                        }
                        Label {
                            visible: root.method.length > 0
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignRight
                            text: root.method
                            color: "#1F2937"
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignRight
                        }

                        Label {
                            visible: root.bookingId.length > 0
                            text: qsTr("Booking")
                            color: "#6B7280"
                            font.pixelSize: 12
                        }
                        Label {
                            visible: root.bookingId.length > 0
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignRight
                            text: root.bookingId
                            color: "#1F2937"
                            font.pixelSize: 12
                            elide: Text.ElideMiddle
                            horizontalAlignment: Text.AlignRight
                        }

                        Label {
                            visible: root.transactionRef.length > 0
                            text: qsTr("Reference")
                            color: "#6B7280"
                            font.pixelSize: 12
                        }
                        Label {
                            visible: root.transactionRef.length > 0
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignRight
                            text: root.transactionRef
                            color: "#1F2937"
                            font.pixelSize: 12
                            elide: Text.ElideMiddle
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            // ---- Pay now button (only when not yet paid) ----
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                visible: root.status !== 2 && root.status !== 3 && root.status !== 4
                text: qsTr("Pay Now")

                contentItem: Label {
                    text: parent.text
                    color: "#FFFFFF"
                    font.pixelSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 14
                    color: parent.down ? "#1D4ED8" : "#2563EB"
                }
                onClicked: root.payNowClicked()
            }
        }
    }
}
