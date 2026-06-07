#ifndef PASSWORD_ENTIES_H
#define PASSWORD_ENTIES_H

#include <vector>
#include <unordered_map>
#include <string>
#include <optional>
#include <expected>

#include "TypesDefininitions.h"
#include "FieldError.h"

namespace pwdctl::core {

struct AddPasswordEntryCommand {
    std::string title;
    std::string username;
    std::string password;
    std::string url;
};

struct UpdatePasswordEntryCommand {
    std::optional<std::string> title;
    std::optional<std::string> username;
    std::optional<std::string> password;
    std::optional<std::string> url;
};

struct PasswordEntry
{
    EntryId id;
    std::string title;
    std::string username;
    std::string password;
    std::string url;
    Timestamp createdAt;
    Timestamp updatedAt;

bool operator==(const PasswordEntry& other) const {
    return id   == other.id &&
           title == other.title &&
           username == other.username &&
           url == other.url;
}
};

struct EntrySummary {
    std::string title;
    std::string username;
    std::string url;
    Timestamp updatedAt;
};

class PasswordCollection {

public:
    PasswordCollection() = default;
    ~PasswordCollection() = default;

    std::expected<EntryId, std::vector<FieldError>> addEntry(const AddPasswordEntryCommand& command) noexcept;
    void removeEntry(const EntryId& id) noexcept;
    std::vector<std::string> updateEntry(const EntryId& id, 
        const UpdatePasswordEntryCommand& command) noexcept;

    [[nodiscard]]
    const PasswordEntry* entryById(const EntryId& id) const noexcept;  
    const std::vector<EntrySummary> allEntries() const noexcept;

private:
    std::unordered_map<EntryId, PasswordEntry> pwdEntries_;
};

}

#endif // PASSWORD_ENTIES_H