import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import "../../../components/navigations"
import "../../../utils" as UtilsModule
Page{
   id: footerPageId
   property int currentIndex : 0
   // Refreshed explicitly via AppSettings.userSessionChanged — Q_INVOKABLE
   // calls alone are not reactive.
   property string userRole: ""
   property bool isAdminUser: false
   property bool showPropertiesTab: false
   property bool showSavedTab: true
   // Single knob for every tab label's font size — tweak this to experiment.
   property int tabFontSize: 12

   function refreshSessionState() {
      userRole = AppSettings.userType()
      isAdminUser = userRole === "ADMIN" || userRole === "SUPER_ADMIN"
      showPropertiesTab = userRole === "AGENT" || isAdminUser
      showSavedTab = userRole === "CLIENT" || userRole === ""
      if (currentIndex === 2 && !showSavedTab)
         currentIndex = 0
   }

   Component.onCompleted: {
      refreshSessionState()
      console.log("FooterComponent loaded, currentIndex property exists")
   }

   Connections {
      target: AppSettings
      function onUserSessionChanged() { footerPageId.refreshSessionState() }
   }

   // At the top of FooterComponent.qml
   signal tabSelected(int index)
   signal homeTapped()
   signal propertiesTapped()
   signal bookingsTapped()
   signal accountTapped()
   signal saveTapped()
   signal dashboardTapped()

   background: Rectangle {
      color: "#F8F9FA"
   }
   Item {
      anchors.fill: parent
      anchors.leftMargin: 10
      anchors.rightMargin: 10

      RowLayout {
         anchors.horizontalCenter: parent.horizontalCenter
         anchors.top: parent.top
         anchors.bottom: parent.bottom
         spacing: 32

         ColumnLayout{
            Layout.preferredHeight: 0
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            spacing: 0
            ToolButton{
               icon.name: footerPageId.isAdminUser ? "dashboard-icon" : "Home-icon"
               icon.source: footerPageId.isAdminUser ? "qrc:/ui/assets/dashboard-icon.svg" : "qrc:/ui/assets/home-icon.svg"
               icon.height: 24
               icon.width: 24
               background: null
               icon.color: currentIndex === 0 ? "#2563EB" : "gray"
               Layout.alignment: Qt.AlignHCenter
               onClicked: {
                  if(currentIndex === 0) return
                  currentIndex = 0
                  if (footerPageId.isAdminUser)
                     footerPageId.dashboardTapped()
                  else
                     footerPageId.homeTapped()
                  tabSelected(0)
               }
            }
            Text{
               text: footerPageId.isAdminUser ? qsTr("Dashboard") : qsTr("Home")
               Layout.alignment: Qt.AlignHCenter
               font.pixelSize: footerPageId.tabFontSize
               //font.bold: currentIndex === 0
            }
         }
         ColumnLayout{
            Layout.preferredHeight: 0
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            Layout.preferredWidth: footerPageId.showPropertiesTab ? -1 : 0
            Layout.maximumWidth: footerPageId.showPropertiesTab ? Number.POSITIVE_INFINITY : 0
            spacing: 0
            visible: footerPageId.showPropertiesTab
            ToolButton{
               icon.name: "Properties-icon"
               icon.source:"qrc:/ui/assets/properties-icon.svg"
               icon.height: 24
               icon.width: 24
               icon.color: currentIndex === 1 ? "#2563EB" : "gray"
               Layout.alignment: Qt.AlignHCenter
               background: null
               onClicked: {
                  if(currentIndex === 1) return
                  footerPageId.propertiesTapped()
                  currentIndex = 1
                  tabSelected(1)
               }
            }
            Text{
               text: qsTr("Properties")
               Layout.alignment: Qt.AlignHCenter
               font.pixelSize: footerPageId.tabFontSize
               //font.bold: currentIndex === 1
            }
         }
         ColumnLayout{
            Layout.preferredHeight: 0
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            Layout.preferredWidth: footerPageId.showSavedTab ? -1 : 0
            Layout.maximumWidth: footerPageId.showSavedTab ? Number.POSITIVE_INFINITY : 0
            spacing: 0
            visible: footerPageId.showSavedTab
            ToolButton{
               icon.name: "Save-icon"
               icon.source:"qrc:/ui/assets/save-icon.svg"
               icon.height: 24
               icon.width: 24
               background: null
               icon.color: currentIndex === 2 ? "#2563EB" : "gray"
               Layout.alignment: Qt.AlignHCenter
               onClicked: {
                  if(currentIndex === 2) return
                  currentIndex = 2
                  footerPageId.saveTapped()
                  tabSelected(2)
               }
            }
            Text{
               text: qsTr("Saved")
               Layout.alignment: Qt.AlignHCenter
               font.pixelSize: footerPageId.tabFontSize
               //font.bold: currentIndex === 2
            }
         }

         // Compact accommodation-safety badge for non-admin footers: a primary-blue
         // rounded shield whose "resize" (breathing) animation keeps the
         // footer narrow, so the tabs stay within the left/right margins.
         Rectangle {
            id: safetyBadge
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            Layout.alignment: Qt.AlignVCenter
            visible: !footerPageId.isAdminUser
            radius: 7
            color: "#2563EB"
            antialiasing: true

            Rectangle {
               id: safetyRing
               anchors.fill: parent
               radius: 7
               color: "transparent"
               border.color: "#BFDBFE"
               border.width: 1.5
               opacity: 0.6

               SequentialAnimation {
                  running: parent.parent.visible
                  loops: Animation.Infinite
                  ParallelAnimation {
                     NumberAnimation { target: safetyRing; property: "scale"; from: 1.0; to: 1.45; duration: 1000 }
                     NumberAnimation { target: safetyRing; property: "opacity"; from: 0.6; to: 0.0; duration: 1000 }
                  }
                  PauseAnimation { duration: 300 }
               }
            }

            Shape {
               anchors.centerIn: parent
               width: 12
               height: 14
               antialiasing: true
               ShapePath {
                  fillColor: "#FFFFFF"
                  strokeColor: "transparent"
                  startX: 6
                  startY: 1
                  PathLine { x: 11; y: 2 }
                  PathLine { x: 11; y: 6 }
                  PathLine { x: 6; y: 13 }
                  PathLine { x: 1; y: 6 }
                  PathLine { x: 1; y: 2 }
                  PathLine { x: 6; y: 1 }
               }
            }

            // Scales in place around its center — a pure "resize" animation,
            // so the layout footprint (and hence the margins) never change.
            SequentialAnimation {
               running: parent.visible
               loops: Animation.Infinite
               NumberAnimation { target: safetyBadge; property: "scale"; from: 1.0; to: 0.87; duration: 900; easing.type: Easing.InOutSine }
               NumberAnimation { target: safetyBadge; property: "scale"; from: 0.87; to: 1.0; duration: 900; easing.type: Easing.InOutSine }
               PauseAnimation { duration: 300 }
            }
         }
         //a speacner for admin
         Item {
            id: spencer
            Layout.minimumWidth: 0
            visible: footerPageId.isAdminUser
         }

         ColumnLayout{
            Layout.preferredHeight: 0
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            spacing: 0
            ToolButton{
               icon.name: "Bookings-icon"
               icon.source:"qrc:/ui/assets/bookings-icon.svg"
               icon.height: 24
               icon.width: 24
               icon.color: currentIndex === 3 ? "#2563EB" : "gray"
               Layout.alignment: Qt.AlignHCenter
               background: null
               onClicked: {
                  if(currentIndex === 3) return
                  footerPageId.bookingsTapped()
                  currentIndex = 3
                  tabSelected(3)
               }
            }
            Text{
               text: qsTr("Bookings")
               Layout.alignment: Qt.AlignHCenter
               font.pixelSize: footerPageId.tabFontSize
               //font.bold: currentIndex === 2
            }
         }
         ColumnLayout{
            Layout.preferredHeight: 0
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            spacing: 0
            ToolButton{
               icon.name: "Account-icon"
               icon.source:"qrc:/ui/assets/account-icon.svg"
               icon.height: 24
               icon.width: 24
               icon.color: currentIndex === 4 ? "#2563EB" : "gray"
               Layout.alignment: Qt.AlignHCenter
               background: null
               onClicked: {
                  if(currentIndex === 4) return
                  currentIndex = 4
                  footerPageId.accountTapped()
                  tabSelected(4)
               }
            }
            Text{
               text: qsTr("Account")
               Layout.alignment: Qt.AlignHCenter
               font.pixelSize: footerPageId.tabFontSize
               //font.bold: currentIndex === 3
            }

         }
      }
   }

}






