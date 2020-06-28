import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import "../components"
import "../js/styles.js" as Styles

Column {

    property var checkedDevicesArr: []

    spacing: 15

    Settings {
        id: storage
    }

    Text {
        text: roomName
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 18
        font.bold: true
        color: Styles.white
    }

    Text {
        text: qsTr("Enter new room name")
        color: Styles.white
        anchors {
            left: roomNameInputContainer.left
            leftMargin: 5
        }
        font {
            italic: true
            pointSize: 10
        }
    }

    Rectangle
    {
        id: roomNameInputContainer
        color: Styles.dark
        height: 25
        width: parent.width - 20
        anchors.horizontalCenter: parent.horizontalCenter

        TextInput
        {
            id: roomNameInput
            echoMode: TextInput.Normal
            color: Styles.white
            font.pixelSize: 10
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.topMargin: 5
        }
    }

    Text {
        text: qsTr("Choose icon")
        anchors.horizontalCenter: parent.horizontalCenter
        font {
            family: "Roboto"
            pointSize: 16
        }
        color: Styles.white
    }
    Row {
        id: iconListContainer
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        property int currentIconId: 0

        Repeater {
            id: roomIconContainer
            model: JSON.parse(storage.value("iconsArrJson"))

            Image {
                id: roomIcon
                source: "qrc:/png/" + modelData.iconName + ".png"
                height: modelData.iconHeight
                width: modelData.iconWidth
                antialiasing: true
                smooth: true


//                Component.onCompleted: {
                // ДОДЕЛАТЬ ВЫДЕЛЕНИЕ ИКОНКИ ТЕКУЩЕЙ КОМНАТЫ
//                    let roomsArr = JSON.parse(storage.value("roomsArrJson"))

//                    if(swipe.currentIndex !== 0) {
//                        if(parseInt(roomsArr[swipe.currentIndex - 1].iconId) === parseInt(modelData.iconId)) {
//                            iconListContainer.currentIconId = modelData.iconId
//                            roomIcon.source = "qrc:/png/active/" + modelData.iconName + ".png"
//                        }
//                    } else {
//                        roomIcon.source = "qrc:/png/" + modelData.iconName + ".png"
//                    }

//                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // сложные манипуляции для того, чтобы выбранная иконка стала синей
                        for(let i = 0; i < JSON.parse(storage.value("iconsArrJson")).length; ++i) {
                            let currentSource = roomIconContainer.itemAt(i).source.toString();
                            let splitArr = []
                            splitArr = currentSource.split("/")
                            if(splitArr[2] === "active") {
                                let splitActive = []
                                splitActive = currentSource.split("active/")
                                roomIconContainer.itemAt(i).source = splitActive[0] + splitActive[1]
                            }
                        }
                        iconListContainer.currentIconId = modelData.iconId
                        roomIcon.source = "qrc:/png/active/" + modelData.iconName + ".png"
                    }
                }
            }
        }
    }

    Text {
        text: qsTr("Devices list")
        anchors.horizontalCenter: parent.horizontalCenter
        font {
            family: "Roboto"
            pointSize: 16
        }
        color: Styles.white
    }

    Rectangle {
        border.color: Styles.dark
        color: Styles.gray
        height: devicesList.count * 33
        Layout.maximumHeight: parent.height - 60
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 8
            rightMargin: 8
        }

        ScrollView {

            width: parent.width
            height: parent.height

            ListView {
                id: deviceRoomIcon
                clip: true
                anchors {
                    fill: parent
                    margins: 10
                }

                spacing: 20

                model: devicesList

                delegate: Item {
                    id: deviceItem

                    Row {
                        spacing: 10

                        Text {
                            id: currentDeviceLabelIdLabel
                            text: idDevice
                            visible: false
                            enabled: false
                        }
                        Text {
                            id: currentZoneIdLabel
                            text: zoneId.toString();
                            visible: false
                            enabled: false
                        }

                        Image {
                            id: currentDeviceLabelIcon
                            anchors.verticalCenter: parent.verticalCenter
                            smooth: true
                            antialiasing: true

                            Component.onCompleted: {
                                let roomsArr = JSON.parse(storage.value("roomsArrJson"))
                                let iconsArr = JSON.parse(storage.value("iconsArrJson"))

                                for(let i = 0; i < roomsArr.length; i++) {
                                    if(parseInt(roomsArr[i].zoneId) === parseInt(zoneId)) {
                                        currentDeviceLabelIcon.source = iconsArr[roomsArr[i].iconId].iconSource
                                        currentDeviceLabelIcon.width = iconsArr[roomsArr[i].iconId].iconWidth / 2
                                        currentDeviceLabelIcon.height = iconsArr[roomsArr[i].iconId].iconHeight / 2
                                    }
                                }
                            }
                        }

                        Text {
                            property bool click: false

                            id: currentDeviceLabel
                            text: name
                            color: Styles.white
                            font.pointSize: 10
                            verticalAlignment: Text.AlignVCenter
                            font.family: 'Roboto'

                            Component.onCompleted: {

                                let devicesArr = JSON.parse(storage.value("devicesArrJson"))
                                let roomsArr = JSON.parse(storage.value("roomsArrJson"))

                                if(swipe.currentIndex !== 0) {

                                    // -1 нужен потому что нулевой индекс SwipeView - добавление комнат.
                                    //Таким образом, для соответствия индексов текущей комнаты и элемента в массиве комнат нужно отнять 1
                                    let currentRoomIndex = swipe.currentIndex - 1

                                    // выделить серым те устройства, которые не относятся к текущей комнате
                                    if(parseInt(zoneId) === parseInt(roomsArr[currentRoomIndex].zoneId)) {
                                        currentDeviceLabel.color = Styles.white
                                    } else {
                                        currentDeviceLabel.color = Styles.lightGray
                                    }
                                }
                            }


                            MouseArea {
                                anchors.fill: parent
                                onClicked: {

                                    if(!currentDeviceLabel.click) {

                                        currentDeviceLabel.color = Styles.white
                                        currentDeviceLabelCheck.visible = true

                                        checkedDevicesArr.push({
                                                                   "idDevice": parseInt(currentDeviceLabelIdLabel.text),
                                                                   "zoneId": parseInt(currentZoneIdLabel.text)
                                                               })

                                        currentDeviceLabel.click = !currentDeviceLabel.click

                                    } else {
                                        currentDeviceLabel.color = Styles.lightGray
                                        currentDeviceLabelCheck.visible = false

                                        for(var d = 0; d < checkedDevicesArr.length; d++) {
                                            if(checkedDevicesArr[d].idDevice === currentDeviceLabelIdLabel.text)
                                                checkedDevicesArr.splice(d, 1)
                                        }

                                        currentDeviceLabel.click = !currentDeviceLabel.click
                                    }
                                }
                            }
                        }

                        Image {
                            id: currentDeviceLabelCheck
                            source: "qrc:/png/apply.png"
                            width: 20
                            height: 14
                            visible: false
                        }
                    }
                }
            }
        }
    }
    Row {
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        Button {
            text: swipe.currentIndex === 0 ? qsTr("Add") : qsTr("Edit")
            isActive: true

            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    try {
                        let roomsArr = JSON.parse(storage.value("roomsArrJson"))
                        let devicesArr = JSON.parse(storage.value("devicesArrJson"))
                        let managedZoneId;
                        let isEmptyRoom = false;

                        if(swipe.currentIndex === 0) // добавить новую комнату
                        {
                            // Сгенерировать новую zoneId при создании новой комнаты. К последнему записанному zoneId в массиве прибалвяется 1
                            managedZoneId = parseInt(roomsArr[roomsArr.length - 1].zoneId) + 1
                            roomsArr.push({
                                              "zoneId": managedZoneId,
                                              "roomName": roomNameInput.text,
                                              "iconId": iconListContainer.currentIconId
                                          });
                        } else {
                            // -1 нужен, потому что нулевой индекс SwipeView - добавление новой комнаты
                            managedZoneId = parseInt(roomsArr[swipe.currentIndex - 1].zoneId)

                            // поиск текущей комнаты и обновление её названия и иконки
                            for(let i = 0; i < roomsArr.length; i++) {
                                if(parseInt(roomsArr[i].zoneId) === managedZoneId) {
                                    roomsArr[i].zoneId = managedZoneId
                                    roomsArr[i].roomName = roomNameInput.text === "" ?  roomsArr[i].roomName : roomNameInput.text
                                    roomsArr[i].iconId = iconListContainer.currentIconId
                                }
                            }
                        }

                        for(let checkedIterator = 0; checkedIterator < checkedDevicesArr.length; checkedIterator++) {

                            // уведомить ESP о смене zoneId у выбранных устройств
                            appCore.sendMqttMessage(checkedDevicesArr[checkedIterator].idDevice + "/Set/NewZoneId", managedZoneId)

                            // ищем в записанном в памяти массиве устройств выбранные и переносим в новую zoneId
                            for(let q = 0; q < devicesArr.length; q++) {
                                if(parseInt(devicesArr[q].idDevice) === parseInt(checkedDevicesArr[checkedIterator].idDevice)) {
                                    devicesArr[q].zoneId = managedZoneId
                                }
                            }
                        }

                        storage.setValue("roomsArrJson", JSON.stringify(roomsArr))
                        storage.setValue("devicesArrJson", JSON.stringify(devicesArr))

                        stack.pop();
                        appCore.setFooter(true);

                    } catch(e) {
                        popup.open()
                    }
                }
            }
        }
        Rectangle {
            id: deleteBtn
            height: 30
            width: 95
            color: "transparent"
            border.color: Styles.red

            visible: swipe.currentIndex !== 0 & swipe.currentIndex !== 1 ? true : false

            Text {
                text: qsTr("Delete")
                anchors.centerIn: parent
                color: Styles.white
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    let roomsArr = JSON.parse(storage.value("roomsArrJson"))
                    let devicesArr = JSON.parse(storage.value("devicesArrJson"))

                    // -1 нужен потому что нулевой индекс SwipeView - добавление комнат.
                    //Таким образом, для соответствия индексов текущей комнаты и элемента в массиве комнат нужно отнять 1
                    let currentRoomZoneId = swipe.currentIndex - 1

                    // переместить устройства из текущей комнаты в нулевую комнату
                    for(let i = 0; i < devicesArr.length; i++) {
                        if(parseInt(devicesArr[i].zoneId) === parseInt(roomsArr[currentRoomZoneId].zoneId)) {
                            devicesArr[i].zoneId = 0
                        }
                    }

                    roomsArr.splice(currentRoomZoneId, 1)

                    storage.setValue("roomsArrJson", JSON.stringify(roomsArr))
                    storage.setValue("devicesArrJson", JSON.stringify(devicesArr))

                    stack.pop();
                    appCore.setFooter(true);
                }
            }
        }
    }
    Popup {
        id: popup
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        anchors.centerIn: Overlay.overlay
        width: parent.width - 5
        height: contentHeight + 100

        background: Item {}

        contentItem: Rectangle {
            color: Styles.gray
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 5

            Text {
                text: qsTr("Can not to add or edit a room without any devices")
                color: Styles.white
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                font{
                    family: 'Roboto'
                    pointSize: 10
                }
            }
        }
    }
}

