#ifndef PASSWORD_ENTIES
#define PASSWORD_ENTIES

#include <vector>
#include <unordered_map>
#include <string>
#include <optional>

#include "TypesDefininitions.h"

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
    Date createdAt;
    Date updatedAt;

bool operator==(const PasswordEntry& other) const {
    return id   == other.id &&
           title == other.title &&
           username == other.username &&
           url == other.url;
}
};

class PasswordCollection {

public:
    PasswordCollection() = default;
    ~PasswordCollection() = default;

    EntryId addEntry(const AddPasswordEntryCommand& command) noexcept;
    void removeEntry(const EntryId& id) noexcept;
    bool updateEntry(const EntryId& id, const UpdatePasswordEntryCommand& command) noexcept;

    [[nodiscard]]
    const PasswordEntry* entryById(const EntryId& id) const noexcept;  
    const std::vector<PasswordEntry> allEntries() const noexcept;

private:
    bool isPasswordEntryValid(const PasswordEntry& entry);

private:
    std::unordered_map<EntryId, PasswordEntry> pwdEntries_;
};

}

#endif // #ifndef PASSWORD_ENTIES