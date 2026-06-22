#include "FieldError.h"

namespace pwdctl::core {

FieldError::FieldError(const std::string &field, const std::string &error)
    : field_(field)
    , error_(error)
{}

bool FieldError::isEmpty() const noexcept
{
    return error_.empty();
}

bool FieldError::isValid() const noexcept
{
    return !error_.empty() && !field_.empty();
}

std::optional<std::string> FieldError::error() const noexcept
{
    if (!isEmpty()) {
        return error_;
    }

    return std::nullopt;
}

std::string FieldError::field() const noexcept
{
    return field_;
}

void FieldError::setValue(const std::string &field, const std::string &error)
{
    field_ = field;
    error_ = error;
}

} // namespace pwdctl::core