.pragma library

var stackView = null

function init( mainStackviewId) {
    stackView = mainStackviewId
    console.log("NaiationUtils Initialized")
}

function push(screenUrl, properties = {}){
    if(!stackView){
        console.log("Stackview not initializedd")
        return
    }
    stackView.push(screenUrl, properties)
}
function replace(screenUrl, properties = {}){
    if(!stackView) return
    stackView.replace(screenUrl, properties)
}
function pop(){
    if(stackView && stackView.depth > 1) stackView.pop()
}
function replace(screenUrl, properties = {}){
    if(!stackView){
        console.log("Stackview not initialized ")
        return
    }
    stackView.replace(screenUrl, properties)
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
    replace("../features/properties/screens/PropertiesScreen.qml")
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
    replace("../features/auth/screens/SignInScreen.qml")
}
function navigateToAdmins(){
    push("../features/auth/admins/screens/OtpScree.qml")
}
function navigateToForgotPassword(){
    push("../features/auth/admins/screens/OtpScree.qml")
}
function navigateToSignIn(){
    push("../features/auth/screens/SignInScreen.qml")
}
function navigateToSignUp(){
    push("../features/auth/screens/SignUpScreen.qml")
}
function navigateToPropertyDetails(){
    push("../features/properties/screens/PropertyDetailScreen.qml")
}
function navigateToPaymentStatus(){
    push("../features/payments/screens/PaymentStatusScreen.qml")
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
    navigateToAccount: navigateToAccount,
    navigateToProperties: navigateToProperties,
    navigateToBookings: navigateToBookings,
    navigateToPropertyDetails: navigateToPropertyDetails,
    navigateToPayments: navigateToPayments,
    navigateToPaymentStatus:  navigateToPaymentStatus
}