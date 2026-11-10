import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/inputs"

// Horizontal filter chip row. Emits `filtersChanged()` whenever the user
// commits a filter value. Does not own the query state — the screen does.
Item {
    id: root

    property string selectedType: ""
    property string selectedDistrict: ""
    property string selectedVillage: ""
    property var selectedAmenities: []
    property real selectedMinPrice: 0
    property real selectedMaxPrice: 0
    property bool priceEnabled: false

    signal filtersChanged

    implicitHeight: 44

    Flickable {
        anchors.fill: parent
        contentWidth: filterRow.implicitWidth + 24
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        RowLayout {
            id: filterRow
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            SearchFilterChip {
                label: qsTr("Type")
                active: root.selectedType.length > 0
                valueText: {
                    if (root.selectedType === "")
                        return "";
                    if (root.selectedType === "WHOLE")
                        return qsTr("House");
                    if (root.selectedType === "HOSTEL")
                        return qsTr("Hostel");
                    if (root.selectedType === "QUARTER")
                        return qsTr("Quarter");
                    return root.selectedType;
                }
                onClicked: typeDialog.open()
            }

            SearchFilterChip {
                label: qsTr("Location")
                active: root.selectedDistrict.length > 0 || root.selectedVillage.length > 0
                valueText: {
                    let parts = [];
                    if (root.selectedVillage.length > 0)
                        parts.push(root.selectedVillage);
                    if (root.selectedDistrict.length > 0)
                        parts.push(root.selectedDistrict);
                    return parts.join(", ");
                }
                onClicked: locationDialog.open()
            }

            SearchFilterChip {
                label: qsTr("Amenities")
                active: root.selectedAmenities.length > 0
                valueText: root.selectedAmenities.length > 0 ? qsTr("%1 selected").arg(root.selectedAmenities.length) : ""
                onClicked: amenitiesDialog.open()
            }

            SearchFilterChip {
                label: qsTr("Price")
                active: root.selectedMinPrice > 0 || root.selectedMaxPrice > 0
                valueText: {
                    if (root.selectedMinPrice <= 0 && root.selectedMaxPrice <= 0)
                        return "";
                    return (root.selectedMinPrice > 0 ? root.selectedMinPrice.toString() : "0") + "–" + (root.selectedMaxPrice > 0 ? root.selectedMaxPrice.toString() : "∞");
                }
                enabled: root.priceEnabled
                visible: root.priceEnabled
                onClicked: priceDialog.open()
            }
        }
    }

    // ---- dialogs, unchanged from before ----

    Dialog {
        id: typeDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        title: qsTr("Property type")
        modal: true
        standardButtons: Dialog.Cancel
        width: Math.min(parent.width - 48, 320)

        ColumnLayout {
            width: parent.width
            spacing: 4

            Repeater {
                model: [
                    {
                        label: qsTr("Any"),
                        value: ""
                    },
                    {
                        label: qsTr("House"),
                        value: "WHOLE"
                    },
                    {
                        label: qsTr("Hostel"),
                        value: "HOSTEL"
                    },
                    {
                        label: qsTr("Quarter"),
                        value: "QUARTER"
                    }
                ]
                delegate: ItemDelegate {
                    required property var model
                    width: parent.width
                    text: model.label
                    highlighted: root.selectedType === model.value
                    onClicked: {
                        root.selectedType = model.value;
                        typeDialog.close();
                        root.filtersChanged();
                    }
                }
            }
        }
    }

    Dialog {
        id: locationDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        title: qsTr("Location")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: Math.min(parent.width - 48, 320)

        property string pendingDistrict: root.selectedDistrict
        property string pendingVillage: root.selectedVillage

        onOpened: {
            pendingDistrict = root.selectedDistrict;
            pendingVillage = root.selectedVillage;
        }
        onAccepted: {
            root.selectedDistrict = pendingDistrict.trim();
            root.selectedVillage = pendingVillage.trim();
            root.filtersChanged();
        }

        ColumnLayout {
            width: parent.width
            spacing: 8

            AppTextInput {
                Layout.fillWidth: true
                label: qsTr("District")
                placeholder: qsTr("e.g. Blantyre")
                text: locationDialog.pendingDistrict
                onTextEdited: locationDialog.pendingDistrict = text
            }
            AppTextInput {
                Layout.fillWidth: true
                label: qsTr("Village / area")
                placeholder: qsTr("e.g. Chichiri")
                text: locationDialog.pendingVillage
                onTextEdited: locationDialog.pendingVillage = text
            }
        }
    }

    Dialog {
        id: amenitiesDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        title: qsTr("Amenities")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: Math.min(parent.width - 48, 360)

        property var pending: []

        onOpened: pending = root.selectedAmenities.slice(0)
        onAccepted: {
            root.selectedAmenities = pending.slice(0);
            root.filtersChanged();
        }

        contentItem: ScrollView {
            implicitHeight: 320
            clip: true

            ColumnLayout {
                width: amenitiesDialog.width - 32
                spacing: 2

                Repeater {
                    model: [
                        {
                            value: "WIFI",
                            label: qsTr("Wi-Fi")
                        },
                        {
                            value: "PARKING",
                            label: qsTr("Parking")
                        },
                        {
                            value: "SECURITY",
                            label: qsTr("Security")
                        },
                        {
                            value: "WATER",
                            label: qsTr("Water")
                        },
                        {
                            value: "ELECTRICITY",
                            label: qsTr("Electricity")
                        },
                        {
                            value: "FURNISHED",
                            label: qsTr("Furnished")
                        },
                        {
                            value: "AC",
                            label: qsTr("A/C")
                        },
                        {
                            value: "GARDEN",
                            label: qsTr("Garden")
                        },
                        {
                            value: "BALCONY",
                            label: qsTr("Balcony")
                        },
                        {
                            value: "BOREHOLE",
                            label: qsTr("Borehole")
                        },
                        {
                            value: "COOKER",
                            label: qsTr("Cooker")
                        }
                    ]
                    delegate: CheckBox {
                        required property var model
                        text: model.label
                        checked: amenitiesDialog.pending.indexOf(model.value) >= 0
                        onClicked: {
                            const next = amenitiesDialog.pending.slice(0);
                            const idx = next.indexOf(model.value);
                            if (checked && idx < 0)
                                next.push(model.value);
                            if (!checked && idx >= 0)
                                next.splice(idx, 1);
                            amenitiesDialog.pending = next;
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: priceDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        title: qsTr("Price range")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: Math.min(parent.width - 48, 320)

        property string pendingMin: ""
        property string pendingMax: ""

        onOpened: {
            pendingMin = root.selectedMinPrice > 0 ? String(root.selectedMinPrice) : "";
            pendingMax = root.selectedMaxPrice > 0 ? String(root.selectedMaxPrice) : "";
        }
        onAccepted: {
            root.selectedMinPrice = pendingMin.length > 0 ? Number(pendingMin) : 0;
            root.selectedMaxPrice = pendingMax.length > 0 ? Number(pendingMax) : 0;
            root.filtersChanged();
        }

        ColumnLayout {
            width: parent.width
            spacing: 8

            AppTextInput {
                Layout.fillWidth: true
                label: qsTr("Minimum (MK)")
                inputMethodHints: Qt.ImhDigitsOnly
                text: priceDialog.pendingMin
                onTextEdited: priceDialog.pendingMin = text
            }
            AppTextInput {
                Layout.fillWidth: true
                label: qsTr("Maximum (MK)")
                inputMethodHints: Qt.ImhDigitsOnly
                text: priceDialog.pendingMax
                onTextEdited: priceDialog.pendingMax = text
            }
        }
    }
}
