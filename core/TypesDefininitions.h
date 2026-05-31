#ifndef TYPES_DEFINITIONS
#define TYPES_DEFINITIONS

#include <string>
#include <filesystem>

namespace pwdctl::core {
    using EntryId = std::string;
    using VaultPath = std::filesystem::path;
    using Date = std::int64_t;    
}

#endif // TYPES_DEFINITIONS