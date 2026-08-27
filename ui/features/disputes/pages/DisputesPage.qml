import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../properties/components"

Item {
    id: root

    readonly property color primaryColor: "#2563EB"
    readonly property color dangerColor: "#DC2626"
    readonly property color warningColor: "#D97706"
    readonly property color successColor: "#16A34A"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softRedColor: "#FEF2F2"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    property var disputesModel: DisputesListViewModel.disputesListModel

    function tintBg(status) {
        if (String(status).toLowerCase() === "resolved") return "#ECFDF5"
        if (String(status).toLowerCase() === "in review") return "#FFFBEB"
        return "#FEF2F2"
    }

    function tintFg(status) {
        if (String(status).toLowerCase() === "resolved") return "#166534"
        if (String(status).toLowerCase() === "in review") return "#92400E"
        return "#B91C1C"
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 14

        Label {
            Layout.fillWidth: true
            text: qsTr("Disputes raised on your listings")
            color: root.mutedColor
            font.pixelSize: 12
            wrapMode: Text.WordWrap
        }

        Rectangle {
            visible: root.disputesModel.count > 0
            Layout.fillWidth: true
            implicitHeight: disputeListCol.implicitHeight
            radius: 12
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: disputeListCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 0

                Repeater {
                    model: root.disputesModel

                    delegate: ColumnLayout {
                        required property var model
                        required property int index
                        Layout.fillWidth: true
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: disputeRow.implicitHeight + 20
                            color: "transparent"

                            RowLayout {
                                id: disputeRow
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    radius: 17
                                    color: root.tintBg(model.status)

                                    Label {
                                        anchors.centerIn: parent
                                        text: "?"
                                        color: root.tintFg(model.status)
                                        font.pixelSize: 15
                                        font.bold: true
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.issue || qsTr("Dispute")
                                        color: root.textColor
                                        font.pixelSize: 13
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: qsTr("Booking %1").arg(model.bookingId || "—")
                                        color: root.mutedColor
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }

                                StatusChip {
                                    textValue: String(model.status).length > 0 ? model.status : qsTr("Open")
                                    variant: String(model.status).toLowerCase() === "resolved" ? "warning" : "danger"
                                }
                            }
                        }

                        Rectangle {
                            visible: index < root.disputesModel.count - 1
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.borderColor
                        }
                    }
                }
            }
        }

        ColumnLayout {
            visible: root.disputesModel.count === 0
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2
            spacing: 6

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 20
                color: "#FEF2F2"
                border.color: "#FECACA"
                border.width: 1

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/ui/assets/disputes-icon.svg"
                    sourceSize.width: 20
                    sourceSize.height: 20
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("No open disputes")
                color: root.textColor
                font.pixelSize: 13
                font.bold: true
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("All clear — no disputes on your listings.")
                color: root.mutedColor
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
    }
}
