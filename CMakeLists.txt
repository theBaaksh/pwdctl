cmake_minimum_required(VERSION 3.25)

project(pwdctl VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(PWDCTL_BUILD_YUNOLOCK "Build YunoLock desktop application" ON)

include(CTest)

add_subdirectory(pwdctl)

if(PWDCTL_BUILD_YUNOLOCK)
    add_subdirectory(application/desktop/yunolock)
endif()
