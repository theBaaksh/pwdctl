#include "PasswordCollection.h"

namespace pwdctl::core
{

bool pwdctl::core::PasswordCollection::isPasswordEntryValid(const PasswordEntry& entry) {
    return !entry.id.empty() &&
            !entry.title.empty() &&
            !entry.username.empty() &&
            !entry.password.empty();
}
    
EntryId PasswordCollection::addEntry(const AddPasswordEntryCommand &command) noexcept
{
    // TODO: validate

    PasswordEntry entry;
    entry.id        = ""; //TODO: genrate ID
    entry.title     = command.title;
    entry.username  = command.username;
    entry.password  = command.password;
    entry.url       = command.url;
    entry.createdAt = Date(); //TODO: fill day today
    entry.updatedAt = Date(); //TODO: fill day today

    auto id = entry.id;
    pwdEntries_.emplace(id, std::move(entry));

    return id;
}

void pwdctl::core::PasswordCollection::removeEntry(const EntryId &id) noexcept
{
    if (id.empty()) return;

    const auto it = pwdEntries_.find(id);
    if (it != pwdEntries_.end()) {
        pwdEntries_.erase(it);
    }
}

bool PasswordCollection::updateEntry(const EntryId &id, const UpdatePasswordEntryCommand &command) noexcept
{
    // TODO: validate

    auto it = pwdEntries_.find(id);
    if (it == pwdEntries_.end()) {
        return false;
    }
    
    auto& targetEntry = it->second;

    // TODO: make method

    return true;
}

const PasswordEntry* pwdctl::core::PasswordCollection::entryById(const EntryId &id) const noexcept
{
    if (id.empty()) return nullptr;

    const auto it = pwdEntries_.find(id);
    if (it == pwdEntries_.end()) {
        return nullptr;
    }

    return &it->second;
}

const std::vector<PasswordEntry> pwdctl::core::PasswordCollection::allEntries() const noexcept
{
    std::vector<PasswordEntry> entries;
    entries.reserve(pwdEntries_.size());

    for (const auto& entryItem : pwdEntries_) {
        entries.push_back(entryItem.second);
    }

    return entries;
}

} // namespace pwdctl::core