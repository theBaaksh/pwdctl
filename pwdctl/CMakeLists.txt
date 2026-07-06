cmake_minimum_required(VERSION 3.25)

project(pwdctl VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(PWDCTL_BUILD_TESTS "Build pwdctl tests" OFF)

set(CORE_DIR "core")
set(3RD_PARTY_DIR "3rd_party")

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

if(PWDCTL_BUILD_TESTS)
    enable_testing()
    include("${CMAKE_CURRENT_LIST_DIR}/cmake/PwdctlTests.cmake")
endif()
