import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Rectangle {
    id: root
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
    property real price: Number(model.amount ?? 0) // !== undefined && model.amount !== null ? model.amount.toString() : (model.price ?? "0")
    property real commission: Number(model.commissionAmount ?? 0)
    property string propertyLocation: model.location ?? ""
    property string roomType: model.roomType ?? "Standard Room"
    property string details: model.details ?? model.roomType ?? "Standard Room"
    property string clientEmail: model.clientEmail ?? ""
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
        spacing: 12
        RowLayout{
            Text {
                text: root.bookingId
                font.pixelSize: 13
                font.bold: true
                color: "#0F172A"
            }
            Item{Layout.fillWidth: true}
            Rectangle {
                Layout.alignment: Qt.AlignRight
                implicitWidth: st.implicitWidth + 14
                implicitHeight: 22
                radius: 11
                color: {
                    var s = String(root.status)
                    if (s === "Confirmed" || s === "Approved") return "#DCFCE7"
                    if (s === "Pending") return "#FEF3C7"
                    if (s === "Paid") return "#DBEAFE"
                    if (s === "Cancelled" || s === "Rejected") return "#FEE2E2"
                    return "#F1F5F9"
                }
                Text {
                    id: st
                    anchors.centerIn: parent
                    text: root.status
                    font.pixelSize: 11
                    font.bold: true
                    color: {
                        var s = String(root.status)
                        if (s === "Confirmed" || s === "Approved") return "#15803D"
                        if (s === "Pending") return "#B45309"
                        if (s === "Paid") return "#2563EB"
                        if (s === "Cancelled" || s === "Rejected") return "#B91C1C"
                        return "#475569"
                    }
                }
            }
        }

        RowLayout{
            Layout.fillWidth: true
            spacing: 6
            // Image
            Rectangle {
                Layout.preferredWidth: 72
                Layout.preferredHeight: 72
                radius: 10
                clip: true
                color: "#F1F5F9"
                Image {
                    anchors.fill: parent
                    source: root.imageUrl || "qrc:/assets/placeholder.png"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            //  id, house, location, client, host, room
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Text {
                    text: root.houseName
                    font.pixelSize: 12
                    color: "#334155"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                RowLayout{
                    spacing: 0
                    Text {
                        text: root.propertyLocation
                        font.pixelSize: 11
                        color: "#94A3B8"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Item{Layout.fillWidth: true}
                    ToolButton{
                        icon.source: "qrc:/ui/assets/forward-icon.svg"
                        icon.width: 6
                        icon.height: 6
                        icon.color:"#64748B"
                        background: null
                    }
                }
                Text {
                    text: "Client: " + root.clientName
                    font.pixelSize: 12
                    color: "#94A3B8"
                }

                Text {
                    text: "Agent: " + root.hostName
                    font.pixelSize: 11
                    color: "#94A3B8"
                }
                Text {
                    text: "Room: " + root.roomType
                    font.pixelSize: 11
                    color: "#64748B"
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.viewDetailsRequested()
    }
}