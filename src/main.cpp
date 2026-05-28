#include "AuthViewModel.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("YunoLock"));
    QGuiApplication::setOrganizationName(QStringLiteral("YunoLock"));

    QQuickStyle::setStyle(QStringLiteral("Basic"));

    AuthViewModel authViewModel;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("authViewModel"), &authViewModel);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));

    return app.exec();
}
