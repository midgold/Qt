import QtQuick 2.0
import Qt.labs.settings 1.0

import "../js/styles.js" as Styles

Item {

    id: handlerMqttId

    function saveDevicesAndRooms(devicesArrJson, roomsArrJson) {
        storage.setValue("devicesArrJson", devicesArrJson)
        storage.setValue("roomsArrJson", roomsArrJson)
        storage.sync()
    }

    function createTimer() {
        return Qt.createQmlObject("import QtQuick 2.0; Timer {}", handlerMqttId);
    }

    Settings {
        id: storage
    }

    property string activePageName: ""

    Component.onCompleted: {

        let timer = createTimer();

        timer.interval = 60000;
        timer.repeat = true;
        timer.triggered.connect(function () {
            let devicesArr;
            try {
                devicesArr = JSON.parse(storage.value("devicesArrJson"));
            } catch(e) {
                devicesArr = []
            }

            for(let i = 0; i < devicesArr.length; i++) {

                let delta = new Date().getTime() - parseInt(devicesArr[i].lastMsg)
                console.log("devicesArr[i].lastMsg " + devicesArr[i].lastMsg)

                if(delta > 60000) {
                    // удалить устройство, если данные с него не пришли в течение минуты
                    devicesArr.splice(i, 1)
                    console.log(JSON.stringify(devicesArr))
                    storage.setValue("devicesArrJson", JSON.stringify(devicesArr))

                    if(activePageName === "rooms") {
                        // отображение нулевой комнаты, чтобы не вводить пользователя в заблуждение внезапным свайпом
                        appCore.setActiveRoom(0)
                        appCore.setFooterZoneId(0)
                        swipe.currentIndex = 0
                    }
                }
            }
        })
        timer.start();
    }

    Connections {
        target: appCore

        onChangeActivePage: {
            activePageName = pageName
        }

        onTopicChanged: {
            console.log("topic " + topic + " msg" + msg);

            let parsingData;

            let topicSplit = [];
            topicSplit = topic.split('/');

            try {
                parsingData = JSON.parse(msg).update;
            } catch(err) {

            }

            // Сохранение Wi-Fi помещено тут, потому что сети отправляются из контроллера 1 раз
            // MQTT топики разделяются для того, чтобы отрегировать на данные, приходящие в топики Wifi,
            // получить объект текущего WiFi и массив достепных WiFi

            let wifiTopic = topicSplit[1];

            if(wifiTopic === "currentWifi") {
                storage.setValue("currentWifi", msg)
                storage.sync()
            }
            else if(wifiTopic === "scanWifi") {
                storage.setValue("scanWifi", msg)
                storage.sync()
            }

            // MQTT топики разделяются для того, чтобы отрегировать на данные, приходящие в топике data,
            // получить zoneId, id, тип устройства
            // и записать эти данные в модель устройства

            let zoneIdFromTopic = parseInt(topicSplit[1]);
            let typeFromTopic = topicSplit[2];
            let idDeviceFromTopic = topicSplit[3];
            let manageTopic = topicSplit[4];

            let roomsArr = []
            let devicesArr = []

            roomsArr = JSON.parse(storage.value("roomsArrJson"))

            // на случай первого запуска, когда нет устройств
            try {
                devicesArr = JSON.parse(storage.value("devicesArrJson"))
            } catch(e) {
                devicesArr = []
            }

            if(manageTopic === "data") {

                let managedData, managedTemp, managedRelay, managedHeating, managedUnit, managedCoeff;

                managedData = typeFromTopic === "thermostat" ? parsingData.target_temp : parsingData.data
                managedTemp = typeFromTopic === "thermostat" ? parsingData.temp : ""
                managedRelay = typeFromTopic === "thermostat" ? parsingData.relay : ""
                managedHeating = typeFromTopic === "thermostat" ? parsingData.heating : false
                managedUnit = parsingData.unit === "Celsius" | parsingData.unit === undefined  ? "" : "" + parsingData.unit
                managedCoeff = typeFromTopic === "pressure" ? parseFloat(0.4) : 1

                let nowTime = new Date().getTime()

                let deviceObject = {
                    "idDevice": idDeviceFromTopic,
                    "zoneId": parseInt(zoneIdFromTopic),
                    "data": parseInt(managedData),
                    "temp": managedTemp,
                    "type": typeFromTopic,
                    "name": parsingData.name,
                    "relay": managedRelay,
                    "hState": managedHeating,
                    "lastMsg": nowTime,
                    "state": false, // для переключателей
                    "sizeCoefficient": managedCoeff,  // для размера шрифта данных
                    "unit": managedUnit,  // единицы измерения данных сенсоров
                    "version": "07_14", // для обновлений. Добавится в будущем
                    "isUpdate": false  // для обновлений. Добавится в будущем
                };

                let roomObject = {
                    "zoneId": parseInt(zoneIdFromTopic),
                    "roomName": "Room " + zoneIdFromTopic.toString(),
                    "iconId": 0 // по умолчанию присвоить сощзданной через MQTT комнату иконку кровати
                }

                let isExistRoom = false
                let isExistDevice = false;

                for(let i = 0; i < roomsArr.length; i++) {
                    if(parseInt(roomsArr[i].zoneId) === parseInt(zoneIdFromTopic)) {
                        isExistRoom = true
                    }
                }

                if(isExistRoom) {
                    for(let p = 0; p < devicesArr.length; p++)
                    {
                        // Обновление данных устройства для перезаписи массива с устройствами в память телефона
                        if(devicesArr[p].idDevice === idDeviceFromTopic) {

                            let foundedDevice = devicesArr[p];
                            foundedDevice.data = managedData;
                            foundedDevice.temp = managedTemp;
                            foundedDevice.hState = managedHeating;
                            foundedDevice.relay = managedRelay;
                            foundedDevice.name = parsingData.name;
                            foundedDevice.lastMsg = deviceObject.lastMsg;

                            appCore.setPopupData(foundedDevice.idDevice, parseInt(foundedDevice.zoneId), foundedDevice.name,
                                                 foundedDevice.data, foundedDevice.temp, foundedDevice.hState, foundedDevice.relay);

                            isExistDevice = true
                            devicesArr[p] = foundedDevice;

                            for(let y = 0; y < roomsArr.length; y++) {
                                if(activePageName === "rooms") {
                                    if(zoneIdFromTopic === parseInt(roomsArr[swipe.currentIndex].zoneId)) {
                                        // отображение обновленной комнаты, соответствующей той, что открыта перед пользователем
                                        saveDevicesAndRooms(JSON.stringify(devicesArr), JSON.stringify(roomsArr)); // сохранить для отображения
                                        appCore.setActiveRoom(parseInt(zoneIdFromTopic)) // отображение добавленной комнаты
                                        appCore.setFooterZoneId(parseInt(zoneIdFromTopic)) // отображение иконки добавленной комнаты
                                    }
                                }
                            }
                            // сохранить для отображения, когда пользователь на какой-либо странице, кроме rooms
                            saveDevicesAndRooms(JSON.stringify(devicesArr), JSON.stringify(roomsArr));
                        }
                    }

                    if (!isExistDevice)
                    {
                        devicesArr.push(deviceObject); // добавление в массив новых устройств с их данными для записи в память телефона

                        for(let y = 0; y < roomsArr.length; y++) {
                            if(activePageName === "rooms") {
                                if(zoneIdFromTopic === parseInt(roomsArr[swipe.currentIndex].zoneId) & swipe.currentIndex != -1) {
                                    // отображение обновленной комнаты, соответствующей той, что открыта перед пользователем
                                    saveDevicesAndRooms(JSON.stringify(devicesArr), JSON.stringify(roomsArr)); // сохранить для отображения
                                    appCore.setActiveRoom(parseInt(zoneIdFromTopic)) // отображение добавленной комнаты
                                    appCore.setFooterZoneId(parseInt(zoneIdFromTopic)) // отображение иконки добавленной комнаты
                                }
                            }
                        }
                        // сохранить для отображения, когда пользователь на какой-либо странице, кроме rooms
                        saveDevicesAndRooms(JSON.stringify(devicesArr), JSON.stringify(roomsArr));
                    }
                }
                else
                {
                    roomsArr.push(roomObject); // добавление в массив новых комнат, полученных из MQTT, для записи в память телефона
                    rooms.roomsCount = roomsArr.length

                    devicesArr.push(deviceObject);

                    saveDevicesAndRooms(JSON.stringify(devicesArr), JSON.stringify(roomsArr)); // сохранить для отображения

                    // отображение нулевой комнаты, чтобы не вводить пользователя в заблуждение внезапным свайпом
                    appCore.setActiveRoom(0)
                    appCore.setFooterZoneId(0)
                }
            }

            saveDevicesAndRooms(JSON.stringify(devicesArr), JSON.stringify(roomsArr));
        }
    }
}
