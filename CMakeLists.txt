cmake_minimum_required(VERSION 3.16)

project(AccoFinder VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appAccoFinder
    src/main.cpp
)

qt_add_qml_module(appAccoFinder
    URI AccoFinder
    QML_FILES
        src/Main.qml
        SOURCES src/models/user.h src/models/user.cpp
        SOURCES src/models/agent.h src/models/agent.cpp
        SOURCES src/models/landlord.h src/models/landlord.cpp
        SOURCES src/models/property.h src/models/property.cpp
        SOURCES src/models/room.h src/models/room.cpp
        SOURCES src/models/booking.h src/models/booking.cpp
        SOURCES src/models/payment.h src/models/payment.cpp
        SOURCES src/models/review.h src/models/review.cpp
        SOURCES src/models/verification.h src/models/verification.cpp
        SOURCES src/models/dispute.h src/models/dispute.cpp
        SOURCES src/application/controllers/bookingcontroller.h src/application/controllers/bookingcontroller.cpp
        SOURCES src/application/controllers/propertycontroller.h src/application/controllers/propertycontroller.cpp
        SOURCES src/application/controllers/paymentcontroller.h src/application/controllers/paymentcontroller.cpp
        SOURCES src/application/controllers/authcontroller.h src/application/controllers/authcontroller.cpp
        SOURCES src/application/dto/bookingdto.h src/application/dto/bookingdto.cpp
        SOURCES src/application/dto/propertydto.h src/application/dto/propertydto.cpp
        SOURCES src/application/dto/paymentdto.h src/application/dto/paymentdto.cpp
        SOURCES src/application/dto/userdto.h src/application/dto/userdto.cpp
        SOURCES src/services/apiclient.h src/services/apiclient.cpp
        SOURCES src/services/paymentgatewayimpl.h src/services/paymentgatewayimpl.cpp
        SOURCES src/services/notificationserviceimpl.h src/services/notificationserviceimpl.cpp
        SOURCES src/services/emailservice.h src/services/emailservice.cpp
        SOURCES src/repositories/interfaces/IBookingRepository.h
        SOURCES src/repositories/interfaces/IPropertyRepository.h
        SOURCES src/repositories/interfaces/IUserRepository.h
        SOURCES src/repositories/interfaces/IPaymentGateway.h
        SOURCES src/repositories/interfaces/IDisputeRepository.h
        SOURCES src/repositories/impl/bookingrepositoryimpl.h src/repositories/impl/bookingrepositoryimpl.cpp
        SOURCES src/repositories/impl/propertyrepositoryimpl.h src/repositories/impl/propertyrepositoryimpl.cpp
        SOURCES src/repositories/impl/userrepositoryimpl.h src/repositories/impl/userrepositoryimpl.cpp
        SOURCES src/repositories/impl/disputerepositoryimpl.h src/repositories/impl/disputerepositoryimpl.cpp
        SOURCES src/core/utils/EPropertyStatus.h
        SOURCES src/core/utils/EBookingStatus.h
        SOURCES src/core/utils/EPaymentStatus.h
        SOURCES src/core/utils/EVerificationStatus.h
        SOURCES src/core/utils/EDisputeStatus.h
        SOURCES src/presentation/models/propertylistmodel.h src/presentation/models/propertylistmodel.cpp
        SOURCES src/presentation/models/roomlistmodel.h src/presentation/models/roomlistmodel.cpp
        SOURCES src/presentation/models/bookinglistmodel.h src/presentation/models/bookinglistmodel.cpp
        SOURCES src/presentation/models/reviewlistmodel.h src/presentation/models/reviewlistmodel.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appAccoFinder PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appAccoFinder
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appAccoFinder
    PRIVATE Qt6::Quick
)
target_include_directories(appAccoFinder PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

install(TARGETS appAccoFinder
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
