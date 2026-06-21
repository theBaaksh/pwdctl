#include <algorithm>

#include <gtest/gtest.h>

#include "PasswordCollection.h"
#include "FieldError.h"

TEST(PasswordCollectionTest, AddPasswordEntryTest)
{
    pwdctl::core::PasswordCollection collection;

    const pwdctl::core::AddPasswordEntryCommand addCommand{
        .title = "Google account",
        .username = "user",
        .password = "password",
        .url = "google.com"
    };

    const auto result = collection.addEntry(addCommand);
    ASSERT_TRUE(result.has_value());

    const auto id = result.value();
    EXPECT_FALSE(id.is_nil());

    const auto* entry = collection.entryById(id);
    ASSERT_NE(entry, nullptr);

    EXPECT_EQ(entry->id, id);
    EXPECT_EQ(entry->title, addCommand.title);
    EXPECT_EQ(entry->username, addCommand.username);
    EXPECT_EQ(entry->password, addCommand.password);
    EXPECT_EQ(entry->url, addCommand.url);
    EXPECT_EQ(entry->createdAt, entry->updatedAt);
}

TEST(PasswordCollectionTest, UpdatePasswordEntryTest)
{
    pwdctl::core::PasswordCollection collection;

    const pwdctl::core::AddPasswordEntryCommand addCommand{
        .title = "Google account",
        .username = "old-user",
        .password = "old-password",
        .url = "google.com"
    };

    const auto addResult = collection.addEntry(addCommand);
    ASSERT_TRUE(addResult.has_value());

    const auto id = addResult.value();
    EXPECT_FALSE(id.is_nil());
    const auto* entryBefore = collection.entryById(id);
    ASSERT_NE(entryBefore, nullptr);

    const auto createdAt = entryBefore->createdAt;
    const auto previousUpdatedAt = entryBefore->updatedAt;

    const pwdctl::core::UpdatePasswordEntryCommand updateCommand{
        .title = "Updated Google account",
        .password = "new-password"
    };

    const auto updatedFields = collection.updateEntry(id, updateCommand);

    ASSERT_EQ(updatedFields.size(), 2);
    EXPECT_EQ(updatedFields[0], "title");
    EXPECT_EQ(updatedFields[1], "password");

    const auto* entryAfter = collection.entryById(id);
    ASSERT_NE(entryAfter, nullptr);

    EXPECT_EQ(entryAfter->id, id);
    EXPECT_EQ(entryAfter->title, updateCommand.title.value());
    EXPECT_EQ(entryAfter->password, updateCommand.password.value());

    EXPECT_EQ(entryAfter->username, addCommand.username);
    EXPECT_EQ(entryAfter->url, addCommand.url);
    EXPECT_EQ(entryAfter->createdAt, createdAt);

    EXPECT_GT(entryAfter->updatedAt, previousUpdatedAt);
}

TEST(PasswordCollectionTest, RemovePasswordEntryTest)
{
    pwdctl::core::PasswordCollection collection;

    const pwdctl::core::AddPasswordEntryCommand addCommand{
        .title = "Google account",
        .username = "user",
        .password = "password",
        .url = "google.com"
    };

    const auto result = collection.addEntry(addCommand);
    ASSERT_TRUE(result.has_value());

    const auto id = result.value();
    EXPECT_FALSE(id.is_nil());

    const auto* entry = collection.entryById(id);
    ASSERT_NE(entry, nullptr);

    collection.removeEntry(id);
    EXPECT_EQ(collection.entryById(id), nullptr);
}

TEST(PasswordCollectionTest, ListEntryTest)
{
    pwdctl::core::PasswordCollection collection;

    const pwdctl::core::AddPasswordEntryCommand addCommand1{
        .title = "Google account",
        .username = "user1",
        .password = "password1",
        .url = "google.com"
    };

    const auto result1 = collection.addEntry(addCommand1);
    ASSERT_TRUE(result1.has_value());

    const auto id1 = result1.value();
    EXPECT_FALSE(id1.is_nil());

    const auto* entry1 = collection.entryById(id1);
    ASSERT_NE(entry1, nullptr);

    const pwdctl::core::AddPasswordEntryCommand addCommand2{
        .title = "Google account",
        .username = "user2",
        .password = "password2",
        .url = "google.com"
    };

    const auto result2 = collection.addEntry(addCommand2);
    ASSERT_TRUE(result2.has_value());

    const auto id2 = result2.value();
    EXPECT_FALSE(id2.is_nil());

    const auto* entry2 = collection.entryById(id2);
    ASSERT_NE(entry2, nullptr);

    const auto allEntries = collection.allEntries();
    ASSERT_EQ(allEntries.size(), 2);

    const auto summary1 = std::ranges::find(
        allEntries,
        id1,
        &pwdctl::core::EntrySummary::id
    );

    const auto summary2 = std::ranges::find(
        allEntries,
        id2,
        &pwdctl::core::EntrySummary::id
    );

    ASSERT_NE(summary1, allEntries.end());
    ASSERT_NE(summary2, allEntries.end());

    EXPECT_EQ(summary1->title, addCommand1.title);
    EXPECT_EQ(summary1->username, addCommand1.username);
    EXPECT_EQ(summary1->url, addCommand1.url);
    EXPECT_EQ(summary1->updatedAt, entry1->updatedAt);

    EXPECT_EQ(summary2->title, addCommand2.title);
    EXPECT_EQ(summary2->username, addCommand2.username);
    EXPECT_EQ(summary2->url, addCommand2.url);
    EXPECT_EQ(summary2->updatedAt, entry2->updatedAt);
}