#include <gtest/gtest.h>

#include <string>

#include "FieldError.h"

TEST(FieldErrorTest, DefaultConstructedErrorIsEmpty)
{
    const pwdctl::core::FieldError fieldError;

    EXPECT_TRUE(fieldError.isEmpty());
    EXPECT_FALSE(fieldError.isValid());
    EXPECT_FALSE(fieldError.error().has_value());
    EXPECT_EQ(fieldError.field(), "");
}

TEST(FieldErrorTest, GeneralConstructorErrorIsValid)
{
    const std::string field = "user";
    const std::string error = "field 'user' could not be empty";
    const pwdctl::core::FieldError fieldError(field, error);
    
    EXPECT_FALSE(fieldError.isEmpty());
    EXPECT_TRUE(fieldError.isValid());
    ASSERT_TRUE(fieldError.error().has_value());    
    EXPECT_EQ(fieldError.error().value(), error);
    EXPECT_EQ(fieldError.field(), field);
}

TEST(FieldErrorTest, ConstructorWithEmptyFieldIsInvalid)
{
    const std::string error = "Field 'user' could not be empty";
    const pwdctl::core::FieldError fieldError("", error);

    EXPECT_FALSE(fieldError.isEmpty());
    EXPECT_FALSE(fieldError.isValid());
    ASSERT_TRUE(fieldError.error().has_value());
    EXPECT_EQ(fieldError.error().value(), error);
    EXPECT_EQ(fieldError.field(), "");
}

TEST(FieldErrorTest, ConstructorWithEmptyErrorIsEmptyAndInvalid)
{
    const std::string field = "user";
    const pwdctl::core::FieldError fieldError(field, "");

    EXPECT_TRUE(fieldError.isEmpty());
    EXPECT_FALSE(fieldError.isValid());
    EXPECT_FALSE(fieldError.error().has_value());
    EXPECT_EQ(fieldError.field(), field);
}

TEST(FieldErrorTest, SetValueMakesErrorValid)
{
    const std::string field = "password";
    const std::string error = "Password must not be empty";
    pwdctl::core::FieldError fieldError;

    fieldError.setValue(field, error);

    EXPECT_FALSE(fieldError.isEmpty());
    EXPECT_TRUE(fieldError.isValid());
    ASSERT_TRUE(fieldError.error().has_value());
    EXPECT_EQ(fieldError.error().value(), error);
    EXPECT_EQ(fieldError.field(), field);
}

TEST(FieldErrorTest, SetValueOverwritesPreviousValue)
{
    const std::string field = "url";
    const std::string error = "URL is invalid";
    pwdctl::core::FieldError fieldError("title", "Title must not be empty");

    fieldError.setValue(field, error);

    EXPECT_FALSE(fieldError.isEmpty());
    EXPECT_TRUE(fieldError.isValid());
    ASSERT_TRUE(fieldError.error().has_value());
    EXPECT_EQ(fieldError.error().value(), error);
    EXPECT_EQ(fieldError.field(), field);
}

TEST(FieldErrorTest, SetValueCanClearError)
{
    const std::string field = "title";
    pwdctl::core::FieldError fieldError(field, "Title must not be empty");

    fieldError.setValue(field, "");

    EXPECT_TRUE(fieldError.isEmpty());
    EXPECT_FALSE(fieldError.isValid());
    EXPECT_FALSE(fieldError.error().has_value());
    EXPECT_EQ(fieldError.field(), field);
}
