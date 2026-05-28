#pragma once

#include <QObject>
#include <QString>

class AuthViewModel final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString vaultName READ vaultName CONSTANT)
    Q_PROPERTY(bool isUnlocking READ isUnlocking NOTIFY isUnlockingChanged)
    Q_PROPERTY(QString errorText READ errorText NOTIFY errorTextChanged)
    Q_PROPERTY(int failedAttempts READ failedAttempts NOTIFY failedAttemptsChanged)
    Q_PROPERTY(QString feedbackCode READ feedbackCode NOTIFY feedbackCodeChanged)
    Q_PROPERTY(bool capsLockActive READ capsLockActive WRITE setCapsLockActive NOTIFY capsLockActiveChanged)

public:
    explicit AuthViewModel(QObject *parent = nullptr);

    QString vaultName() const;
    bool isUnlocking() const;
    QString errorText() const;
    int failedAttempts() const;
    QString feedbackCode() const;
    bool capsLockActive() const;

    Q_INVOKABLE void unlock(const QString &masterPassword);
    Q_INVOKABLE void clearError();

public slots:
    void setCapsLockActive(bool active);

signals:
    void isUnlockingChanged();
    void errorTextChanged();
    void failedAttemptsChanged();
    void feedbackCodeChanged();
    void capsLockActiveChanged();
    void unlockSucceeded();
    void unlockFailed(const QString &reason);

private:
    void setIsUnlocking(bool isUnlocking);
    void setErrorText(const QString &errorText);
    void setFeedbackCode(const QString &feedbackCode);
    void setFailedAttempts(int failedAttempts);

    bool m_isUnlocking = false;
    bool m_capsLockActive = false;
    int m_failedAttempts = 0;
    QString m_errorText;
    QString m_feedbackCode;
};
