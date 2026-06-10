cmake_minimum_required(VERSION 3.16)

project(AccoFinder VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appAccoFinder
    main.cpp
)

qt_add_qml_module(appAccoFinder
    URI AccoFinder
    VERSION 1.0
    QML_FILES
    Main.qml
    SOURCES
        src/models/user.h src/models/user.cpp
        src/models/agent.h src/models/agent.cpp
        src/models/landlord.h src/models/landlord.cpp
        src/models/property.h src/models/property.cpp
        src/models/room.h src/models/room.cpp
        src/models/booking.h src/models/booking.cpp
        src/models/payment.h src/models/payment.cpp
        src/models/review.h src/models/review.cpp
        src/models/verification.h src/models/verification.cpp
        src/models/dispute.h src/models/dispute.cpp
        src/application/controllers/bookingcontroller.h
        src/application/controllers/bookingcontroller.cpp
        src/application/controllers/propertycontroller.h
        src/application/controllers/propertycontroller.cpp
        src/application/controllers/paymentcontroller.h
        src/application/controllers/paymentcontroller.cpp
        src/application/controllers/authcontroller.h
        src/application/controllers/authcontroller.cpp
        src/application/dto/bookingdto.h
        src/application/dto/bookingdto.cpp
        src/application/dto/propertydto.h
        src/application/dto/propertydto.cpp
        src/application/dto/paymentdto.h
        src/application/dto/paymentdto.cpp
        src/application/dto/userdto.h
        src/application/dto/userdto.cpp
        src/services/apiclient.h
        src/services/apiclient.cpp
        src/services/paymentgatewayimpl.h
        src/services/paymentgatewayimpl.cpp
        src/services/notificationserviceimpl.h
        src/services/notificationserviceimpl.cpp
        src/services/emailservice.h
        src/services/emailservice.cpp
        src/repositories/interfaces/IBookingRepository.h
        src/repositories/interfaces/IPropertyRepository.h
        src/repositories/interfaces/IUserRepository.h
        src/repositories/interfaces/IPaymentGateway.h
        src/repositories/interfaces/IDisputeRepository.h
        src/repositories/impl/bookingrepositoryimpl.h
        src/repositories/impl/bookingrepositoryimpl.cpp
        src/repositories/impl/propertyrepositoryimpl.h
        src/repositories/impl/propertyrepositoryimpl.cpp
        src/repositories/impl/userrepositoryimpl.h
        src/repositories/impl/userrepositoryimpl.cpp
        src/repositories/impl/disputerepositoryimpl.h
        src/repositories/impl/disputerepositoryimpl.cpp
        src/core/utils/EPropertyStatus.h
        src/core/utils/EBookingStatus.h
        src/core/utils/EPaymentStatus.h
        src/core/utils/EVerificationStatus.h
        src/core/utils/EDisputeStatus.h
        src/presentation/models/propertylistmodel.h
        src/presentation/models/propertylistmodel.cpp
        src/presentation/models/roomlistmodel.h
        src/presentation/models/roomlistmodel.cpp
        src/presentation/models/bookinglistmodel.h
        src/presentation/models/bookinglistmodel.cpp
        src/presentation/models/reviewlistmodel.h
        src/presentation/models/reviewlistmodel.cpp
        src/presentation/viewmodels/bookingviewmodel.h
        src/presentation/viewmodels/bookingviewmodel.cpp
        src/presentation/viewmodels/propertyviewmodel.h
        src/presentation/viewmodels/propertyviewmodel.cpp
        src/presentation/viewmodels/reviewviewmodel.h
        src/presentation/viewmodels/reviewviewmodel.cpp
        src/presentation/viewmodels/roomviewmodel.h
        src/presentation/viewmodels/roomviewmodel.cpp
        src/models/client.h src/models/client.cpp
        src/models/notification.h
        src/models/notification.cpp
        src/repositories/interfaces/INotification.h
        src/core/utils/appsettings.h
        src/core/utils/appsettings.cpp
        src/repositories/interfaces/IVerificationRepository.h
        src/application/controllers/verificationcontroller.h src/application/controllers/verificationcontroller.cpp
        src/repositories/impl/verificationrepositoryimpl.h src/repositories/impl/verificationrepositoryimpl.cpp
    RESOURCES
        android/src/com/accofinder/SplashActivity.java
        SOURCES src/application/controllers/disputecontroller.h src/application/controllers/disputecontroller.cpp



)

# ─────────────────────────────────────────────────────────────
# QtJenny generation (only for Android) - MANUAL CONTROL
# ─────────────────────────────────────────────────────────────
set(QTJENNY_GENERATE FALSE CACHE BOOL "Set to TRUE to regenerate QtJenny proxies (requires Gradle)")

