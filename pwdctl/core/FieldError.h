#ifndef FIELD_ERROR_H
#define FIELD_ERROR_H

#include <string>
#include <optional>

namespace pwdctl::core {

class FieldError
{
public:
    FieldError() = default;
    FieldError(const std::string& field, const std::string& error);

    bool isEmpty() const noexcept;
    bool isValid() const noexcept;
    std::optional<std::string> error() const noexcept;
    std::string field() const noexcept;

    void setValue(const std::string& field, const std::string& error);

private:
    std::string field_;
    std::string error_;
};

}

#endif // FIELD_ERROR_H