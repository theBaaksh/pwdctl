cmake_minimum_required(VERSION 3.25)

project(yunolock VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick QuickControls2)

qt_add_executable(${PROJECT_NAME}
    AuthViewModel.h
    main.cpp
    AuthViewModel.cpp
)

qt_add_resources(${PROJECT_NAME} app_resources
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

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
)
