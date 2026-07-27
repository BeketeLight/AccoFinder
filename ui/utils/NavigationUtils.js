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
    push("../features/properties/screens/PropertiesScreen.qml")
}
function navigateToPayments(){
    push("../features/properties/screens/PaymentsScreen.qml")
}
function navigateToSettings(){
    push("../features/settings/screens/SettingsScreen.qml")
}
function navigateToReviews(){
    push("../features/disputes/screens/ReviewsScreen.qml")
}
//========GLOBAL-AUTH=========
function navigateToAccount(){
    push("../features/auth/admins/screens/SignInScreen.qml")
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


var Navigation = {
    init: init,
    navigateToNotifications: navigateToNotifications,
    navigateToSignIn: navigateToSignIn,
    navigateToSignUp: navigateToSignUp,
    navigateToProperties: navigateToProperties,
    navigateToBookings: navigateToBookings
}