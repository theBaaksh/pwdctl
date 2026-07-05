cmake_minimum_required(VERSION 3.25)

project(pwdctl VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CORE_DIR "core")
set(3RD_PARTY_DIR "3rd_party")

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick QuickControls2)

add_library(core
    ${CORE_DIR}/TypesDefininitions.h
    ${CORE_DIR}/PasswordCollection.h
    ${CORE_DIR}/FieldError.h

    ${CORE_DIR}/FieldError.cpp
    ${CORE_DIR}/PasswordCollection.cpp
)

add_library(3rd_party INTERFACE)

target_include_directories(3rd_party
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/${3RD_PARTY_DIR}
)

target_include_directories(core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/${CORE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/${3RD_PARTY_DIR}
)

qt_add_executable(yunolock
    include/yunolock/AuthViewModel.h
    src/main.cpp
    src/yunolock/AuthViewModel.cpp
)

qt_add_resources(yunolock app_resources
    PREFIX "/"
    FILES
        qml/Main.qml
        qml/components/AuthScreen.qml
        qml/components/MascotScene.qml
        qml/components/PasswordField.qml
        qml/components/StatusToast.qml
        qml/components/UnlockButton.qml
        resources/images/background.webp
        resources/images/mascot_normal.png
        resources/images/mascot_pout.png
        resources/images/mascot_sad.png
)

target_link_libraries(yunolock
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
)

target_include_directories(yunolock
    PRIVATE
        include
)

enable_testing()

find_package(GTest REQUIRED)

add_executable(core_tests
    test/core/FieldErrorTests.cpp
    test/core/PasswordCollectionTests.cpp
)

target_link_libraries(core_tests
    PRIVATE
        core
        GTest::gtest_main
)

include(GoogleTest)
gtest_discover_tests(core_tests)
