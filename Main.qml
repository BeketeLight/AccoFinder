import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./ui/components/navigations"
import "./ui/app"
import "./ui/features/properties/screens"
import "./ui/features/home/screens"
import "./ui/features/home/components"
import "./ui/features/home/models"
import "./ui/utils/NavigationUtils.js" as NavUtils
import "./ui/utils/Utils.js" as Utils
import "./ui/components/indicators"

ApplicationWindow {
    id: root

    width: 640
    height: 480
    visible: true
    title: qsTr("AccoFinder")
    flags: {
        if (Qt.platform.os === "android") {
            return Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint;
        } else {
            return Qt.Window;
        }
    }
    Material.primary: "#2563EB"
    Material.accent: Material.Blue

    // Theme is persisted by AppSettings and re-applied from themeChanged,
    // because the C++ getter itself is not a bindable property.
    property string themeSetting: AppSettings.theme()
    Material.theme: root.themeSetting === "Dark"
                    ? Material.Dark
                    : (root.themeSetting === "Light" ? Material.Light : Material.System)
    Material.background: root.themeSetting === "Dark" ? "#0F172A" : "#F8FAFC"
    Material.foreground: root.themeSetting === "Dark" ? "#E5E7EB" : "#111827"

    Connections {
        target: AppSettings
        function onThemeChanged() {
            root.themeSetting = AppSettings.theme()
        }
    }

    Component.onCompleted: {
        // NavUtils also receives the stack from MainStackview; passing the
        // window lets it route root tabs through the cached page host.
        NavUtils.init(mainStack.stackView, root);
        AppSettings.setStatusBarAppearance(Qt.rgba(0, 0, 0, 0), true);
        // Also covers a sign-in that completed before this QML existed - the
        // Google OAuth redirect can land on a cold-started app, and the session
        // it persisted must still route to the right page rather than the
        // public home screen.
        // The landing page change schedules the correctly scoped bell refresh.
        root.applySessionLanding();
    }

    function isRootLandingPage(url) {
        var s = url.toString();
        return s.endsWith("HomeScreen.qml") || s.endsWith("AdminsDashboardScreen.qml") || s.endsWith("AgentsDashboardScreen.qml") || s.endsWith("PropertiesScreen.qml");
    }

    // Picks the page the app should open on. Used both at startup and after a
    // sign-in, so the two can never disagree about where a session belongs.
    function sessionLandingSource() {
        if (AppSettings.isLoggedIn()) {
            var role = AppSettings.userType();
            if (role === "ADMIN" || role === "SUPER_ADMIN")
                return "./ui/features/dashboards/admins/screens/AdminsDashboardScreen.qml";
            if (role === "AGENT")
                return "./ui/features/properties/screens/PropertiesScreen.qml";
            // Clients land on Home.
            return "./ui/features/home/screens/HomeScreen.qml";
        }
        // A sign-up interrupted by the user leaving to read their emailed OTP
        // resumes straight into the wizard with their answers restored, rather
        // than dumping them on the home page to retype everything. The draft
        // expires on its own, so a genuinely new visitor still lands on Home.
        if (AppSettings.hasRegistrationDraft())
            return "./ui/features/auth/screens/SignUpScreen.qml";
        return "./ui/features/home/screens/HomeScreen.qml";
    }

    function sessionLandingNavIndex() {
        // Home tab (index 0) for everyone: it is Home for clients/agents and
        // the Dashboard for admins, which is also index 0.
        return 0;
    }

    // Entry point used by NavUtils and the footer. Root tabs are cached, so
    // switching back to a tab reuses the existing page instead of replaying
    // Component.onCompleted (and its network requests) on every tap.
    function showRootScreen(source) {
        rootPageArea.show(source);
    }

    // Clears any pushed pages and shows the page this session belongs on.
    function applySessionLanding() {
        mainStack.stackView.clear();
        // A new session must not inherit a cached dashboard/profile page from
        // the previous role or user.
        rootPageArea.clearCache();
        root.showRootScreen(root.sessionLandingSource());
        if (typeof bottomNavBar.currentIndex !== "undefined")
            bottomNavBar.currentIndex = root.sessionLandingNavIndex();
    }

    // -------------------------------------------------------------------
    // Shared home feed.
    //
    // Owned by the window so HomeScreen and the Saves screen's property tab
    // filter against the exact same rows. One fetch, one cache; a property
    // bookmarked on Home shows up in Saves with the same title/price/image.
    // -------------------------------------------------------------------
    // Never fall back to the hidden root page while a stack page is active;
    // that would let its header actions and drawer handlers act off-screen.
    readonly property var currentPage: (mainStack.depth > 0)
                                       ? mainStack.currentItem
                                       : rootPageArea.currentItem

    // The shared feed is also mirrored by the Saves tab, so its ListModel must
    // only be rebuilt while the page the user is actually looking at is idle.
    // Each root screen exposes `scrollIdle`; pushed pages without a scrollable
    // list are treated as idle so a refresh is never lost.
    // While a pushed page is on top, the cached root tabs are hidden and must
    // not rebuild their models at all; their pending reload runs after popping.
    readonly property bool activeScrollIdle: mainStack.depth > 0
                                             ? false
                                             : (!currentPage
                                                || (currentPage.visible
                                                    && currentPage.enabled
                                                    && (typeof currentPage.scrollIdle === "undefined"
                                                        || currentPage.scrollIdle)))

    // The notification feed is role-scoped. The admin dashboard bell shows the
    // account-level feed, while the properties/agent dashboard bell shows the
    // AGENT feed. Root pages are cached, so switching tabs does not replay their
    // onCompleted fetches; refresh the shared list here whenever the active root
    // page changes (or a pushed page is popped back to it). Otherwise the badge
    // keeps the previous tab's count until the next periodic poll.
    function refreshNotificationBellForActivePage() {
        if (!AppSettings.isLoggedIn() || mainStack.depth > 0)
            return;

        var source = rootPageArea.currentSource;
        if (source.endsWith("PropertiesScreen.qml") || source.endsWith("AgentsDashboardScreen.qml"))
            NotificationViewModel.getNotificationsByRole(Utils.notificationRoleForViewer());
        else if (source.length > 0)
            NotificationViewModel.getNotifications();
    }

    PropertiesModel {
        id: sharedProperties
        refreshAllowed: root.activeScrollIdle
    }
    readonly property bool isAdminDashboard: currentPage && typeof currentPage.pageTitle !== "undefined" && currentPage.pageTitle === qsTr("Admin Dashboard")
    readonly property bool isAgentDashboard: currentPage && typeof currentPage.pageTitle !== "undefined" && currentPage.pageTitle === qsTr("Agent Dashboard")
    readonly property bool isAgentDashboardHost: currentPage && typeof currentPage.isAgentDashboardHost !== "undefined" && currentPage.isAgentDashboardHost
    readonly property bool agentMenuActive: isAgentDashboard || isAgentDashboardHost

    Shortcut {
        sequences: ["Back", "Esc"]
        context: Qt.ApplicationShortcut
        onActivated: {
            if (mainStack.depth > 1) {
                NavUtils.pop();
                return;
            }
            if (mainStack.depth === 1) {
                mainStack.stackView.clear();
                return;
            }
            // Root landing pages (Home for clients, Admin Dashboard for admins, Agent Properties) exit the app
            if (!isRootLandingPage(rootPageArea.currentSource)) {
                root.showRootScreen(root.sessionLandingSource());

                if (typeof bottomNavBar.currentIndex !== "undefined") {
                    bottomNavBar.currentIndex = 0;
                }
                return;
            }

            // if already on Home quit
            AppLifecycle.quit();
        }
    }

    // Coalesce tab changes, stack pops and the polling tick into one fetch.
    // rootPageArea.show() clears the stack before switching pages, so several
    // signals can arrive in the same event loop; a 0ms timer keeps that to a
    // single request with the final page's scope.
    Timer {
        id: notificationBellRefreshTimer
        interval: 0
        repeat: false
        onTriggered: root.refreshNotificationBellForActivePage()
    }

    function scheduleNotificationBellRefresh() {
        notificationBellRefreshTimer.restart()
    }

    Connections {
        target: rootPageArea
        function onCurrentSourceChanged() { root.scheduleNotificationBellRefresh() }
    }

    Connections {
        target: mainStack.stackView
        function onDepthChanged() {
            if (mainStack.depth === 0)
                root.scheduleNotificationBellRefresh()
        }
    }

    // Lightweight REST polling for the notification bell badge: refresh using
    // the active page's scope so the unread count stays current without a
    // manual pull-to-refresh and without showing another tab's count.
    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: {
            if (AppSettings.isLoggedIn())
                root.scheduleNotificationBellRefresh()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        //Main area: page + floating header
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                //Reserves space under solid header only
                //On transparent header, 0 so the image starts from the top
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: {
                        if (!appHeader.visible)
                            return 0;
                        if (appHeader.transparentHeader)
                            return 0;
                        return appHeader.implicitHeight;
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    // Root-level pages are created once and kept alive here.
                    // A Loader with a changing `source` destroyed each page on
                    // every footer tap, replaying all of its startup requests.
                    Item {
                        id: rootPageArea
                        anchors.fill: parent
                        // Stay rendered under a pushed page. If a StackView
                        // item ever fails to appear, the active root page is
                        // still on screen instead of a blank white rectangle.
                        visible: true

                        property var _pages: ({})
                        property var currentItem: null
                        property string currentSource: ""

                        function configurePage(page) {
                            if (page.objectName === "SavesScreen" && "sharedPropertiesModelRef" in page)
                                page.sharedPropertiesModelRef = sharedProperties;
                            else if (page.objectName === "HomeScreen" && "propertiesModelRef" in page)
                                page.propertiesModelRef = sharedProperties;

                            // Give loaded pages access to the ApplicationWindow
                            // for network-availability checks.
                            if ("accessToOfflineCach" in page)
                                page.accessToOfflineCach = root;

                            // A cached root page stays rendered as the underlay
                            // while a pushed page is shown, but it must not
                            // answer signals or accept input during that time.
                            // Qt.binding keeps this in step with push/pop,
                            // which do not call show() and so cannot be handled
                            // by assigning a one-off value here.
                            page.enabled = Qt.binding(function() {
                                return page.visible && mainStack.depth === 0;
                            });
                        }

                        function show(source) {
                            var key = Qt.resolvedUrl(source).toString();
                            if (mainStack.depth > 0)
                                mainStack.stackView.clear();

                            var page = _pages[key];
                            if (!page) {
                                var component = Qt.createComponent(key);
                                if (component.status === Component.Error) {
                                    console.log("Cannot load root page:", key,
                                                component.errorString());
                                    return;
                                }
                                // Inject shared models at creation time. Doing
                                // it in configurePage() afterwards was too late:
                                // Component.onCompleted had already created and
                                // fetched the private fallback model.
                                var initialProperties = { "visible": false };
                                if (key.endsWith("HomeScreen.qml"))
                                    initialProperties.propertiesModelRef = sharedProperties;
                                else if (key.endsWith("SavesScreen.qml"))
                                    initialProperties.sharedPropertiesModelRef = sharedProperties;

                                page = component.createObject(rootPageArea, initialProperties);
                                if (!page) {
                                    console.log("Could not create root page:", key);
                                    return;
                                }
                                configurePage(page);
                                page.anchors.fill = rootPageArea;
                                _pages[key] = page;
                            }

                            for (var cachedKey in _pages) {
                                if (_pages.hasOwnProperty(cachedKey))
                                    _pages[cachedKey].visible = (cachedKey === key);
                            }
                            currentItem = page;
                            currentSource = key;
                        }

                        function clearCache() {
                            for (var key in _pages) {
                                if (_pages.hasOwnProperty(key))
                                    _pages[key].destroy();
                            }
                            _pages = ({});
                            currentItem = null;
                            currentSource = "";
                        }
                    }
                    MainStackview {
                        id: mainStack
                        anchors.fill: parent
                        visible: depth > 0
                    }
                }
            }
            AppHeader {
                id: appHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: implicitHeight
                z: 10
                //collapse header if not specified
                // Bind collapsible & transparency
                transparentHeader: currentPage && typeof currentPage.transparentHeader !== "undefined" ? currentPage.transparentHeader : false
                collapsible: Boolean(currentPage && currentPage.collapsible)
                scrollY: currentPage && typeof currentPage.scrollY !== "undefined" ? currentPage.scrollY : 0
                visible: {
                    if (!currentPage)
                        return false;
                    return typeof currentPage.showHeader !== "undefined" ? currentPage.showHeader : true;
                }
                //binding readonly to for searchBar
                searchReadOnly: currentPage && typeof currentPage.searchReadOnly !== "undefined" ? currentPage.searchReadOnly : false

                onSearchBarTapped: {
                    if (currentPage && typeof currentPage.onSearchBarTapped === "function") {
                        currentPage.onSearchBarTapped();
                    }
                }
                title: currentPage && currentPage.pageTitle ? currentPage.pageTitle : ""
                isSearchBar: Boolean(currentPage && currentPage.isSearchBar)
                titleFontSize: (currentPage && typeof currentPage.titleFontSize !== "undefined") ? currentPage.titleFontSize : 15
                showBottomBorder: (currentPage && typeof currentPage.showBottomBorder !== "undefined") ? currentPage.showBottomBorder : true
                showBackButton: mainStack.depth > 0 || Boolean(currentPage && currentPage.showBack)
                leftAction: (isAdminDashboard || agentMenuActive) ? hamburgerMenuComponent : (currentPage && currentPage.leftComponentAction ? currentPage.leftComponentAction : null)
                rightAction: currentPage && currentPage.rightComponentAction ? currentPage.rightComponentAction : null

                onBackClicked: {
                    if (currentPage && typeof currentPage.goBack === "function") {
                        currentPage.goBack();
                        return;
                    }
                    if (mainStack.depth > 0) {
                        NavUtils.pop();
                    }
                }
                onMenuButtonClicked: {
                    if (agentMenuActive)
                        agentDrawer.open();
                    else
                        adminDrawer.open();
                }
            }
        }
        //header always on top page area

        // Plain Item container: anchored children keep their size even while
        // invisible, so the first push of a session always lands in a sized stack.
        // Item {
        //     Layout.fillWidth: true
        //     Layout.fillHeight: true

        //     Loader {
        //         id: loader
        //         anchors.fill: parent
        //         visible: mainStack.depth === 0
        //         source: "./ui/features/home/screens/HomeScreen.qml"
        //     }
        //     MainStackview {
        //         id: mainStack
        //         anchors.fill: parent
        //         visible: depth > 0
        //     }
        // }

        Connections {
            target: AuthController
            function onUserLoggedOut() {
                mainStack.stackView.clear();
                rootPageArea.clearCache();
                root.showRootScreen("./ui/features/auth/pages/CreateAccountPage.qml");
                bottomNavBar.currentIndex = 4;
            }
            function onAccountSuspended() {
                // Force logout of an already-signed-in user whose account was
                // suspended (detected mid-session via fetchProfile). During a
                // fresh login attempt the user is not logged in yet, so the
                // SignInPage handler simply shows the suspension message.
                if (!AppSettings.isLoggedIn())
                    return;
                AuthController.logOut();
                NavUtils.resetToSignIn();
            }
            function onSignInSucceded(user) {
                // Covers password sign-in and the Google OAuth redirect alike,
                // since both land here through AuthController.
                root.applySessionLanding();
                root.scheduleNotificationBellRefresh();
            }
        }

        // Admin dashboard routing: stat cards, quick actions and activity rows.
        Connections {
            // Ignore dashboard signals while a pushed page is active; the
            // cached dashboard stays alive as an underlay but is not interactive.
            target: (mainStack.depth === 0 && rootPageArea.currentItem
                     && rootPageArea.currentItem.quickActionTriggered !== undefined)
                    ? rootPageArea.currentItem : null

            function onQuickActionTriggered(actionTitle) {
                if (actionTitle === qsTr("Verification queue") || actionTitle === qsTr("Property approvals"))
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PropertyApprovalScreen.qml"));
                else if (actionTitle === qsTr("User management"))
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/UserManagementScreen.qml"));
                else if (actionTitle === qsTr("Register agent"))
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/UserManagementScreen.qml"));
                else if (actionTitle === qsTr("Dispute resolution"))
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/DisputesScreen.qml"));
                else if (actionTitle === qsTr("Payments oversight"))
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PaymentsOversightScreen.qml"));
                else
                    console.log("Unhandled admin quick action:", actionTitle);
            }
            function onUsersRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/UserManagementScreen.qml"));
            }
            function onAgentsRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/AgentManagementScreen.qml"));
            }
            function onPropertiesRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/AllPropertiesScreen.qml"));
            }
            function onApprovalsRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PropertyApprovalScreen.qml"));
            }
            function onBookingsRequested() {
                // Pushed, not swapped into the cached root page: every other
                // card uses NavUtils.push, and hiding the root page here would
                // destroy the dashboard the user was standing on.
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/AdminBookingsScreen.qml"));
            }
            function onPaymentsRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PaymentsOversightScreen.qml"));
            }
            function onDisputesRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/DisputesScreen.qml"));
            }
            function onNotificationsRequested() {
                NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/SystemNotificationsScreen.qml"));
            }
            function onActivityTriggered(kind, targetId) {
                if (kind === "users" || kind === "agents-register")
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/UserManagementScreen.qml"));
                else if (kind === "approvals") {
                    // The activity row carries the property id, so open that
                    // property's review detail directly instead of the queue.
                    // Falls back to the queue when its payload is not loaded.
                    var activityPropertyId = (targetId !== undefined) ? String(targetId) : "";
                    var activityPayload = activityPropertyId.length > 0 ? PropertyViewModel.registrationPayloadFor(activityPropertyId) : null;
                    if (activityPayload && activityPayload.propertyId !== undefined && String(activityPayload.propertyId).length > 0)
                        NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PropertyApprovalDetailScreen.qml"), {
                            propertyPayload: activityPayload,
                            propertyId: activityPropertyId,
                            listingsModel: null
                        });
                    else
                        NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PropertyApprovalScreen.qml"));
                } else if (kind === "payments")
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/PaymentsOversightScreen.qml"));
                else if (kind === "disputes")
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/DisputesScreen.qml"));
                else if (kind === "agents")
                    NavUtils.push(Qt.resolvedUrl("./ui/features/dashboards/admins/screens/AgentApplicationsScreen.qml"));
                else
                    console.log("Unhandled admin activity kind:", kind);
            }
            function onMenuRequested() {
                adminDrawer.open();
            }
        }

        FooterComponent {
            id: bottomNavBar
            Layout.fillWidth: true
            Layout.preferredHeight: 65
            visible: mainStack.depth === 0
            //signals
            onHomeTapped: Qt.callLater(function() {
                NavUtils.showRootScreen("./ui/features/home/screens/HomeScreen.qml")
            })
            onPropertiesTapped: Qt.callLater(function() {
                NavUtils.showRootScreen("./ui/features/properties/screens/PropertiesScreen.qml")
            })
            onAccountTapped: Qt.callLater(function() {
                NavUtils.showRootScreen(AppSettings.isLoggedIn()
                    ? "./ui/features/auth/pages/Profile.qml"
                    : "./ui/features/auth/pages/CreateAccountPage.qml")
            })
            onBookingsTapped: Qt.callLater(function() {
                NavUtils.showRootScreen("./ui/features/bookings/screens/BookingsScreen.qml")
            })
            onSaveTapped: Qt.callLater(function() {
                NavUtils.showRootScreen("./ui/features/favourites/screen/SavesScreen.qml")
            })
            onDashboardTapped: Qt.callLater(function() {
                NavUtils.showRootScreen(root.sessionLandingSource())
            })
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
