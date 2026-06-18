#include <yunolock/AuthViewModel.h>

#include <QTimer>

AuthViewModel::AuthViewModel(QObject *parent)
    : QObject(parent)
{
}

QString AuthViewModel::vaultName() const
{
    return QStringLiteral("Личное защищенное хранилище");
}

bool AuthViewModel::isUnlocking() const
{
    return isUnlocking_;
}

QString AuthViewModel::errorText() const
{
    return errorText_;
}

int AuthViewModel::failedAttempts() const
{
    return failedAttempts_;
}

QString AuthViewModel::feedbackCode() const
{
    return feedbackCode_;
}

bool AuthViewModel::capsLockActive() const
{
    return capsLockActive_;
}

void AuthViewModel::unlock(const QString &masterPassword)
{
    if (isUnlocking_) {
        return;
    }

    if (masterPassword.isEmpty()) {
        const auto code = QStringLiteral("empty_password");
        setErrorText({});
        setFeedbackCode(code);
        emit unlockFailed(code);
        return;
    }

    setErrorText({});
    setFeedbackCode({});
    setIsUnlocking(true);

    QTimer::singleShot(700, this, [this, masterPassword]() {
        setIsUnlocking(false);

        if (masterPassword == QStringLiteral("sakura")) {
            setFailedAttempts(0);
            setFeedbackCode(QStringLiteral("success"));
            emit unlockSucceeded();
            return;
        }

        const auto code = QStringLiteral("wrong_password");
        setFailedAttempts(failedAttempts_ + 1);
        setErrorText({});
        setFeedbackCode(code);
        emit unlockFailed(code);
    });
}

void AuthViewModel::clearError()
{
    setErrorText({});
    setFeedbackCode({});
}

void AuthViewModel::setCapsLockActive(bool active)
{
    if (capsLockActive_ == active) {
        return;
    }

    capsLockActive_ = active;
    emit capsLockActiveChanged();
}

void AuthViewModel::setIsUnlocking(bool isUnlocking)
{
    if (isUnlocking_ == isUnlocking) {
        return;
    }

    isUnlocking_ = isUnlocking;
    emit isUnlockingChanged();
}

void AuthViewModel::setErrorText(const QString &errorText)
{
    if (errorText_ == errorText) {
        return;
    }

    errorText_ = errorText;
    emit errorTextChanged();
}

void AuthViewModel::setFeedbackCode(const QString &feedbackCode)
{
    if (feedbackCode_ == feedbackCode) {
        return;
    }

    feedbackCode_ = feedbackCode;
    emit feedbackCodeChanged();
}

void AuthViewModel::setFailedAttempts(int failedAttempts)
{
    if (failedAttempts_ == failedAttempts) {
        return;
    }

    failedAttempts_ = failedAttempts;
    emit failedAttemptsChanged();
}
