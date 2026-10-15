import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/pages"
import "../components"
import "../delegates"
import "../models"

Item {
    id: root

    property int currentTab: 0
    property var propertiesModelRef: null   // shared home PropertiesModel
    property var roomLookupFn: null         // fn(roomId) → row, provided by SavesScreen

    signal removeProperty(string propertyId)
    signal removeRoom(string roomId)

    SavedPropertiesModel {
        id: savedProps
        sourceModel: root.propertiesModelRef
    }

    SavedRoomsModel {
        id: savedRooms
        lookupRoom: root.roomLookupFn
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: root.currentTab

        // ================= TAB 0 — PROPERTIES =================
        AppScrollablePage {
            contentTopMargin: 12

            SavesEmptyState {
                kind: "property"
                visible: savedProps.count === 0
            }

            Repeater {
                model: savedProps.model

                delegate: SavedPropertyDelegate {
                    required property var model
                    Layout.fillWidth: true
                    propertyId: model.propertyId
                    title: model.title
                    location: model.location
                    price: model.price
                    imageUrl: model.imageUrl
                    imageUrls: model.imageUrls
                    amenities: model.amenities
                    status: model.status
                    isVerified: model.isVerified
                    onRemoveRequested: function (pid) {
                        root.removeProperty(pid);
                    }
                }
            }
        }

        // ================= TAB 1 — ROOMS =================
        AppScrollablePage {
            contentTopMargin: 12

            SavesEmptyState {
                kind: "room"
                visible: savedRooms.count === 0
            }

            Repeater {
                model: savedRooms.model

                delegate: SavedRoomDelegate {
                    required property var model
                    Layout.fillWidth: true
                    roomId: model.roomId
                    propertyId: model.propertyId
                    quarterType: model.quarterType
                    quarterTitle: model.quarterTitle
                    quarterPrice: model.quarterPrice
                    location: model.location
                    imageUrl: model.imageUrl
                    available: model.available
                    holdActive: model.holdActive
                    holdExpiresAt: model.holdExpiresAt
                    onRemoveRequested: function (rid) {
                        root.removeRoom(rid);
                    }
                }
            }
        }
    }
}
