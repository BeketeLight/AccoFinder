// var stackView = null

// function init( mainStackviewId) {
//     stackView = mainStackviewId
//     console.log("NaiationUtils Initialized")
// }

// function push(screenUrl, properties = {}){
//     if(!stackView){
//         console.log("Stackview not initialized")
//         return
//     }
//     stackView.push(screenUrl, properties)
// }
// function pop(){
//     if(stackView && stackView.depth > 1) stackView.pop()
// }
// function replace(screenUrl, properties = {}){
//     if(!stackView){
//         console.log("Stackview not initialized ")
//         return
//     }
//     stackView.replace(screenUrl, properties)
// }

// //=================SPECIFIC ROUTES FUNCTIONS=========
// function navigateToBookings(){
//     push("./ui/feature/bookings/screens/BookingListScreen.qml")
// }
// function navigateToBookings(){
//     push("./ui/feature/disputes/screens/DisputesScreen.qml")
// }
// function navigateToBookings(){
//     push("./ui/feature/notifications/screens/NotificationsScreen.qml")
// }
// function navigateToBookings(){
//     push("./ui/feature/properties/screens/PropertiesScreen.qml")
// }
// function navigateToSettings(){
//     push("./ui/feature/settings/screens/SettingsScreen.qml")
// }
// function navigateToBookings(){
//     push("./ui/feature/disputes/screens/DisputeListScreen.qml")
// }
// function navigateToAdmins(){
//     push("./ui/feature/auth/admins/screens/DisputeListScreen.qml")
// }
// var Navigation = {
//  init: init
// }