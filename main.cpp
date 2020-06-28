#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScreen>
#include <QFont>

#include "appcore.h"
//#include "qmlmqttclient.h"

int main(int argc, char *argv[])
{

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    AppCore appCore;

    QQmlApplicationEngine engine;

    QFont roboto("Roboto");
//    QApplication::setFont(roboto);

    app.setOrganizationName("Lytko");
    app.setOrganizationDomain("lytko.com");
    app.setApplicationName("Lytko Application");

    QQmlContext *context = engine.rootContext();
    context->setContextProperty("appCore", &appCore);

    const QUrl url(QStringLiteral("qrc:/pages/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
