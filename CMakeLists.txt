cmake_minimum_required(VERSION 3.25)

project(pwdctl LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CORE_DIR "core")

add_library(core
    ${CORE_DIR}/TypesDefininitions.h
    ${CORE_DIR}/PasswordCollection.h
    ${CORE_DIR}/FieldError.h
    
    ${CORE_DIR}/FieldError.cpp
    ${CORE_DIR}/PasswordCollection.cpp
    
)

target_include_directories(core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/${CORE_DIR}
)
