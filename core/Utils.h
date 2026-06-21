#ifndef UTILS_H
#define UTILS_H

#include <chrono>
#include <format>
#include <random>
#include <string>

#include "TypesDefininitions.h"

namespace pwdctl::core::utils {

inline Timestamp currentTimestampMs()
{
    return std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::system_clock::now().time_since_epoch()
    ).count();
}

inline std::string timestampToString(Timestamp timestampMs)
{
    using namespace std::chrono;

    auto tp = system_clock::time_point{milliseconds{timestampMs}};

    return std::format("{:%d.%m.%Y %H:%M:%S}", tp);
}

inline EntryId generateId()
{
    static thread_local std::mt19937 engine{std::random_device{}()};
    return uuids::uuid_random_generator{engine}();
}

} 

#endif // UTILS_H 
