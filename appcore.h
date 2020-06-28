#ifndef APPCORE_H
#define APPCORE_H

#include <QObject>
#include <QVariantMap>

class QMqttClient;
class QMqttSubscription;

class AppCore : public QObject
{
    Q_OBJECT
public:
    explicit AppCore(QObject *parent = nullptr);

signals:
    void changeFooter(bool status);
    void changeFooterZoneId(int currentZoneId);
    void changeDeviceData(int zoneId, int currentRoomSwipeIndex);
    void changeActivePage(QString pageName);

    void changePopupData(QString idDevice, QString zoneId, QString name, QString targetTemp, QString currentTemp, QString hState, QString relay);
    void changeActiveRoom(int zoneId);
    void changeRoomManageData(QString devicesList, QString roomsList);
    void changeRoomsManageMode(bool addNewRoom);

    void topicChanged(QString topic, QString msg);
    void mqttConnected();
    void mqttStatusUpdate(QString status);

public slots:
    void setMqttConnection(QString host, QString port, QString user, QString password);
    void sendMqttMessage(QString topic, QString msg);

    void setPopupData(QString idDevice, QString zoneId, QString name, QString targetTemp, QString currentTemp, QString hState, QString relay);
    void setFooter(bool status);
    void setFooterZoneId(int currentZoneId);

    void setActivePage(QString pageName);

    void setActiveRoom(int zoneId);
    QString getDevicesList() {return p_devicesList;};
    QString getRoomsList() {return p_roomsList;};

    QVariantMap getTopics();

private:
    QMqttClient *mqtt;
    QMqttSubscription *s;

    QString p_user;

    QString p_devicesList;
    QString p_roomsList;

    QVariantMap *topics;
};

#endif // APPCORE_H
