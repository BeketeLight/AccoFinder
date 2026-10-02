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
    id: root

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
        // Also covers a sign-in that completed before this QML existed - the
        // Google OAuth redirect can land on a cold-started app, and the session
        // it persisted must still route to the right page rather than the
        // public home screen.
        root.applySessionLanding()
    }

    function isRootLandingPage(url) {
        var s = url.toString()
        return s.endsWith("HomeScreen.qml") || s.endsWith("AdminsDashboardScreen.qml")
    }

    // Picks the page the app should open on. Used both at startup and after a
    // sign-in, so the two can never disagree about where a session belongs.
    function sessionLandingSource() {
        if (AppSettings.isLoggedIn()) {
            var role = AppSettings.userType()
            if (role === "ADMIN" || role === "SUPER_ADMIN")
                return "./ui/features/dashboards/admins/screens/AdminsDashboardScreen.qml"
            return "./ui/features/auth/pages/Profile.qml"
        }
        // A sign-up interrupted by the user leaving to read their emailed OTP
        // resumes straight into the wizard with their answers restored, rather
        // than dumping them on the home page to retype everything. The draft
        // expires on its own, so a genuinely new visitor still lands on Home.
        if (AppSettings.hasRegistrationDraft())
            return "./ui/features/auth/screens/SignUpScreen.qml"
        return "./ui/features/home/screens/HomeScreen.qml"
    }

    function sessionLandingNavIndex() {
        if (!AppSettings.isLoggedIn())
            return 0
        var role = AppSettings.userType()
        if (role === "ADMIN" || role === "SUPER_ADMIN")
            return 0
        return 4
    }

    // Clears any pushed pages and shows the page this session belongs on.
    function applySessionLanding() {
        mainStack.stackView.clear()
        loader.source = root.sessionLandingSource()
        if (typeof bottomNavBar.currentIndex !== "undefined")
            bottomNavBar.currentIndex = root.sessionLandingNavIndex()
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

    // Lightweight REST polling for the notification bell badge: refresh the
    // logged-in user's notifications periodically so the unread count stays
    // current without requiring a manual pull-to-refresh.
    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: {
            if (AppSettings.isLoggedIn())
                NotificationViewModel.refreshCurrent()
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
                           ? currentPage.titleFontSize : 15
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
            function onAccountSuspended() {
                // Force logout of an already-signed-in user whose account was
                // suspended (detected mid-session via fetchProfile). During a
                // fresh login attempt the user is not logged in yet, so the
                // SignInPage handler simply shows the suspension message.
                if (!AppSettings.isLoggedIn())
                    return
                AuthController.logOut()
                NavUtils.resetToSignIn()
            }
            function onSignInSucceded(user) {
                // Covers password sign-in and the Google OAuth redirect alike,
                // since both land here through AuthController.
                root.applySessionLanding()
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
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/UserManagementScreen.qml"))
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
                // Pushed, not swapped into the root loader: every other card
                // uses NavUtils.push, and replacing the loader source here
                // destroyed the dashboard the user was standing on.
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/AdminBookingsScreen.qml"))
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

    AdminDrawer {
        id: adminDrawer
    }

    AgentDrawer {
        id: agentDrawer
    }
}
