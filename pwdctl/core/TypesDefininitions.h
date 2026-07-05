#ifndef TYPES_DEFINITIONS_H
#define TYPES_DEFINITIONS_H

#include <string>

#include "uuid.h"

namespace pwdctl::core {
    using EntryId = uuids::uuid;
    using Timestamp = std::int64_t;
}

#endif // TYPES_DEFINITIONS_H
