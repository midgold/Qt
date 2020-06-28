import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Window 2.14
import Qt.labs.settings 1.0

import "../components"
import "qrc:/js/styles.js" as Styles

ApplicationWindow
{
    property bool mainFooter: false
    property int activeZoneId: 0
    property string roomName: ""

    Settings {
        id: storage
    }

    Connections
    {
        target: appCore // Указываем целевое соединение
        /* Объявляем и реализуем функцию, как параметр
             * объекта и с имененем похожим на название сигнала
             * Разница в том, что добавляем в начале on и далее пишем
             * с заглавной буквы
             * */
        onChangeFooter:
        {
            mainFooter = status
        }
        onChangeFooterZoneId:
        {
            // Установить название и икноку комнаты в footer при изменении
            let roomsArr = JSON.parse(storage.value("roomsArrJson"))
            let iconsArr = JSON.parse(storage.value("iconsArrJson"))
            let currentIconId;

            for(let r = 0; r < roomsArr.length; r++) {
                if(parseInt(roomsArr[r].zoneId) === parseInt(currentZoneId))
                    currentIconId = roomsArr[r].iconId
            }

            for(let i = 0; i < iconsArr.length; i++) {
                if(iconsArr[i].iconId === currentIconId) {
                    roomIconFooter.source = iconsArr[i].iconSource
                    roomIconFooter.width = iconsArr[i].iconWidth
                    roomIconFooter.height = iconsArr[i].iconHeight
                    break;
                }
            }

            for(let e = 0; e < roomsArr.length; e++) {
                if(parseInt(roomsArr[e].zoneId) === parseInt(currentZoneId))
                    roomNameFooter.text = roomsArr[e].roomName
            }

            activeZoneId = parseInt(currentZoneId)
        }
        onMqttStatusUpdate: {
            console.log(status);
            if(status === "NoError") {
                authContainer.visible = false
                mainPageLoader.visible = true
                mainFooter = true
            } else if (status === "Disconnected") {
                authContainer.visible = true
                mainPageLoader.visible = false
                mainFooter = false
            }
            else {
                inputErrorLabel.visible=true
            }
        }
    }

    Component.onCompleted: {

        //        console.log(appCore.getTopics());


        //        for (var prop in appCore.getTopics()) {
        //            console.log("Object item:", prop, "=", appCore.getTopics()[prop])
        //        }

        appCore.setActivePage("rooms") // main.qml служит контейнером для rooms.qml, поэтому они равнозначны для обработчика MQTT

        // Проверка на авторизацию пользователя
        if(storage.value("mqttIsConnected") == "true") {

            appCore.setMqttConnection(storage.value("ipMqtt"), storage.value("portMqtt"), storage.value("userName"), storage.value("userPass"));

            authContainer.visible = false
            mainPageLoader.visible = true
            mainFooter = true
        } else {
            authContainer.visible = true
            mainPageLoader.visible = false
        }

        let roomsArr = [];

        // Создание нулевой комнаты при первом запуске
        if(storage.value("roomsArrJson") === undefined | storage.value("roomsArrJson") === "") {

            roomsArr.push({
                              "zoneId": 0,
                              "roomName": "Room 0",
                              "iconId": 0
                          });
            storage.setValue("roomsArrJson", JSON.stringify(roomsArr))
            storage.sync()

            // Создание и запись в память приложения массива со списком иконок для комнат.
            // Индекс элемента соответствует iconId иконки для комнаты
            var iconsArr = [
                        {"iconId": 0, "iconWidth": 42, "iconHeight": 25, "iconSource": "qrc:/png/bedroom.png", "iconName": "bedroom"},
                        {"iconId": 1, "iconWidth": 25, "iconHeight": 25, "iconSource": "qrc:/png/bathroom.png", "iconName": "bathroom"},
                        {"iconId": 2, "iconWidth": 19, "iconHeight": 25, "iconSource": "qrc:/png/childroom.png", "iconName": "childroom"},
                        {"iconId": 3, "iconWidth": 20, "iconHeight": 25, "iconSource": "qrc:/png/kitchen.png", "iconName": "kitchen"},
                        {"iconId": 4, "iconWidth": 42, "iconHeight": 25, "iconSource": "qrc:/png/livingroom.png", "iconName": "livingroom"},
                        {"iconId": 5, "iconWidth": 36, "iconHeight": 25, "iconSource": "qrc:/png/storeroom.png", "iconName": "storeroom"},

                    ]
            // Запись массива с икноками в память приложения при первом запуске
            storage.setValue("iconsArrJson", JSON.stringify(iconsArr))
            storage.sync()
        }

        // Установить название и икноку комнаты в footer при запуске
        roomsArr = JSON.parse(storage.value("roomsArrJson"))
        iconsArr = JSON.parse(storage.value("iconsArrJson"))
        let currentIconId = roomsArr[0].iconId

        for(let i = 0; i < iconsArr.length; i++) {
            if(iconsArr[i].iconId === currentIconId) {
                roomIconFooter.source = iconsArr[i].iconSource
                roomIconFooter.width = iconsArr[i].iconWidth
                roomIconFooter.height = iconsArr[i].iconHeight
                break;
            }
        }

        roomNameFooter.text = roomsArr[0].roomName

        // По умолчанию отображается первая комната с zoneId=0
        appCore.setActiveRoom(0);
    }

    width: 375
    height: 812
    title: qsTr("Lytko")
    visible: true
    id: mainWindow

    Rectangle {

        id: authContainer
        anchors.fill: parent
        color: Styles.dark

        Rectangle {

            anchors.centerIn: parent
            color: Styles.gray
            radius: 10
            height: authContent.height + 60
            width: parent.width - 20

            Column {

                id: authContent
                width: parent.width - 20
                anchors {
                    top: parent.top
                    topMargin: 30
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 10

                Text {
                    id: header
                    y: 20
                    text: qsTr("Authorization")
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: 18
                    font.bold: true
                    color: Styles.white
                }

                Text {
                    id: inputErrorLabel
                    visible: false
                    text: qsTr("Check input data")
                    color: Styles.red
                }

                Text
                {
                    font.pointSize: 10
                    color: Styles.white
                    text: "Ip"
                }

                Rectangle
                {
                    color: Styles.dark
                    height: 25
                    width: parent.width

                    TextInput
                    {
                        id: ipInput
                        text: "lytko.com"
                        readOnly: true
                        echoMode: TextInput.Normal
                        color: Styles.white
                        font.pixelSize: 12
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.topMargin: 5

                    }
                }

                Text
                {
                    font.pointSize: 10
                    color: Styles.white
                    text: qsTr("Port")
                }

                Rectangle
                {
                    color: Styles.dark
                    height: 25
                    width: parent.width

                    TextInput
                    {
                        id: portInput
                        text: "1883"
                        readOnly: true
                        echoMode: TextInput.Normal
                        color: Styles.white
                        font.pixelSize: 12
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.topMargin: 5
                    }
                }

                Text
                {
                    id: loginLabel
                    font.pointSize: 10
                    color: Styles.white
                    text: qsTr("Login")
                }

                Rectangle
                {
                    id: loginInputContainer
                    color: Styles.dark
                    width: parent.width
                    height: 25

                    TextInput
                    {
                        id: loginInput
                        echoMode: TextInput.Normal
                        color: Styles.white
                        font.pixelSize: 12
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.topMargin: 5
                        KeyNavigation.tab: passInput
                    }
                }

                Text
                {
                    id: passLabel
                    font.pointSize: 10
                    color: Styles.white
                    text: qsTr("Password")
                }

                Rectangle
                {
                    id: passInputContainer
                    color: Styles.dark
                    width: parent.width
                    height: 25

                    TextInput
                    {
                        id: passInput
                        echoMode: TextInput.Password
                        color: Styles.white
                        font.pixelSize: 12
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.topMargin: 5
                        KeyNavigation.tab: loginInput
                    }
                }

                Row {
                    spacing: 5

                    Rectangle {
                        id: checkBox

                        property bool checkState: false

                        height: 20
                        width: 20
                        color: Styles.dark

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                checkBox.checkState = !checkBox.checkState
                                if(checkBox.checkState) {
                                    ipInput.text=""
                                    ipInput.readOnly=false

                                    portInput.text=""
                                    portInput.readOnly=false

                                    checkBox.color=Styles.blue
                                } else {
                                    ipInput.text="lytko.com"
                                    ipInput.readOnly=true

                                    portInput.text="1883"
                                    portInput.readOnly=true

                                    checkBox.color=Styles.dark
                                }
                            }
                        }
                    }

                    Text {
                        text: qsTr("Use another MQTT server")
                        color: Styles.white
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 5

                    Rectangle {
                        id: checkBoxLogin

                        property bool checkState: false

                        height: 20
                        width: 20
                        color: Styles.dark

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                checkBoxLogin.checkState = !checkBoxLogin.checkState

                                if(checkBoxLogin.checkState) {
                                    checkBoxLogin.color=Styles.blue
                                    loginInputContainer.visible=false
                                    passInputContainer.visible=false
                                    loginLabel.visible=false
                                    passLabel.visible=false
                                } else {
                                    checkBoxLogin.color=Styles.dark
                                    loginInputContainer.visible=true
                                    passInputContainer.visible=true
                                    loginLabel.visible=true
                                    passLabel.visible=true
                                }
                            }
                        }
                    }

                    Text {
                        text: qsTr("Log in without name & password")
                        color: Styles.white
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Button {
                    text: qsTr("Log in")
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(loginInput.text != "" & portInput.text != "" & ipInput.text != "" & portInput.text != "" |
                               ipInput.text != "" & portInput.text != "" & checkBoxLogin.checkState) {

                                appCore.setMqttConnection(ipInput.text, parseInt(portInput.text), loginInput.text, passInput.text);

                                storage.setValue("ipMqtt", ipInput.text)
                                storage.setValue("portMqtt", parseInt(portInput.text))
                                storage.setValue("userName", loginInput.text)
                                storage.setValue("userPass", passInput.text)
                                storage.sync()
                            } else {
                                inputErrorLabel.visible=true
                            }
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: mainPageLoader
        visible: false
        width: parent.width
        height: parent.height
        source: "qrc:/pages/rooms.qml"
    }

    Footer {
        visible: mainFooter
        id: footer

        Rectangle
        {
            id: tab1
            height: 25
            width: 37
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            anchors.left: parent.left
            color: "transparent"

            Column {
                width: parent.width
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    id: roomIconFooter
                    smooth: true
                    antialiasing: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    id: roomNameFooter
                    color: Styles.blue
                    font.pointSize: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    mainPageLoader.source = "qrc:/pages/rooms.qml"
                }
            }
        }

        Rectangle
        {
            id: tab2
            height: 25
            width: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            Image {
                id: settingsSwipeIcon
                source: "qrc:/png/settings.png"
                anchors.fill: parent
                smooth: true
                antialiasing: true
            }

            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    mainPageLoader.source = "qrc:/pages/settings.qml"
                }
            }
        }

        Rectangle
        {
            id: tab3
            height: 25
            width: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            anchors.right: parent.right
            color: "transparent"
            Image {
                id: addDeviceSwipeIcon
                source: "qrc:/png/plus.png"
                anchors.fill: parent
                smooth: true
                antialiasing: true
            }

            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    mainPageLoader.source = "qrc:/pages/addDevice.qml"
                }
            }
        }
    }
}


