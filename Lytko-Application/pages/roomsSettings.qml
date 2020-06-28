import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import "../components"
import "../js/styles.js" as Styles

Rectangle
{
    function setDevicesListByZoneId(currentRoomId) {
        try {
            let devicesArr = []
            let roomsArr = []
            devicesList.clear()

            devicesArr = JSON.parse(storage.value("devicesArrJson"))
            roomsArr = JSON.parse(storage.value("roomsArrJson"))

            for(let y = 0; y < devicesArr.length; y++) {
                devicesList.append(devicesArr[y])
            }

        } catch(e) {
            devicesList.append({
                                   "idDevice": "0",
                                   "name": "No available devices",
                               })
        }
    }

    HandlerMqtt {

    }

    Component.onCompleted: {
        var roomsArr = []
        roomsArr = JSON.parse(storage.value("roomsArrJson"))

        // зполнение массива для передачи в Repeater, чтобы отобразить SwipeView
        for(var y = 0; y < roomsArr.length; y++) {
            let roomObj = {
                "zoneId": roomsArr[y].zoneId,
                "roomName": roomsArr[y].roomName,
                "iconId": roomsArr[y].iconId
            }
            roomsManageList.append(roomObj)
        }
        appCore.setFooter(false);
        appCore.setActivePage("roomsSettings")
    }

    id: back
    color: Styles.dark

    Rectangle {
        color: Styles.gray
        anchors {
            fill:parent
            topMargin: 8
            leftMargin: 8
            rightMargin: 8
            bottomMargin: 68
        }

        radius: 5

        SwipeView {
            id: swipe
            anchors {
                fill: parent
                topMargin: 20
            }

            Repeater {
                model: roomsManageList
                Loader {
                    active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                    sourceComponent:
                        RoomManage { }
                }
            }
            onCurrentIndexChanged: {
                // -1 нужен, потому что нулевой индекс SwipeView - добавление новой комнаты
                setDevicesListByZoneId(currentIndex - 1)
            }
        }

        ListModel {
            id: roomsManageList

            ListElement {
                zoneId: 0
                roomName: qsTr("Create new room")
            }
        }

        ListModel {
            id: devicesList
        }
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

        anchors{
            bottom: footer.top
            horizontalCenter: parent.horizontalCenter
        }
    }

    Footer {
        id: footer

        Rectangle
        {
            height: 25
            width: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            anchors.right: parent.right
            color: "transparent"
            Image {
                id: close
                source: "qrc:/png/close.png"
                anchors.fill: parent
                smooth: true
                antialiasing: true
            }

            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    stack.pop();
                    appCore.setFooter(true);
                }
            }
        }
    }
}
