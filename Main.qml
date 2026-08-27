import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./ui/components/navigations"
import "./ui/app"
import "./ui/features/properties/screens"
import "./ui/features/home/screens"
import "./ui/features/home/components"
import "./ui/utils/NavigationUtils.js" as NavUtils

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("AccoFinder")
    flags: {
        if (Qt.platform.os === "android") {
            return Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint
        } else {
            return Qt.Window
        }
    }
    Material.primary : "#2563EB"
    Material.accent : Material.Blue
    Component.onCompleted: {
        AppSettings.setStatusBarAppearance(Qt.rgba(0,0,0,0),true)
        if (AppSettings.isLoggedIn() &&
                (AppSettings.userType() === "ADMIN" || AppSettings.userType() === "SUPER_ADMIN"))
            loader.source = "./ui/features/dashboards/admins/screens/AdminsDashboardScreen.qml"
    }

    function isRootLandingPage(url) {
        var s = url.toString()
        return s.endsWith("HomeScreen.qml") || s.endsWith("AdminsDashboardScreen.qml")
    }
    readonly property var currentPage: (mainStack.depth > 0 && mainStack.currentItem)
                                    ? mainStack.currentItem
                                    :(loader.item ? loader.item: null)
    readonly property bool isAdminDashboard: currentPage
                                             && typeof currentPage.pageTitle !== "undefined"
                                             && currentPage.pageTitle === qsTr("Admin Dashboard")
    readonly property bool isAgentDashboard: currentPage
                                             && typeof currentPage.pageTitle !== "undefined"
                                             && currentPage.pageTitle === qsTr("Agent Dashboard")
    readonly property bool isAgentDashboardHost: currentPage
                                             && typeof currentPage.isAgentDashboardHost !== "undefined"
                                             && currentPage.isAgentDashboardHost
    readonly property bool agentMenuActive: isAgentDashboard || isAgentDashboardHost

    Shortcut {
        sequences: ["Back", "Esc"]
        context: Qt.ApplicationShortcut
        onActivated: {
            if(mainStack.depth > 1){
                NavUtils.pop()
                return
            }
            if(mainStack.depth === 1){
                mainStack.stackView.clear()
                return
            }
            // Root landing pages (Home for clients, Admin Dashboard for admins) exit the app
            if (!isRootLandingPage(loader.source)) {
                loader.source = (AppSettings.isLoggedIn() &&
                                 (AppSettings.userType() === "ADMIN" || AppSettings.userType() === "SUPER_ADMIN"))
                                ? "./ui/features/dashboards/admins/screens/AdminsDashboardScreen.qml"
                                : "./ui/features/home/screens/HomeScreen.qml"

                if (typeof bottomNavBar.currentIndex !== "undefined") {
                    bottomNavBar.currentIndex = 0
                }
                return
            }

            // if already on Home quit
            Qt.quit()
        }
    }

    ColumnLayout{
        anchors.fill: parent
        spacing: 0

        AppHeader{
            id: appHeader
            Layout.fillWidth: true
            //collapse header if not specified
            Layout.preferredHeight: visible ? 64 : 0
            visible: {
                if(!currentPage) return false
                return typeof currentPage.showHeader !== "undefined" ? currentPage.showHeader: true
            }
            //binding readonly to for searchBar
            searchReadOnly: currentPage && typeof currentPage.searchReadOnly !== "undefined"
                            ? currentPage.searchReadOnly
                            : false

            onSearchBarTapped: {
                if(currentPage && typeof currentPage.onSearchBarTapped === "function"){
                    currentPage.onSearchBarTapped()
                }
            }
            title: currentPage && currentPage.pageTitle ? currentPage.pageTitle:""
            isSearchBar: Boolean(currentPage && currentPage.isSearchBar)
            titleFontSize: (currentPage && typeof currentPage.titleFontSize !== "undefined")
                           ? currentPage.titleFontSize : 18
            showBottomBorder: (currentPage && typeof currentPage.showBottomBorder !== "undefined")
                              ? currentPage.showBottomBorder : true
            showBackButton: mainStack.depth > 0 || Boolean(currentPage && currentPage.showBack)
            leftAction: (isAdminDashboard || agentMenuActive) ? hamburgerMenuComponent
                        : (currentPage && currentPage.leftComponentAction ? currentPage.leftComponentAction : null)
            rightAction: currentPage && currentPage.rightComponentAction ? currentPage.rightComponentAction: null

            onBackClicked: {
                if (currentPage && typeof currentPage.goBack === "function") {
                    currentPage.goBack()
                    return
                }
                if (mainStack.depth > 0) {
                    NavUtils.pop()
                }
            }
            onMenuButtonClicked: {
                if (agentMenuActive)
                    agentDrawer.open()
                else
                    adminDrawer.open()
            }
        }
        // Plain Item container: anchored children keep their size even while
        // invisible, so the first push of a session always lands in a sized stack.
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Loader{
                id: loader
                anchors.fill: parent
                visible: mainStack.depth === 0
                source: "./ui/features/home/screens/HomeScreen.qml"
            }
            MainStackview{
                id: mainStack
                anchors.fill: parent
                visible: depth > 0
            }
        }

        Connections {
            target: AuthController
            function onUserLoggedOut() {
                mainStack.stackView.clear()
                loader.source = "./ui/features/auth/pages/CreateAccountPage.qml"
                bottomNavBar.currentIndex = 4
            }
            function onSignInSucceded(user) {
                mainStack.stackView.clear()
                var role = AppSettings.userType()
                if (role === "ADMIN" || role === "SUPER_ADMIN") {
                    loader.source = "./ui/features/dashboards/admins/screens/AdminsDashboardScreen.qml"
                    bottomNavBar.currentIndex = 0
                } else {
                    loader.source = "./ui/features/auth/pages/Profile.qml"
                    bottomNavBar.currentIndex = 4
                }
            }
        }

        // Admin dashboard routing: stat cards, quick actions and activity rows.
        Connections {
            target: (loader.item && loader.item.quickActionTriggered !== undefined) ? loader.item : null

            function onQuickActionTriggered(actionTitle) {
                if (actionTitle === qsTr("Verification queue") || actionTitle === qsTr("Property approvals"))
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PropertyApprovalScreen.qml"))
                else if (actionTitle === qsTr("User management"))
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/UserManagementScreen.qml"))
                else if (actionTitle === qsTr("Register agent"))
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/RegisterAgentScreen.qml"))
                else if (actionTitle === qsTr("Dispute resolution"))
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/DisputesScreen.qml"))
                else if (actionTitle === qsTr("Payments oversight"))
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PaymentsOversightScreen.qml"))
                else
                    console.log("Unhandled admin quick action:", actionTitle)
            }
            function onUsersRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/UserManagementScreen.qml"))
            }
            function onAgentsRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/AgentManagementScreen.qml"))
            }
            function onPropertiesRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/AllPropertiesScreen.qml"))
            }
            function onApprovalsRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PropertyApprovalScreen.qml"))
            }
            function onBookingsRequested() {
                loader.source = "./ui/features/bookings/screens/BookingsScreen.qml"
            }
            function onPaymentsRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PaymentsOversightScreen.qml"))
            }
            function onDisputesRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/DisputesScreen.qml"))
            }
            function onNotificationsRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/SystemNotificationsScreen.qml"))
            }
            function onActivityTriggered(kind) {
                if (kind === "users" || kind === "agents-register")
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/UserManagementScreen.qml"))
                else if (kind === "approvals")
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PropertyApprovalScreen.qml"))
                else if (kind === "payments")
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PaymentsOversightScreen.qml"))
                else if (kind === "disputes")
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/DisputesScreen.qml"))
                else if (kind === "agents")
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/AgentApplicationsScreen.qml"))
                else
                    console.log("Unhandled admin activity kind:", kind)
            }
            function onMenuRequested() {
                adminDrawer.open()
            }
        }

        FooterComponent{
            id: bottomNavBar
            Layout.fillWidth: true
            Layout.preferredHeight: 65
            visible: mainStack.depth === 0
            //signals
            onHomeTapped: loader.source = "./ui/features/home/screens/HomeScreen.qml"
            onPropertiesTapped: loader.source = "./ui/features/properties/screens/PropertiesScreen.qml"
            onAccountTapped: loader.source = AppSettings.isLoggedIn()
                             ? "./ui/features/auth/pages/Profile.qml"
                             : "./ui/features/auth/pages/CreateAccountPage.qml"
            onBookingsTapped: loader.source = "./ui/features/bookings/screens/BookingsScreen.qml"
            onSaveTapped: loader.source = ""
            onDashboardTapped: loader.source = "./ui/features/dashboards/admins/screens/AdminsDashboardScreen.qml"
        }

    }

    Component {
        id: hamburgerMenuComponent
        ToolButton {
            implicitHeight: 48
            implicitWidth: 48
            icon.source: "qrc:/ui/assets/hamburger-icon.svg"
            icon.color: "#111111"
            icon.height: 20
            icon.width: 20
            onClicked: appHeader.menuButtonClicked()
        }
    }

    Drawer {
        id: adminDrawer
        width: 300
        height: parent.height
        edge: Qt.LeftEdge
        background: Rectangle { color: "#FFFFFF" }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 6

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 56
                radius: 12
                color: "#EFF6FF"

                Label {
                    anchors.centerIn: parent
                    text: qsTr("Quick actions")
                    color: "#2563EB"
                    font.pixelSize: 16
                    font.bold: true
                }
            }

            Repeater {
                model: [
                    { title: qsTr("Verification queue"), detail: qsTr("Approve or reject listings"), kind: "approvals" },
                    { title: qsTr("User management"), detail: qsTr("View clients and agents"), kind: "users" },
                    { title: qsTr("Register agent"), detail: qsTr("Create a new agent account"), kind: "agents-register" },
                    { title: qsTr("Property approvals"), detail: qsTr("Pending verification queue"), kind: "approvals" },
                    { title: qsTr("Dispute resolution"), detail: qsTr("Review open disputes"), kind: "disputes" },
                    { title: qsTr("Payments oversight"), detail: qsTr("Commissions and payouts"), kind: "payments" }
                ]

                delegate: Rectangle {
                    required property var model
                    required property int index
                    Layout.fillWidth: true
                    Layout.topMargin: index === 0 ? 6 : 0
                    implicitHeight: drawerRow.implicitHeight + 18
                    radius: 10
                    color: drawerMouse.pressed ? "#F0F4FF" : "transparent"

                    Rectangle {
                        visible: index > 0
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        height: 1
                        color: "#E5E7EB"
                    }

                    RowLayout {
                        id: drawerRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 4
                            Layout.preferredHeight: 32
                            radius: 2
                            color: "#2563EB"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                Layout.fillWidth: true
                                text: model.title
                                color: "#1F2937"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true
                                text: model.detail
                                color: "#6B7280"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        id: drawerMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            adminDrawer.close()
                            if (model.kind === "users")
                                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/UserManagementScreen.qml"))
                            else if (model.kind === "approvals")
                                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PropertyApprovalScreen.qml"))
                            else if (model.kind === "agents-register")
                                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/RegisterAgentScreen.qml"))
                            else if (model.kind === "disputes")
                                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/DisputesScreen.qml"))
                            else if (model.kind === "payments")
                                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PaymentsOversightScreen.qml"))
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    Drawer {
        id: agentDrawer
        width: 300
        height: parent.height
        edge: Qt.LeftEdge
        background: Rectangle { color: "#FFFFFF" }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 6

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 56
                radius: 12
                color: "#EFF6FF"

                Label {
                    anchors.centerIn: parent
                    text: qsTr("Agent menu")
                    color: "#2563EB"
                    font.pixelSize: 16
                    font.bold: true
                }
            }

            Repeater {
                model: [
                    { title: qsTr("My property"), detail: qsTr("Manage your listings and drafts"), kind: "properties" },
                    { title: qsTr("Recent bookings"), detail: qsTr("Bookings on your listings"), kind: "bookings" },
                    { title: qsTr("Open disputes"), detail: qsTr("Disputes raised on your listings"), kind: "disputes" }
                ]

                delegate: Rectangle {
                    required property var model
                    required property int index
                    Layout.fillWidth: true
                    Layout.topMargin: index === 0 ? 6 : 0
                    implicitHeight: agentDrawerRow.implicitHeight + 18
                    radius: 10
                    color: agentDrawerMouse.pressed ? "#F0F4FF" : "transparent"

                    Rectangle {
                        visible: index > 0
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        height: 1
                        color: "#E5E7EB"
                    }

                    RowLayout {
                        id: agentDrawerRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 4
                            Layout.preferredHeight: 32
                            radius: 2
                            color: "#2563EB"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                Layout.fillWidth: true
                                text: model.title
                                color: "#1F2937"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true
                                text: model.detail
                                color: "#6B7280"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        id: agentDrawerMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            agentDrawer.close()
                            if (model.kind === "properties")
                                NavUtils.push(Qt.resolvedUrl("./ui/features/properties/screens/PropertiesScreen.qml"))
                            else if (model.kind === "bookings")
                                NavUtils.push(Qt.resolvedUrl("./ui/features/bookings/screens/BookingsScreen.qml"))
                            else if (model.kind === "disputes")
                                NavUtils.push(Qt.resolvedUrl("./ui/features/disputes/screens/DisputesScreen.qml"))
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
