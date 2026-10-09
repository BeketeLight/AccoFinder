import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../models"
import "../../../utils/Utils.js" as Helper
Rectangle {
    id: delegateRoot

    // --- REQUIRED MODEL PROPERTIES ---
    property string bookingId: model.bookingId ?? ""
    property string houseName: model.houseName ?? "Hostel/Apartment"
    property string landlordName: model.landlordName ?? model.hostName ?? "Landlord / Agent"
    property string ownerFirstName: model.ownerFirstName ?? ""
    property string hostName: model.hostName ?? ""
    property string hostInitials: model.hostInitials ?? ""
    property string imageUrl: model.propertyImage ?? model.imageUrl ?? ""
    property string status: model.status ?? "Pending"
    readonly property string statusKey: String(status).trim().toUpperCase()
    property string clientName: model.clientName ?? "Guest"
    property string clientPhone: model.clientPhone ?? "N/A"
    property string dateRange: model.bookingDate ?? model.dateRange ?? "N/A"
    //Expires at details
    property string holdExpiresAt: model.holdExpiresAt ?? ""
    property bool holdActive: model.holdActive === true || model.holdActive === 1
    property int tick: 0
    // Robust numeric check for price
    property real price: Number(model.amount ?? 0)
    property string propertyLocation: model.location ?? ""
    property string roomType: model.roomType ?? "Standard Room"
    property string details: model.details ?? model.roomType ?? "Standard Room"
    property string clientEmail: model.clientEmail ?? ""

    property double baseAmount: model.amount ?? 0.0
    property double serviceFee: model.commissionAmount ?? 0.0
    property double totalAmount: baseAmount + serviceFee
    //colors
    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color pageColor: "#FFFFFF"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"
    // --- ACTIVE FILTER PROP (FOR INLINE LISTVIEW FILTERING) ---
    //property string activeFilter: "All"

    // --- INTERACTION SIGNALS ---
    signal removeRequested()
    signal viewDetailsRequested(var data)
    signal payNowRequested(string bookingId, real amount, var holdExpiresAt)

    // --- VISIBILITY & LAYOUT BEHAVIOR ---
    // visible: activeFilter === "All" || status === activeFilter
    visible: model.matches ?? true
    width: ListView.view ? ListView.view.width : parent.width
    implicitHeight: visible ? cardContent.implicitHeight + 24 : 0
    color: "#FFFFFF"
    radius: 8
    border.color: "#E2E8F0"
    border.width: 1

    //Countdown for expiration of booking
    // readonly property string holdCountdownText: {
    //     var _ = tick   // re-evaluate every second
    //     if (!holdExpiresAt || holdExpiresAt.length === 0)
    //         return ""
    //     var end = Date.parse(holdExpiresAt)
    //     if (isNaN(end))
    //         return ""
    //     var s = Math.max(0, Math.floor((end - Date.now()) / 1000))
    //     if (s <= 0)
    //         return qsTr("Hold expired")
    //     var h = Math.floor(s / 3600)
    //     var m = Math.floor((s % 3600) / 60)
    //     var sec = s % 60
    //     if (h > 0)
    //         return qsTr("This booking expires in %1h %2m").arg(h).arg(m)
    //     if (m > 0)
    //         return qsTr("This booking expires in %1m %2s").arg(m).arg(sec)
    //     return qsTr("Expires in %1s").arg(sec)
    // }
     Timer {
         interval: 1000
         running: delegateRoot.holdExpiresAt.length > 0
         repeat: true
        onTriggered: delegateRoot.tick++
    }
     readonly property string holdCountdownText: {
         var _ = tick
        // return .holdCountdownText(holdExpiresAt)
         return Helper.holdCountdownText(delegateRoot.status, holdExpiresAt)
     }

     readonly property bool canPay: {
         var _ = tick
         return Helper.canPayBooking(status, holdExpiresAt)
     }

     readonly property bool showHoldActions: {
         var _ = tick
         return Helper.canPayBooking(status, holdExpiresAt)
     }
    // //To make payment when booking is pending need this
    // //Conditions has to be checked first
    // //Countdown must be greater than Zero
    // readonly property bool canPay: {
    //     switch (statusKey) {
    //     case "PENDING PAYMENT":
    //     case "PAYMENT PROCESSING":
    //     case "PAYMENT FAILED":
    //     case "PENDING":
    //         return holdCountdownText.length > 0
    //             && holdCountdownText !== qsTr("Hold expired")
    //     default:
    //         return false
    //     }
    // }
    ColumnLayout {
        id: cardContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 10
        z:1
        // --- 1. HEADER ROW: STATUS ---


        // // --- 2. LANDLORD / STORE BADGE ---
        // RowLayout {
        //     spacing: 6


        // }
         RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Date: " + delegateRoot.dateRange
                font.pixelSize: 12
                color: "#000000"
            }
            Item { Layout.fillWidth: true }

            Rectangle {
                id: badge
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: statusLabel.implicitWidth + 16
                implicitHeight: 20
                radius: 14
                color: {
                    switch(delegateRoot.statusKey){
                    case "CONFIRMED":
                    case "PAID":
                        return "#DCFCE7"

                    case "PENDING PAYMENT":
                    case "PAYMENT PROCESSING":
                    case "PAYMENT FAILED":
                    case "PENDING":
                        return "#FEF3C7"

                    case "CANCELLED":
                    case "EXPIRED":
                        return "#FEE2E2"

                    default:
                        return "#F1F5F9" //Watch
                    }

                }
                Text {
                    id: statusLabel
                    text: delegateRoot.status
                    anchors.centerIn: parent
                    font.pixelSize: 12
                    font.bold: false
                    color: {
                        switch (delegateRoot.statusKey) {
                        case "CONFIRMED":
                        case "PAID":
                            return "#16A34A"
                        case "PENDING PAYMENT":
                        case "PAYMENT PROCESSING":
                        case "PAYMENT FAILED":
                        case "PENDING":
                            return "#D97706"
                        case "CANCELLED":
                        case "EXPIRED":
                        case "REJECTED":
                            return "#DC2626"
                        default:
                            return "#64748B"
                        }
                    }
                }
            }
        }
        // --- 3. MAIN CONTENT: THUMBNAIL & PROPERTY INFO ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                id: imageContainer
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: 8
                color: "#F0F0F0"
                clip: true

                Image {
                    id: propImage
                    anchors.fill: parent
                    source: delegateRoot.imageUrl !== "" ? delegateRoot.imageUrl : "qrc:/assets/placeholder.png"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                }

                MultiEffect {
                    anchors.fill: propImage
                    source: propImage
                    maskEnabled: true
                    maskThresholdMin: 0.5

                    maskSource: ShaderEffectSource {
                        sourceItem: Rectangle {
                            width: imageContainer.width
                            height: imageContainer.height
                            radius: imageContainer.radius
                            color: "black"
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    text: delegateRoot.houseName
                    font.pixelSize: 14
                    color: "#2563EB"
                }
                RowLayout{
                    spacing: 0
                    Text {
                        text: "Room Type: " + delegateRoot.details
                        font.pixelSize: 12
                        color: "#888888"
                    }
                    Item{Layout.fillWidth: true}
                    ToolButton{
                        icon.source: "qrc:/ui/assets/forward-icon.svg"
                        icon.width: 6
                        icon.height: 6
                        icon.color: "#64748B"
                        background: Rectangle{
                            color: "#F1F5F9"
                            implicitHeight: 24
                            implicitWidth: 24
                            radius: 12
                        }
                    }
                }
                Text {
                    text:"Location: " + delegateRoot.propertyLocation
                    font.pixelSize: 12
                    color: "#888888"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: "MWK " + delegateRoot.price
                    font.bold: true
                    font.pixelSize: 14
                    color: "#000000"
                }
            }

        }
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#F1F5F9"; visible:  holdCountdownText.length > 0}
        RowLayout{
            // Text {
            //     visible: holdCountdownText.length > 0
            //     text: holdCountdownText
            //     font.pixelSize: 12
            //     font.bold: true
            //     color: "#D97706"
            // }
            //Item{Layout.fillWidth: true}
            Rectangle {
                id: pay
                visible: holdCountdownText.length > 0
                Layout.fillWidth: true
                implicitHeight: 40
                radius: 24
                color: "#22C55E"
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Pay now")
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    font.bold: true
                }
                z:2
                // MouseArea {
                //     anchors.fill: pay
                //     onClicked: delegateRoot.payNowRequested(
                //         delegateRoot.bookingId,
                //         delegateRoot.price,
                //         delegateRoot.holdExpiresAt
                //     )
                // }
                MouseArea {
                    anchors.fill: pay
                    onClicked: {
                        console.log("Pay now", delegateRoot.bookingId, delegateRoot.price, delegateRoot.holdExpiresAt)
                        delegateRoot.payNowRequested(
                            delegateRoot.bookingId,
                            Number(delegateRoot.price),
                            delegateRoot.holdExpiresAt
                        )
                    }
                }
            }
        }
    }
    MouseArea{
        anchors.fill: cardContent
        onClicked: delegateRoot.viewDetailsRequested(data)
        z: 0
    }
}