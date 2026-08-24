import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../../../utils" as UtilsModule

Page {
    id: root

    readonly property color pageColor: "#F8FAFC"
    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color secondaryColor: "#22C55E"
    readonly property color successColor: "#16A34A"
    readonly property color warningColor: "#D97706"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softBlueColor: "#EFF6FF"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    property string propertyNameValue: qsTr("Sunset Apartments")
    property string propertyLocationValue: qsTr("Zomba, Chikanda")
    property real monthlyPrice: 85000
    property string verificationStatus: qsTr("Verified")
    property int bedroomsCount: 3
    property int bathroomsCount: 2
    property string descriptionTextValue: qsTr("Modern three-bedroom house with spacious rooms, tiled floors and a perimeter fence. Close to shops and public transport.")
    property string landlordName: qsTr("Bryan Phiri")
    property string landlordPhone: qsTr("+265 999 123 456")

    background: Rectangle { color: root.pageColor }

    header: ToolBar {
        background: Rectangle { color: "#FFFFFF" }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16

            ToolButton {
                id: backButton

                contentItem: Item {
                    implicitWidth: 24
                    implicitHeight: 24

                    Rectangle {
                        width: 12
                        height: 2
                        radius: 1
                        color: root.textColor
                        rotation: 45
                        transformOrigin: Item.Right
                        x: 0
                        y: 4.5
                    }

                    Rectangle {
                        width: 12
                        height: 2
                        radius: 1
                        color: root.textColor
                        rotation: -45
                        transformOrigin: Item.Right
                        x: 0
                        y: 17.5
                    }
                }

                onClicked: UtilsModule.NavigationUtils.pop()
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Property details")
                font.pixelSize: 17
                font.bold: true
                color: root.textColor
            }

            StatusChip {
                textValue: root.verificationStatus
                variant: root.verificationStatus === qsTr("Verified") ? "success"
                       : root.verificationStatus === qsTr("Pending") ? "warning"
                       : "danger"
            }
        }
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: detailsColumn.implicitHeight + 32
        clip: true

        ScrollBar.vertical: ScrollBar { }

        ColumnLayout {
            id: detailsColumn
            x: Math.max(16, (flick.width - 520) / 2)
            y: 20
            width: Math.min(flick.width - 32, 520)
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: heroColumn.implicitHeight + 40
                radius: 16
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root.primaryColor }
                    GradientStop { position: 1.0; color: root.primaryDarkColor }
                }

                ColumnLayout {
                    id: heroColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 8

                    Label {
                        Layout.fillWidth: true
                        text: root.propertyNameValue
                        color: "#FFFFFF"
                        font.pixelSize: 21
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 5
                            Layout.preferredHeight: 5
                            radius: 2.5
                            color: Qt.rgba(1, 1, 1, 0.85)
                        }

                        Label {
                            text: root.propertyLocationValue
                            color: Qt.rgba(1, 1, 1, 0.85)
                            font.pixelSize: 13
                        }

                        Item { Layout.fillWidth: true }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        implicitHeight: priceRow.implicitHeight
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.12)

                        RowLayout {
                            id: priceRow
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            Label {
                                text: "MK " + Number(root.monthlyPrice).toLocaleString()
                                color: "#FFFFFF"
                                font.pixelSize: 22
                                font.bold: true
                            }

                            Label {
                                text: qsTr("/ month")
                                color: Qt.rgba(1, 1, 1, 0.75)
                                font.pixelSize: 13
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: qsTr("Rent per room")
                                color: Qt.rgba(1, 1, 1, 0.75)
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Photos")
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 150
                radius: 14
                color: root.softBlueColor
                border.color: "#BFDBFE"
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 34

                        Rectangle {
                            anchors.fill: parent
                            radius: 9
                            color: "transparent"
                            border.color: root.primaryColor
                            border.width: 2.2
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: -5
                            width: 16
                            height: 9
                            radius: 3
                            color: root.softBlueColor
                            border.color: root.primaryColor
                            border.width: 2.2
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 15
                            height: 15
                            radius: 7.5
                            color: "transparent"
                            border.color: root.primaryColor
                            border.width: 2.2
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 6
                            height: 6
                            radius: 3
                            color: root.primaryColor
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("No photos uploaded yet")
                        color: root.primaryDarkColor
                        font.pixelSize: 12
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("About this property")
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: aboutLabel.implicitHeight + 28
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Label {
                    id: aboutLabel
                    anchors.fill: parent
                    anchors.margins: 14
                    text: root.descriptionTextValue
                    color: root.textColor
                    font.pixelSize: 13
                    lineHeight: 1.25
                    wrapMode: Text.WordWrap
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Bedrooms")
                    valueText: String(root.bedroomsCount)
                    accentColor: root.primaryColor
                }

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Bathrooms")
                    valueText: String(root.bathroomsCount)
                    accentColor: root.secondaryColor
                }

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Monthly rent")
                    valueText: "MK " + Number(root.monthlyPrice).toLocaleString()
                    accentColor: root.successColor
                }

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Verification")
                    valueText: root.verificationStatus
                    accentColor: root.warningColor
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Listed by")
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: ownerRow.implicitHeight + 26
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                RowLayout {
                    id: ownerRow
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: root.softBlueColor

                        Label {
                            anchors.centerIn: parent
                            text: root.landlordName.charAt(0)
                            color: root.primaryColor
                            font.pixelSize: 18
                            font.bold: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            Layout.fillWidth: true
                            text: root.landlordName
                            color: root.textColor
                            font.pixelSize: 14
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.landlordPhone
                            color: root.mutedColor
                            font.pixelSize: 12
                        }
                    }

                    Button {
                        id: callButton
                        Layout.preferredHeight: 36
                        Layout.preferredWidth: 78
                        text: qsTr("Call")

                        contentItem: Label {
                            text: callButton.text
                            color: root.primaryColor
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 18
                            color: callButton.down ? root.softBlueColor : "transparent"
                            border.color: root.primaryColor
                            border.width: 1
                        }

                        onClicked: console.log("Call landlord:", root.landlordPhone)
                    }
                }
            }

            Item { Layout.preferredHeight: 8; Layout.fillWidth: true }
        }
    }

    footer: Rectangle {
        implicitHeight: bookingBarRow.implicitHeight + 24
        color: root.surfaceColor

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: root.borderColor
        }

        RowLayout {
            id: bookingBarRow
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Label {
                    text: "MK " + Number(root.monthlyPrice).toLocaleString()
                    color: root.textColor
                    font.pixelSize: 17
                    font.bold: true
                }

                Label {
                    text: qsTr("per month")
                    color: root.mutedColor
                    font.pixelSize: 11
                }
            }

            Button {
                id: bookNowButton
                Layout.preferredWidth: 160
                Layout.preferredHeight: 48
                text: qsTr("Book now")

                contentItem: Label {
                    text: bookNowButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 24
                    color: bookNowButton.down ? root.primaryDarkColor : root.primaryColor
                }

                onClicked: UtilsModule.NavigationUtils.navigateToPayments()
            }
        }
    }
}
