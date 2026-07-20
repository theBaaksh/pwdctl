include_guard(GLOBAL)

find_package(GTest REQUIRED)

get_filename_component(PWDCTL_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(PWDCTL_TESTS_DIR "${PWDCTL_ROOT_DIR}/tests")

add_executable(pwdctl_core_tests
    "${PWDCTL_TESTS_DIR}/core/FieldErrorTests.cpp"
    "${PWDCTL_TESTS_DIR}/core/PasswordCollectionTests.cpp"
)

target_link_libraries(pwdctl_core_tests
    PRIVATE
        core
        GTest::gtest_main
)

include(GoogleTest)
gtest_discover_tests(pwdctl_core_tests)
