#include "AuthViewModel.h"

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
    return m_isUnlocking;
}

QString AuthViewModel::errorText() const
{
    return m_errorText;
}

int AuthViewModel::failedAttempts() const
{
    return m_failedAttempts;
}

QString AuthViewModel::feedbackCode() const
{
    return m_feedbackCode;
}

bool AuthViewModel::capsLockActive() const
{
    return m_capsLockActive;
}

void AuthViewModel::unlock(const QString &masterPassword)
{
    if (m_isUnlocking) {
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
        setFailedAttempts(m_failedAttempts + 1);
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
    if (m_capsLockActive == active) {
        return;
    }

    m_capsLockActive = active;
    emit capsLockActiveChanged();
}

void AuthViewModel::setIsUnlocking(bool isUnlocking)
{
    if (m_isUnlocking == isUnlocking) {
        return;
    }

    m_isUnlocking = isUnlocking;
    emit isUnlockingChanged();
}

void AuthViewModel::setErrorText(const QString &errorText)
{
    if (m_errorText == errorText) {
        return;
    }

    m_errorText = errorText;
    emit errorTextChanged();
}

void AuthViewModel::setFeedbackCode(const QString &feedbackCode)
{
    if (m_feedbackCode == feedbackCode) {
        return;
    }

    m_feedbackCode = feedbackCode;
    emit feedbackCodeChanged();
}

void AuthViewModel::setFailedAttempts(int failedAttempts)
{
    if (m_failedAttempts == failedAttempts) {
        return;
    }

    m_failedAttempts = failedAttempts;
    emit failedAttemptsChanged();
}
