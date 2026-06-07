#ifndef TYPES_DEFINITIONS_H
#define TYPES_DEFINITIONS_H

#include <string>

#define UUID_SYSTEM_GENERATOR
#include "uuid.h"

namespace pwdctl::core {
    using EntryId = uuids::uuid;
    using Timestamp = std::int64_t;
}

#endif // TYPES_DEFINITIONS_H