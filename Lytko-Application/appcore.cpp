#include "appcore.h"

#include <QMqttClient>
#include <QSettings>

AppCore::AppCore(QObject *parent)
    : QObject(parent)
    , mqtt(new QMqttClient(this))
    , topics(new QVariantMap)
{}

void AppCore::setFooter(bool status)
{
    emit changeFooter(status);
}

void AppCore::setFooterZoneId(int currentZoneId)
{
    emit changeFooterZoneId(currentZoneId);
}

void AppCore::setPopupData(QString idDevice, QString zoneId, QString name, QString targetTemp, QString currentTemp, QString hState, QString relay)
{
    emit changePopupData(idDevice, zoneId, name, targetTemp, currentTemp, hState, relay);
}

void AppCore::setActiveRoom(int zoneId)
{
    emit changeActiveRoom(zoneId);
}

void AppCore::setActivePage(QString pageName)
{
    emit changeActivePage(pageName);
}

QVariantMap AppCore::getTopics()
{
    return *topics;
}

void AppCore::setMqttConnection(QString host, QString port, QString user, QString password)
{
    mqtt->disconnectFromHost();
    mqtt->setHostname(host);
    mqtt->setPort(port.toUShort());
    mqtt->setUsername(user);
    mqtt->setPassword(password);
    mqtt->connectToHost();
    p_user = user;

    connect(mqtt, &QMqttClient::stateChanged, [this, user, host](QMqttClient::ClientState state)
    {

        if (state == QMqttClient::ClientState::Connected)
        {
            QSettings storage;
            storage.setValue("mqttIsConnected", true);
            emit mqttStatusUpdate("NoError");
            qDebug() << "MQTT Connected";
            emit mqttConnected();

            QString withoutUser = host;

            connect(mqtt->subscribe(user+"/#"), &QMqttSubscription::messageReceived,
                    [this, user](QMqttMessage msg)
            {
                QString topic = msg.topic().name().remove(0, user.length()+1);
                emit topicChanged(topic, msg.payload());
                topics->insert(topic, msg.payload());
            });

        }
        else if (state == QMqttClient::ClientState::Disconnected)
        {
            QSettings storage;
            storage.setValue("mqttIsConnected", false);
            emit mqttStatusUpdate("Disconnected");
        }
    });

    connect(mqtt, &QMqttClient::errorChanged, [this](QMqttClient::ClientError error)
    {
        static const QMap<int, QString> list =
        {
            {0, tr("NoError")},
            {1, tr("InvalidProtocolVersion")},
            {2, tr("IdRejected")},
            {3, tr("ServerUnavailable")},
            {4, tr("BadUsernameOrPassword")},
            {5, tr("NotAuthorized")},
            // Qt states
            {256, tr("TransportInvalid")},
            {257, tr("ProtocolViolation")},
            {258, tr("UnknownError")},
            {259, tr("Mqtt5SpecificError")}
        };

        QSettings storage;
        if(error == QMqttClient::NotAuthorized) {
            storage.setValue("mqttIsConnected", false);
            emit mqttStatusUpdate(list.value(error));
        }
        qDebug() << error;
    });

}

void AppCore::sendMqttMessage(QString topic, QString msg)
{
    mqtt->publish(QMqttTopicName(p_user+"/"+topic), msg.toUtf8(), 0, false);
}
