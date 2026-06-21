#include "PasswordCollection.h"


#include "Utils.h"

namespace pwdctl::core
{

namespace {
    std::vector<FieldError> validateAddPasswordEntry(const AddPasswordEntryCommand& command) noexcept {

        std::vector<FieldError> errors;

        if (command.title.empty()) {
            errors.emplace_back("title", "Title must not be empty");
        }

        if (command.username.empty()) {
            errors.emplace_back("username", "Username must not be empty");
        }

        if (command.password.empty()) {
            errors.emplace_back("password", "Password must not be empty");
        }

        return errors;
    }

    bool updateIfNotNull(std::string& targetStr, const std::optional<std::string>& newStr) {
        if (newStr) {
            targetStr = newStr.value();
            return true;
        }

        return false;
    }
}

std::expected<EntryId, std::vector<FieldError>> PasswordCollection::addEntry(const AddPasswordEntryCommand& command) noexcept{

    const auto errors = validateAddPasswordEntry(command);
    if (!errors.empty()) return std::unexpected(errors);

    PasswordEntry entry;
    entry.id        = utils::generateId();
    entry.title     = command.title;
    entry.username  = command.username;
    entry.password  = command.password;
    entry.url       = command.url;

    const Timestamp timestamp = utils::currentTimestampMs();
    entry.createdAt = timestamp;
    entry.updatedAt = timestamp;

    auto id = entry.id;
    pwdEntries_.emplace(id, std::move(entry));

    return id;
}

void pwdctl::core::PasswordCollection::removeEntry(const EntryId &id) noexcept
{
    if (id.is_nil()) return;

    const auto it = pwdEntries_.find(id);
    if (it == pwdEntries_.end()) {
        return;
    }

    pwdEntries_.erase(it);
}

std::vector<std::string> PasswordCollection::updateEntry(const EntryId &id, 
    const UpdatePasswordEntryCommand &command) noexcept
{
    auto it = pwdEntries_.find(id);
    if (it == pwdEntries_.end()) {
        return {};
    }
    
    auto& targetEntry = it->second;
    std::vector<std::string> updatedFields;

    if (updateIfNotNull(targetEntry.title, command.title)) {
        updatedFields.push_back("title");
    }

    if (updateIfNotNull(targetEntry.username, command.username)) {
        updatedFields.push_back("username");
    }

    if (updateIfNotNull(targetEntry.password, command.password)) {
        updatedFields.push_back("password");
    }

    if (updateIfNotNull(targetEntry.url, command.url)) {
        updatedFields.push_back("url");
    }

    if (updatedFields.size()) {
        targetEntry.updatedAt = utils::currentTimestampMs();
    }

    return updatedFields;
}

const PasswordEntry* pwdctl::core::PasswordCollection::entryById(const EntryId &id) const noexcept
{
    if (id.is_nil()) return nullptr;

    const auto it = pwdEntries_.find(id);
    if (it == pwdEntries_.end()) {
        return nullptr;
    }

    return &it->second;
}

std::vector<EntrySummary> pwdctl::core::PasswordCollection::allEntries() const noexcept
{
    std::vector<EntrySummary> summaries;
    summaries.reserve(pwdEntries_.size());

    for (const auto& entryItem : pwdEntries_) {
        const auto& entry = entryItem.second; 

        EntrySummary summary {
            .id = entry.id,
            .title = entry.title,
            .username = entry.username,
            .url = entry.url,
            .updatedAt = entry.updatedAt
        };

        summaries.push_back(std::move(summary));
    }

    return summaries;
}

} // namespace pwdctl::core