.pragma library

var stackView = null

function init( mainStackview) {
    stackView = mainStackview
    console.log("NavigationUtils Initialized successfully")
}

function push(screenUrl, properties = {}){
    if(!stackView){
        console.log("NavigationUtils cannot push :Stackview not initialized")
        return
    }
    stackView.push(screenUrl, properties)
}
function replace(screenUrl, properties = {}){
    if(!stackView){
        console.warn("NavigationUtils cannot replace: Stackview not initialized")
        return
    }
    stackView.replace(screenUrl, properties)
}
function pop() {
    if (!stackView) {
        console.warn("[NavigationUtils] stackView is null");
        return;
    }

    console.log("[NavigationUtils] Current Stack Depth:", stackView.depth);

    if (stackView.depth > 1) {
        // Normal pop when multiple items are on the stack
        stackView.pop();
        console.log("[NavigationUtils] Popped successfully!");
    } else if (stackView.depth === 1) {
        // Root page on mainStack -> Clear stack to reveal the Loader/SignInScreen beneath!
        stackView.clear();
        console.log("[NavigationUtils] Stack cleared to reveal underlying Loader!");
    } else {
        console.warn("[NavigationUtils] Stack is already empty.");
    }
}
//=================SPECIFIC ROUTES FUNCTIONS=========
function navigateToBookings(){
    push("../features/bookings/screens/BookingsScreen.qml")
}
function navigateToDisputes(){
    push("../features/disputes/screens/DisputesScreen.qml")
}
function navigateToNotifications(){
    push("../features/notifications/screens/NotificationsScreen.qml")
}
function navigateToProperties(){
    push("../features/properties/screens/PropertiesScreen.qml")
}
function navigateToPayments(){
    push("../features/payments/screens/PaymentsScreen.qml")
}
function navigateToSettings(){
    push("../features/settings/screens/SettingsScreen.qml")
}
function navigateToReviews(){
    push("../features/disputes/screens/ReviewsScreen.qml")
}
//========GLOBAL-AUTH=========
function navigateToAccount(){
    push("../features/auth/screens/SignInScreen.qml")
}
function navigateToAdmins(){
    push("../features/auth/admins/screens/OtpScree.qml")
}
function navigateToForgotPassword(){
    push("../features/auth/pages/ForgotPasswordPage.qml")
}
//===================AUTH=======================
function navigateToSignIn(){
    push("../features/auth/screens/SignInScreen.qml")
}
function navigateToSignUp(){
    push("../features/auth/screens/SignUpScreen.qml")
}
function navigateToCreateAccount(){
    push("../features/auth/pages/CreateAccountPage.qml")
}
function navigateToOtp(){
    push("../features/auth/pages/OtpPage.qml")
}
//========================AUTH================
function navigateToPropertyDetails(){
    push("../features/properties/screens/PropertyDetailScreen.qml")
}
function navigateToPaymentStatus(){
    push("../features/payments/screens/PaymentStatusScreen.qml")
}
function navigateToSearchScreen(){
      push("../features/properties/screens/SearchPropertiesScreen.qml")
}
function navigateToAdminDashboard(){
    push("../features/dashboards/admins/screens/AdminsDashboardScreen.qml")
}

function navigateToDashboard(role){
    switch(role){
        case "admin":
            replace("../features/dashboard/screens/AdminsDashboardScreen.qml")
            break;
        case "agent":
            replace("../features/dashboard/screens/AgentsDashboardScreen.qml")
            break;
        case "client":
            replace("../features/dashboard/screens/ClientsDashboardScreen.qml")
            break;
        default:
            replace("../features/auth/screens/SignInScreen.qml")  
    }

}

var Navigation = {
    init: init,
    pop: pop,
    navigateToNotifications: navigateToNotifications,
    navigateToSignIn: navigateToSignIn,
    navigateToSignUp: navigateToSignUp,
    navigateToOtp: navigateToOtp,
    navigateToForgotPassword: navigateToForgotPassword,
    navigateToAccount: navigateToAccount,
    navigateToProperties: navigateToProperties,
    navigateToBookings: navigateToBookings,
    navigateToPropertyDetails: navigateToPropertyDetails,
    navigateToPayments: navigateToPayments,
    navigateToPaymentStatus:  navigateToPaymentStatus,
    navigateToSearchScreen: navigateToSearchScreen
}