set(JENNY_OUTPUT_DIR "")
set(JENNY_GENERATED_SOURCES "")

if(ANDROID)
    message(STATUS ">>> Building for Android - QtJenny support enabled <<<")

    if(QTJENNY_GENERATE)
        message(STATUS ">>> QtJenny generation ENABLED (manual flag) <<<")

        # Check multiple possible locations for qtjenny_generator
        set(POSSIBLE_GENERATOR_DIRS
            "${CMAKE_CURRENT_SOURCE_DIR}/qtjenny_generator"
        )

    set(GENERATOR_DIR "")
    foreach(dir IN LISTS POSSIBLE_GENERATOR_DIRS)
        if(EXISTS "${dir}")
            set(GENERATOR_DIR "${dir}")
            message(STATUS "Found QtJenny generator at: ${GENERATOR_DIR}")
            break()
        endif()
    endforeach()

    if(NOT GENERATOR_DIR)
        message(FATAL_ERROR "QtJenny generator directory not found. Tried: ${POSSIBLE_GENERATOR_DIRS}")
    endif()

    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        set(gradlew_cmd "gradlew.bat")
    else()
        set(gradlew_cmd "./gradlew")
    endif()

    if(NOT EXISTS "${GENERATOR_DIR}/${gradlew_cmd}" AND NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        message(FATAL_ERROR "gradlew not found in ${GENERATOR_DIR}")
    endif()

    set(gradlew_arg "--rerun-tasks")
    set(gradlew_task "kaptReleaseKotlin")
    execute_process(
        COMMAND ${gradlew_cmd} ${gradlew_arg} ${gradlew_task}
        WORKING_DIRECTORY "${GENERATOR_DIR}"
        RESULT_VARIABLE gradle_result
    )
if(NOT gradle_result EQUAL 0)
    message(WARNING "QtJenny generation task failed with code ${gradle_result}. Check Gradle output manually.")
else()
    message(STATUS ">>> QtJenny generation completed successfully <<<")
endif()
else()
    message(STATUS ">>> QtJenny generation SKIPPED (manual flag is FALSE) <<<")
endif()

# Check multiple possible locations for qtjenny_output
set(POSSIBLE_OUTPUT_DIRS
    "${CMAKE_CURRENT_SOURCE_DIR}/qtjenny_output"
)

set(JENNY_OUTPUT_DIR "")
foreach(dir IN LISTS POSSIBLE_OUTPUT_DIRS)
    if(EXISTS "${dir}")
        set(JENNY_OUTPUT_DIR "${dir}/jenny/proxy")
        if(EXISTS "${JENNY_OUTPUT_DIR}")
            message(STATUS "Found QtJenny output at: ${JENNY_OUTPUT_DIR}")
            break()
        endif()
    endif()
endforeach()

if(JENNY_OUTPUT_DIR AND EXISTS "${JENNY_OUTPUT_DIR}")
    file(GLOB JENNY_GENERATED_SOURCES "${JENNY_OUTPUT_DIR}/*.h")
    if(JENNY_GENERATED_SOURCES)
        message(STATUS ">>> Using QtJenny proxies from ${JENNY_OUTPUT_DIR} <<<")
    else()
        message(WARNING "No QtJenny proxy headers found in ${JENNY_OUTPUT_DIR}.")
    endif()
else()
    message(STATUS "QtJenny output directory not found.")
endif()
endif()

# Add generated sources to executable (after definition)
if(JENNY_GENERATED_SOURCES)
    target_sources(appAccoFinder PRIVATE ${JENNY_GENERATED_SOURCES})
endif()

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appAccoFinder PROPERTIES
    #    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appAccoFinder
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
)

target_link_libraries(appAccoFinder
    PRIVATE Qt6::Quick Qt6::Core
)

target_include_directories(appAccoFinder PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Add QtJenny include directory if available
if(JENNY_OUTPUT_DIR AND EXISTS "${JENNY_OUTPUT_DIR}")
    target_include_directories(appAccoFinder PRIVATE ${JENNY_OUTPUT_DIR})
endif()

install(TARGETS appAccoFinder
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Print summary
message(STATUS "========================================")
message(STATUS "Project: ${PROJECT_NAME}")
message(STATUS "Version: ${PROJECT_VERSION}")
if(ANDROID)
    message(STATUS "Platform: Android")
    if(JENNY_GENERATED_SOURCES)
        message(STATUS "QtJenny: Enabled (${JENNY_OUTPUT_DIR})")
    else()
        message(STATUS "QtJenny: Disabled or no sources found")
    endif()
else()
    message(STATUS "Platform: Desktop")
endif()
message(STATUS "Qt version: ${Qt6_VERSION}")
message(STATUS "========================================")