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
    if(stackView.depth ===0){
        stackView.push(screenUrl,properties)
    }else{
        stackView.push(screenUrl, properties)
   }
    }

function replace(screenUrl, properties = {}){
    if(!stackView){
        console.warn("NavigationUtils cannot replace: Stackview not initialized")
        return
    }
    stackView.replace(screenUrl, properties)
}
function replaceAll(screenUrl, properties = {}){
    if(!stackView){
        console.warn("NavigationUtils cannot replaceAll: Stackview not initialized")
        return
    }

    // Leave only this page on the stack so Back cannot return to prior screens.
    if (stackView.depth > 0)
        stackView.replace(stackView.get(0), screenUrl, properties)
    else
        stackView.push(screenUrl, properties)
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
    }
    else {
        console.warn("[NavigationUtils] Stack is already empty.");
    }
}
//=================SPECIFIC ROUTES FUNCTIONS=========
function navigateToBookings(){
    push("../features/bookings/screens/BookingsScreen.qml")
}
function navigateToPendingBookings(){
    push("../features/bookings/pages/PendingBookingsPage.qml")
}
function navigateToCancelleddBookings(){
    push("../features/bookings/pages/CancelledBookingsPage.qml")
}
function navigateToBookingView(){
    push("../features/bookings/pages/BookingView.qml")
}
function  navigateToConfirmedBookings(){
    push("../features/bookings/pages/ConfirmedBokingsPage.qml")
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
function navigateToAddProperty(){
    push("../features/properties/screens/AddPropertyScreen.qml")
}
function navigateToDrafts(){
    push("../features/properties/screens/DraftsScreen.qml")
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
function navigateToResetPassword(email){
    push("../features/auth/pages/ResetPasswordPage.qml", {
        email: email || ""
    })
}
//===================AUTH=======================
function navigateToSignIn(){
    push("../features/auth/screens/SignInScreen.qml")
}
function resetToSignIn(){
    replaceAll("../features/auth/screens/SignInScreen.qml")
}
function navigateToSignUp(){
    push("../features/auth/screens/SignUpScreen.qml")
}
function navigateToCreateAccount(){
    if (typeof AppSettings !== "undefined" && AppSettings.isLoggedIn())
        push("../features/auth/pages/Profile.qml")
    else
        push("../features/auth/pages/CreateAccountPage.qml")
}
function navigateToProfile(){
    push("../features/auth/pages/Profile.qml")
}
function resetToProfile(){
    replaceAll("../features/auth/pages/Profile.qml")
}
function navigateToOtp(email, purpose, initialError){
    push("../features/auth/screens/OtpScree.qml", {
             email: email || "",
             purpose: purpose || "registration",
             initialError: initialError || ""
         })
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
function navigateToBookingsView(filter){
    push("../features/bookings/pages/BookingView.qml",{
        activeFilter:  filter || "All"
    })
}
function navigateToBookingDetails(){
    push("../features/bookings/pages/BookingDetailsPage.qml")
}
function navigateToBookingsDetailsClient(data){
    push("../features/bookings/pages/ClientBookinDetailsPage.qml", {
            bookingId: data.bookingId || "",
            status: data.status || "Pending",
            statusNote: data.statusNote || "",
            houseName: data.houseName || "",
            landlordName: data.landlordName || "",
            imageUrl: data.imageUrl || "",
            checkIn: data.checkIn || "",
            checkOut: data.checkOut || "",
            specialRequests: data.specialRequests || "",
            roomPrice: data.roomPrice || 0.0,
            discount: data.discount || 0.0,
            paymentStatus: data.paymentStatus || "Unpaid",
            paymentMethod: data.paymentMethod || "",
            paymentDate: data.paymentDate || "",
            keyInstructions: data.keyInstructions || "",
            cancellationPolicy: data.cancellationPolicy || ""
         });
}
function navigateToBookingsDetailsOwneByAgent(data){
    push("../features/bookings/pages/AgentBookingDetailsOnOwnedPropertiesPage.qml", {
            bookingId: data.bookingId || "",
            status: data.status || "",
            houseName: data.houseName || "",
            propertyLocation: data.propertyLocation || "124 Lakeview Drive, Sector 4",
            propertyImage: data.propertyImage || "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=500",
            roomType: data.roomType || "2 Bedrooms",

            clientName: data.clientName || "John Doe",
            clientPhone: data.clientPhone || "+1 555-0192",
            clientEmail: data.clientEmail || "johndoe@example.com",
                 //readonly property int guestCount: model.guestCount ?? 3
            checkIn: data.checkIn || data.bookingDate || data.dateRange || "",
            baseAmount: data.baseAmount,
            serviceFee: data.serviceFee,
            totalAmount: data.totalAmount ,
            paymentStatus: data.paymentStatus || "Paid",
            paymentMethod: data.paymentMethod ?? "Credit Card (Visa ending in 4242)",
            paymentDate: data.paymentDate || "Oct 10, 2026",
            //bookingFee: data.bookingFee,

            //createdTime: data.createdTime || "Oct 10, 2026 at 10:15 AM"
            //paidTime: model.paidTime ?? "Oct 10, 2026 at 10:18 AM"
           // approvedTime:
    });
}

var Navigation = {
    init: init,
    pop: pop,
    replaceAll: replaceAll,
    navigateToNotifications: navigateToNotifications,
    navigateToSignIn: navigateToSignIn,
    resetToSignIn: resetToSignIn,
    navigateToSignUp: navigateToSignUp,
    navigateToOtp: navigateToOtp,
    navigateToForgotPassword: navigateToForgotPassword,
    navigateToResetPassword: navigateToResetPassword,
    navigateToAccount: navigateToAccount,
    navigateToProfile: navigateToProfile,
    resetToProfile: resetToProfile,
    navigateToProperties: navigateToProperties,
    navigateToAddProperty: navigateToAddProperty,
    navigateToDrafts: navigateToDrafts,
    navigateToBookings: navigateToBookings,
    navigateToPropertyDetails: navigateToPropertyDetails,
    navigateToPayments: navigateToPayments,
    navigateToPaymentStatus:  navigateToPaymentStatus,
    navigateToPendingBookings: navigateToPendingBookings,
    navigateToCancelleddBookings: navigateToCancelleddBookings,
    navigateToConfirmedBookings: navigateToConfirmedBookings,
    navigateToBookingView: navigateToBookingView,
    navigateToBookingsView: navigateToBookingsView,
    navigateToBookingDetails: navigateToBookingDetails,
   // navigateToBookingsDetails: navigateToBookingsDetails,
    navigateToBookingsDetailsOwneByAgent: navigateToBookingsDetailsOwneByAgent
}
