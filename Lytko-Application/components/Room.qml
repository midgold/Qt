import QtQuick 2.2
import QtQuick.Controls 2.12
import Qt.labs.settings 1.0

import "../components"
import "qrc:/js/styles.js" as Styles

Grid {
    id: grid

    Settings {
        id: storage
    }

    property var roomContentArr: []
    property var roomsArr: []
    property var devicesArr: []
    property var currentRoomModel: null
    property var roomsCount: 0

    function getDataFromServer(topic, msg) {

    }

    Connections
    {
        target: appCore

        onMqttConnected:
        {
            //appCore.sendMqttMessage("test123", 456);
        }

        onChangeActiveRoom: {
            try {
                let devicesArr = JSON.parse(storage.value("devicesArrJson"))

                let activeDevicesArr = []
                displayDevices.model = activeDevicesArr // сбросить запомненные устройства в комнате

                for(let i = 0; i < devicesArr.length; i++) {
                    if(parseInt(devicesArr[i].zoneId) === parseInt(zoneId)) {
                        activeDevicesArr.push(devicesArr[i]) // заполнение промежуточного массива нужными устройствами для вывода
                        displayDevices.model = activeDevicesArr
                    }
                }
            } catch(e) {

            }
        }
    }

    width: parent.width
    height: parent.height
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 10
    columns: 3

    Repeater {
        id: displayDevices

        Rectangle {
            id: deviceBlock
            radius: 10
            width: parent.width/3.3
            height: width/1.6
            color: Styles.gray

            Text {
                text: "H"
                color: modelData.hState === "1" ? Styles.red : Styles.dark
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 15
                font.family: "Roboto"
                font.bold: true
                visible: modelData.type === "thermostat" ? true : false
                anchors.right: deviceData.left
                anchors.rightMargin: 5
            }

            Text {
                id: deviceData
                visible: modelData.type === "signal" | modelData.type === "switcher" ? false : true
                text: modelData.data + modelData.unit
                color: Styles.white
                anchors.centerIn: parent
                font.pointSize: (30 + (parent.width/30)) * modelData.sizeCoefficient
                font.family: "Roboto"
                font.weight: Font.Light
            }

            Image {
                id: celsius
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: deviceData.right
                anchors.leftMargin: 3
                height: 33
                width: 11
                source: "qrc:/png/celsius.png"
                visible: modelData.type === "thermostat" | modelData.type === "temperature" ? true : false
                smooth: true
                antialiasing: true
            }

            Rectangle {
                height: 22
                width: 22
                radius: 11
                anchors.centerIn: parent
                border.color: Styles.dark
                border.width: 2
                visible: modelData.type === "signal" ? true : false
                color: parseInt(modelData.data) === 1 ? Styles.blue : Styles.lightGray
            }

            Switch {
                id: control
                smooth: false
                checked: parseInt(modelData.data) === 1 ? true : false
                visible: modelData.type === "switcher" ? true : false
                anchors.centerIn: parent
                indicator: Rectangle {
                    x: control.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: 15
                    color: Styles.dark
                    height: 35
                    width: 75
                    Rectangle {
                        x: parseInt(modelData.data) === 1 ? parent.width - width : 0
                        width: 35
                        height: 35
                        radius: 17.5
                        color: parseInt(modelData.data) === 1 ? Styles.blue : Styles.lightGray
                    }
                }
                onClicked: {
                    let managedData = control.checked ? "1" : "0"
                    let deviceObject = {
                        "update": {
                            "data": managedData,
                            "name": modelData.name,
                        }
                    }
                    appCore.sendMqttMessage(modelData.idDevice + '/set/data', JSON.stringify(deviceObject))
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    appCore.setPopupData(modelData.idDevice, modelData.zoneId, modelData.name, modelData.data, modelData.temp, modelData.hState, modelData.relay);
                    popupLoader.item.open()
                }
                enabled: modelData.type === "thermostat" ? true : false
            }
        }
    }
}
