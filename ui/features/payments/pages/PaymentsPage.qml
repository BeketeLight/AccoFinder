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
    property var operators: []            // filled from PaymentController.operatorsLoaded
    property var bookingDetails: null
    property string phase: "form"
    signal paymentSubmitted(string bookingId, real amount, string method, string operatorRefId, string phoneNumber)

    // Provisional hold deadline (ISO string from POST /bookings). Invalid or
    // null when the booking is not on a hold, in which case no countdown is
    // shown and payment stays enabled.
    property var holdExpiresAt: null

    // These are plain writable properties driven by recomputeHoldCountdown()
    // rather than bindings over Date.now() or over holdExpiresAt.
    //
    // Two reasons, both learned the hard way:
    //  - QML cannot observe the clock, so a binding over Date.now() would never
    //    re-evaluate on its own.
    //  - Inside an onHoldExpiresAtChanged handler a binding that depends on
    //    holdExpiresAt has not been re-evaluated yet, so reading it there
    //    returns the PREVIOUS value. Deriving everything imperatively from the
    //    raw holdExpiresAt avoids depending on binding freshness at all.
    property bool hasHold: false
    property int holdSecondsRemaining: 0

    readonly property bool holdExpired: hasHold && holdSecondsRemaining <= 0

    // True only when the text in the amount field parses to exactly root.amount.
    // Handles formatted inputs like "55,000", "MK 55000", and "55000.00".
    readonly property bool amountMatches: {
        if (root.amount <= 0)
            return false;
        if (!summary || !summary.text)
            return false;

        var cleaned = String(summary.text).replace(/[^0-9.]/g, "");
        if (cleaned.length === 0)
            return false;

        var typed = Number(cleaned);
        if (isNaN(typed))
            return false;

        return Math.round(typed * 100) === Math.round(root.amount * 100);
    }

    readonly property string holdCountdownText: {
        var total = Math.max(0, root.holdSecondsRemaining);
        var mins = Math.floor(total / 60);
        var secs = total % 60;
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    // Maps an operator to a local icon. The backend's PayChangu response has
    // `logo: null` for all operators, so we fall back on a per-operator asset.
    function operatorIcon(op) {
        if (!op)
            return "";

        // Prefer whatever the backend gives us.
        if (op.icon && op.icon.length > 0)
            return op.icon;
        if (op.logo && op.logo.length > 0)
            return op.logo;

        // Fall back on short_code first (stable), then name (fragile but useful).
        var key = (op.short_code || op.name || "").toLowerCase();

        if (key.indexOf("airtel") !== -1)
            return "qrc:/ui/assets/payment/airtel.svg";
        if (key.indexOf("tnm") !== -1 || key.indexOf("mpamba") !== -1)
            return "qrc:/ui/assets/payment/tnm-logo.svg";
        if (key.indexOf("changu_wallet") !== -1 || key.indexOf("card") !== -1)
            return "qrc:/ui/assets/payment/PayChangu.svg";

        // Last resort: a generic fallback.
        return "qrc:/ui/assets/payment/PayChangu.svg";
    }

    // Recomputes remaining time and keeps the timer in step. Safe to call from
    // anywhere; idempotent.
    function recomputeHoldCountdown() {
        var deadline = 0;

        // Parse the raw value rather than a derived property - see the note on
        // the declarations above. NaN (absent or malformed input) becomes 0,
        // which means "no countdown" rather than "permanently expired".
        if (root.holdExpiresAt) {
            var parsed = Date.parse(String(root.holdExpiresAt));
            if (!isNaN(parsed) && parsed > 0)
                deadline = parsed;
        }

        var remaining = deadline > 0 ? Math.max(0, Math.floor((deadline - Date.now()) / 1000)) : 0;

        root.holdSecondsRemaining = remaining;
        root.hasHold = deadline > 0;

        if (root.hasHold)
            holdCountdownTimer.restart();
        else
            holdCountdownTimer.stop();
    }

    // Selected method. Empty means nothing chosen yet.
    property string selectedMethod: ""        // "mobile_money" | "card"
    property string selectedOperatorRefId: ""
    property string selectedOperatorName: ""

    // Only ticks while a hold is actually running, so an ordinary payment
    // screen costs nothing. Started/stopped by recomputeHoldCountdown().
    Timer {
        id: holdCountdownTimer
        interval: 1000
        repeat: true
        onTriggered: root.recomputeHoldCountdown()
    }

    onHoldExpiresAtChanged: recomputeHoldCountdown()

    Component.onCompleted: recomputeHoldCountdown()

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
                onClicked: UtilsModule.NavigationUtils.pop({
                    bookingId: root.bookingId,
                    returnToBooking: true
                })
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
        visible: root.phase === "form"

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

                // ---- Provisional hold countdown ----
                //
                // Tells the user how long the room is theirs for, and is the
                // only thing standing between an abandoned checkout and a
                // silently wasted room. Hidden entirely when there is no hold.
                Rectangle {
                    id: holdBanner
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? bannerColumn.implicitHeight + 24 : 0
                    visible: root.hasHold
                    radius: 12
                    color: root.holdExpired ? "#FEE2E2" : "#FEF3C7"

                    ColumnLayout {
                        id: bannerColumn
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                text: root.holdExpired ? "\u26A0" : "\u23F3"
                                font.pixelSize: 18
                            }

                            Label {
                                Layout.fillWidth: true
                                text: root.holdExpired ? qsTr("Your hold has expired") : qsTr("Room held for you")
                                color: root.holdExpired ? "#991B1B" : "#92400E"
                                font.pixelSize: 15
                                font.bold: true
                                wrapMode: Text.WordWrap
                            }

                            Label {
                                visible: !root.holdExpired
                                text: root.holdCountdownText
                                color: "#92400E"
                                font.pixelSize: 18
                                font.bold: true
                                font.family: "monospace"
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            visible: !root.holdExpired
                            text: qsTr("Complete payment before the timer runs out, otherwise this room becomes available to other users.")
                            color: "#92400E"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        Label {
                            Layout.fillWidth: true
                            visible: root.holdExpired
                            text: qsTr("This room has been released. Start a new booking if it is still available.")
                            color: "#991B1B"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    visible: root.bookingDetails !== null
                    implicitHeight: bookingSummary.implicitHeight + 24
                    radius: 14
                    color: "#F9FAFB"
                    border.color: "#E5E7EB"

                    ColumnLayout {
                        id: bookingSummary
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        Label {
                            text: qsTr("Booking summary")
                            font.bold: true
                            font.pixelSize: 13
                            color: "#1F2937"
                        }
                        Label {
                            Layout.fillWidth: true
                            text: root.bookingDetails ? ((root.bookingDetails.propertyName || "") + " — " + (root.bookingDetails.roomName || "")) : ""
                            color: "#374151"
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Label {
                                text: qsTr("%1 nights").arg(root.bookingDetails ? (root.bookingDetails.nights || 0) : 0)
                                color: "#6B7280"
                                font.pixelSize: 12
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            Label {
                                text: "MK " + (root.bookingDetails ? Number(root.bookingDetails.total).toLocaleString(Qt.locale("en_MW"), 'f', 0) : "0")
                                font.bold: true
                                color: "#1F2937"
                                font.pixelSize: 14
                            }
                        }
                    }
                }

                // ---- Amount summary card ----
                AppTextInput {
                    id: summary
                    Layout.fillWidth: true
                    label: qsTr("Amount due")
                    placeholder: qsTr("Enter the amount shown on the button")
                    fieldHeight: 65
                    fieldWidth: contentColumn.width
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    // Prefill so the amount starts correct. Delete this `text:` line if you
                    // want the user to *type* the amount as a confirmation step.
                    text: root.amount > 0 ? root.amount.toLocaleString(Qt.locale("en_MW"), 'f', 0) : ""
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
                        model: root.operators.length > 0 ? root.operators : [
                            {
                                ref_id: "20be6c20-adeb-4b5b-a7ba-0769820df4fb",
                                name: qsTr("Airtel Money"),
                                icon: "qrc:/ui/assets/payment/airtel.svg"
                            },
                            {
                                ref_id: "27494cb5-ba9e-437f-a114-4e7a7686bcca",
                                name: qsTr("TNM Mpamba"),
                                icon: "qrc:/ui/assets/payment/tnm-logo.svg"
                            },
                            {
                                ref_id: "550c35a2-86aa-4590-9931-8f23e664cee9",
                                name: "Card",
                                icon: "qrc:/ui/assets/payment/PayChangu.svg"
                            },
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 96
                            radius: 14
                            readonly property bool isSelected: root.selectedOperatorRefId === modelData.ref_id
                            color: isSelected ? Qt.rgba(0.14, 0.39, 0.92, 0.10) : "#F5F5F5"
                            border.width: isSelected ? 2 : 1
                            border.color: isSelected ? "#2563EB" : "#E5E7EB"

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Image {
                                    Layout.alignment: Qt.AlignHCenter
                                    source: root.operatorIcon(modelData)
                                    sourceSize.width: 36
                                    sourceSize.height: 36
                                    fillMode: Image.PreserveAspectFit
                                }
                                Label {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.name || ""
                                    color: "#1F2937"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedOperatorRefId = modelData.ref_id || "";
                                    root.selectedOperatorName = modelData.name || "";
                                    root.selectedMethod = (modelData.ref_id || "").length > 0 ? "mobile_money" : "card";
                                }
                            }
                        }
                    }
                }

                AppTextInput {
                    id: phoneField
                    visible: root.selectedMethod === "mobile_money"
                    Layout.fillWidth: true
                    label: qsTr("Mobile money number")
                    placeholder: qsTr("e.g. 0991234567")
                    fieldHeight: 52
                    fieldWidth: contentColumn.width
                    text: (typeof AppSettings !== "undefined" && AppSettings.phone) ? AppSettings.phone : ""
                    inputMethodHints: Qt.ImhDialableCharactersOnly
                }

                // ---- Pay button ----
                AppPrimaryButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    customText: qsTr("Pay MK %1").arg(root.amount.toLocaleString(Qt.locale("en_MW"), 'f', 0))
                    customRadius: 14
                    customTextColor: "#FFFFFF"
                    customBackgroundColor: root.holdExpired ? "#9CA3AF" : "#2563EB"

                    // Never submit against an expired hold: the backend would
                    // reject the booking anyway, and charging someone for a
                    // room that has already gone to another user is the worst
                    // possible outcome.
                    enabled: !root.holdExpired && root.amountMatches && root.selectedMethod.length > 0 && root.amount > 0 && !PaymentController.isLoading && (root.selectedMethod !== "mobile_money" || (root.selectedOperatorRefId.length > 0 && phoneField.text.replace(/\s/g, "").length >= 9))

                    onClicked: {
                        console.log("pay now button clicked");
                        if (root.holdExpired) {
                            console.warn("[Payment] hold expired");
                            return;
                        }
                        console.log(root.bookingId, root.amount, root.selectedMethod, root.selectedOperatorRefId, phoneField.text.replace(/\s/g, ""));
                        root.paymentSubmitted(root.bookingId, root.amount, root.selectedMethod, root.selectedOperatorRefId, phoneField.text.replace(/\s/g, ""));
                    }
                }

                // ---- Hint ----
                Label {
                    Layout.fillWidth: true
                    text: root.holdExpired ? qsTr("This hold has expired, so payment is no longer available.") : qsTr("You will receive a prompt on your phone to authorize the payment.")
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

    Rectangle {
        anchors.fill: parent
        visible: root.phase === "awaitingPin"
        color: "#FFFFFF"
        z: 90

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 64
            spacing: 20

            BusyIndicator {
                running: true
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("A payment request was sent to your phone.\n\n" + "Open the prompt and enter your Mobile Money PIN to " + "complete the payment. Do not close this screen.")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: "#1F2937"
                font.pixelSize: 14
            }

            Label {
                visible: root.hasHold
                Layout.fillWidth: true
                text: qsTr("Time remaining: ") + root.holdCountdownText
                horizontalAlignment: Text.AlignHCenter
                color: "#92400E"
                font.pixelSize: 16
                font.bold: true
                font.family: "monospace"
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
