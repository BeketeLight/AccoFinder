import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../models"
Rectangle {
    id: delegateRoot
    // --- REQUIRED MODEL PROPERTIES ---
    property string bookingId: model.bookingId ?? ""
    property string houseName: model.houseName ?? "Hostel/Apartment"
    property string landlordName: model.landlordName ?? model.hostName ?? "Landlord / Agent"
    property string ownerFirstName: model.ownerFirstName ?? ""
    property string hostName: model.hostName ?? ""
    property string hostInitials: model.hostInitials ?? ""
    property string  clientInitial: model.clientInitial ?? ""
    property string imageUrl: model.propertyImage ?? model.imageUrl ?? ""
    property string status: model.status ?? "Pending"
    property string clientName: model.clientName ?? "Guest"
    property string clientPhone: model.clientPhone ?? "N/A"
    property string dateRange: model.bookingDate ?? model.dateRange ?? "N/A"
    // Robust numeric check for price
    property real price: Number(model.amount ?? 0) // !== undefined && model.amount !== null ? model.amount.toString() : (model.price ?? "0")
    property real commission: Number(model.commissionAmount ?? 0)
    property string propertyLocation: model.location ?? ""
    property string roomType: model.roomType ?? "Standard Room"
    property string details: model.details ?? model.roomType ?? "Standard Room"
    property string clientEmail: model.clientEmail ?? ""
    // --- ACTIVE FILTER PROP (FOR INLINE LISTVIEW FILTERING) ---
    property string activeFilter: "All"

    // --- INTERACTION SIGNALS ---
    signal approveBooking()
    signal viewDetailsRequested(var data)

    // --- VISIBILITY & LAYOUT BEHAVIOR ---
    visible: activeFilter === "All" || status === activeFilter
    //visible: model.matches ?? true
    width: ListView.view ? ListView.view.width : parent.width
    implicitHeight: visible ? cardContent.implicitHeight + 16 : 0
    color: "#FFFFFF"
    radius: 8
    border.color: "#E2E8F0"
    border.width: 1

    ColumnLayout {
        id: cardContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 10
        // --- 2. LANDLORD / STORE BADGE ---
        RowLayout {
            spacing: 6

            Text {
                text: delegateRoot.houseName
                font.pixelSize: 14
                color: "#2563EB"
            }

            Item { Layout.fillWidth: true }


            Rectangle {
                id: badge
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: statusLabel.implicitWidth + 16
                implicitHeight: 28
                radius: 14
                color: delegateRoot.status === "Confirmed" ? "#DCFCE7"
                     : delegateRoot.status === "Pending" ? "#FEF3C7"
                     : delegateRoot.status === "Cancelled" ? "#FEE2E2"
                     : "#F1F5F9"

                Text {
                    id: statusLabel
                    anchors.centerIn: parent
                    text: delegateRoot.status
                    font.pixelSize: 12
                    font.bold: true
                    color: delegateRoot.status === "Confirmed" ? "#15803D"
                         : delegateRoot.status === "Pending" ? "#B45309"
                         : delegateRoot.status === "Cancelled" ? "#B91C1C"
                         : "#475569"
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
                RowLayout{
                    spacing: 0
                    Text {
                        text: "Client: " + delegateRoot.clientName
                        font.pixelSize: 12
                        color: "#888888"
                   }
                    Item{Layout.fillWidth: true}
                    ToolButton{
                        icon.source: "qrc:/ui/assets/forward-icon.svg"
                        icon.width: 8
                        icon.height: 8
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
                    text:"Room Type: " + delegateRoot.details
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
    }
    MouseArea{
        anchors.fill: delegateRoot
        onClicked: delegateRoot.viewDetailsRequested(data)
    }
}