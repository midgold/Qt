import QtQuick 2.2
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0

import "../components"
import "../js/styles.js" as Styles

Item
{
    id: rooms

    property int roomsCount: 1

    Component.onCompleted: {
        if(storage.value("roomsArrJson") !== undefined & storage.value("roomsArrJson") !== null & storage.value("roomsArrJson") !== "") {
            let roomsArr = JSON.parse(storage.value("roomsArrJson"))
            rooms.roomsCount = roomsArr.length
            appCore.setActiveRoom(parseInt(roomsArr[swipe.currentIndex].zoneId))
            appCore.setFooterZoneId(parseInt(roomsArr[swipe.currentIndex].zoneId))
        }
        appCore.setActivePage("rooms")
    }

    HandlerMqtt {

    }

    Settings {
        id: storage
    }

    Rectangle
    {
        id: back
        width: parent.width
        height: parent.height
        color: Styles.dark

        SwipeView
        {
            anchors.fill: parent
            anchors.topMargin: 10
            anchors.leftMargin: 10

            id: swipe

            Repeater {
                model: rooms.roomsCount

                Loader {
                    active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                    sourceComponent:
                        Room { }
                }
            }
            onCurrentIndexChanged: {
                if(currentIndex !== -1) { // почему возникает -1 - разобраться

                    try {
                        let roomsArr = JSON.parse(storage.value("roomsArrJson"))
                        let devicesArr = JSON.parse(storage.value("devicesArrJson"))
                        let foundedBaseDevice = false

                        // проверка, есть ли устройства с zoneId=0 для нулевой комнаты
                        for(let i = 0; i < devicesArr.length; i++) {
                            if(devicesArr[i].zoneId === 0) {
                                foundedBaseDevice = true
                                break
                            }
                        }

                        if(!foundedBaseDevice & currentIndex == 0) {
                            // если нулевая комната пустая
                            appCore.setActiveRoom(0)
                            appCore.setFooterZoneId(0)
                        } else {
                            appCore.setActiveRoom(parseInt(roomsArr[currentIndex].zoneId))
                            appCore.setFooterZoneId(parseInt(roomsArr[currentIndex].zoneId))
                        }

                    } catch(e) {
                        appCore.setActiveRoom(0) // установка комнаты по умолчанию
                        appCore.setFooterZoneId(0) // установка комнаты по умолчанию в Footer
                    }
                }
            }
        }
    }

    Loader {
        id: popupLoader
        source: "qrc:/pages/thermostatSettings.qml"
        width: parent.width
        height: parent.height
    }

    PageIndicator {
        id: indicator

        count: swipe.count
        currentIndex: swipe.currentIndex

        delegate: Rectangle {
            implicitWidth: 8
            implicitHeight: 8

            radius: width / 2
            color: index === indicator.currentIndex ? Styles.blue : Styles.lightGray

            opacity: index === indicator.currentIndex ? 0.95 : pressed ? 0.7 : 0.45

            Behavior on opacity {
                OpacityAnimator {
                    duration: 100
                }
            }
        }

        anchors {
            bottomMargin: 55
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
    }
}
/*
ListModel {
    id: devicesModel

    ListElement {
        idDevice: "123"
        data: "-1"
        type: "pressure"
        name: "Атмосферное давление"
        hState: false
        connected: false
        unit: "mm Hg"
        sizeCoefficient: 0.6
    }
    ListElement {
        idDevice: "74"
        data: "35"
        type: "humidity"
        name: "Влажность воздуха"
        hState: false
        connected: true
        unit: "%"
        sizeCoefficient: 1
    }
    ListElement {
        idDevice: "85"
        data: "40"
        type: "illuminance"
        name: "Освещение"
        hState: false
        connected: true
        unit: "%"
        sizeCoefficient: 1
    }
    ListElement {
        idDevice: "6"
        data: "20"
        type: "temperature"
        name: "Температура"
        hState: false
        connected: true
        unit: ""
        sizeCoefficient: 1
    }
    ListElement {
        idDevice: "231"
        data: ""
        type: "switcher"
        name: "Выключатель"
        hState: false
        connected: true
        state: true
        unit: ""
        sizeCoefficient: 1
    }
}
*/

