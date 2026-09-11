import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import "../components"
import "../delegates"

Page {
    id: root

    property string activeFilter: "Pending"
    // property string title: ""
    // property bool isSearchBar: true
    // property bool showBackButton: true
    background: Rectangle { color: "#F4F6F9" }

    // Header properties driven by active filter

    readonly property string headerTitle: activeFilter + " Bookings"
    readonly property string headerSubtitle: {
        switch (activeFilter) {
            case "Pending":   return "Your booking requests awaiting confirmation"
            case "Confirmed": return "Upcoming stays ready for your trip"
            case "Cancelled": return "Past cancelled booking requests"
            default:          return "Overview of all your booking requests"
        }
    }

    // Dynamic Filter Counts from Dummy Data
    function getCount(statusName) {
        if (statusName === "All") return dummyBookingsModel.count;
        var count = 0;
        for (var i = 0; i < dummyBookingsModel.count; i++) {
            if (dummyBookingsModel.get(i).status === statusName) count++;
        }
        return count;
    }

    // --- TOOLBAR HEADER ---
    // header: Rectangle {
    //     height: 115
    //     color: "#2B62ED"

    //     ColumnLayout {
    //         anchors.fill: parent
    //         anchors.margins: 16
    //         spacing: 2

    //         RowLayout {
    //             Layout.fillWidth: true

    //             ToolButton {
    //                 contentItem: Text { text: "‹"; color: "white"; font.pixelSize: 30 }
    //                 background: Item {}
    //                 onClicked: if (typeof stackView !== "undefined") stackView.pop()
    //             }

    //             Item { Layout.fillWidth: true }

    //             ToolButton {
    //                 contentItem: Text { text: "🔍"; color: "white"; font.pixelSize: 18 }
    //                 background: Item {}
    //             }
    //         }

    //         Text {
    //             text: root.headerTitle
    //             color: "white"
    //             font.pixelSize: 22
    //             font.bold: true
    //         }
    //         Text {
    //             text: root.headerSubtitle
    //             color: "#D0E0FF"
    //             font.pixelSize: 13
    //         }
    //     }
    // }

    // --- MAIN CONTENT ---
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Horizontal Status Filter Chips Bar
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            contentHeight: 60
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Repeater {
                    model: ["All", "Pending", "Confirmed", "Cancelled"]

                    FilterComponent {
                        title: modelData
                        count: root.getCount(modelData)
                        selected: root.activeFilter === modelData
                        onClicked: root.activeFilter = modelData
                    }
                }
            }
        }

        // List View Filtered via DelegateModel
        ListView {
            id: bookingListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 12
            topMargin: 8
            bottomMargin: 16

            model: ListModel { id: filteredBookingsModel }
            delegate: BookingsDelegate {}

            function refreshFilter() {
                filteredBookingsModel.clear();
                for (var i = 0; i < dummyBookingsModel.count; ++i) {
                    var item = dummyBookingsModel.get(i);
                    if (root.activeFilter === "All" || item.status === root.activeFilter) {
                            filteredBookingsModel.append(item);
                    }
                }
            }

            Component.onCompleted: refreshFilter()

            Connections {
                target: root
                function onActiveFilterChanged() { bookingListView.refreshFilter() }
            }

            Text {
                anchors.centerIn: parent
                text: "No " + root.activeFilter.toLowerCase() + " bookings found."
                visible: bookingListView.count === 0
                color: "#8A99AD"
                font.pixelSize: 15
            }
        }
    }

    // --- DUMMY DATA MODEL ---
    ListModel {
        id: dummyBookingsModel

        ListElement {
            propertyName: "NCHA"
            location: "Zomba, Urban"
            bookingDate: "Apr 25, 2025 – Apr 28, 2025"
            guests: "2 Guests"
            status: "Pending"
            statusNote: "Awaiting host confirmation"
            imageUrl: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688"
        }
        ListElement {
            propertyName: "Ungwiro hostel"
            location: "Zomba, Chikanda"
            bookingDate: "May 10, 2025 – May 15, 2025"
            guests: "4 Guests"
            status: "Pending"
            statusNote: "Awaiting host confirmation"
            imageUrl: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750"
        }
        ListElement {
            propertyName: "Highway"
            location: "Blantyre, MUBAS"
            bookingDate: "May 20, 2025 – May 22, 2025"
            guests: "1 Guest"
            status: "Pending"
            statusNote: "Awaiting host confirmation"
            imageUrl: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267"
        }
        ListElement {
            propertyName: "Mwayiwathu"
            location: "Chikanda, Malawi"
            bookingDate: "Jun 01, 2025 – Jun 04, 2025"
            guests: "2 Guests"
            //status: "Confirmed"
            statusNote: "Booking confirmed by host"
            imageUrl: "https://images.unsplash.com/photo-1566073771259-6a8506099945"
        }
        ListElement {
            propertyName: "Nzika"
            location: "Chikwawa, Malawi"
            bookingDate: "Mar 10, 2025 – Mar 12, 2025"
            guests: "3 Guests"
            status: "Cancelled"
            statusNote: "Cancelled by guest"
            imageUrl: "https://images.unsplash.com/photo-1580587771525-78b9dba3b914"
        }
    }
}