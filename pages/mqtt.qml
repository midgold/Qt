import QtQuick 2.12
import QtQuick.Controls 2.12
import Qt.labs.settings 1.0

import "../components"
import "../js/styles.js" as Styles

Container {

    Component.onCompleted: {
        appCore.setFooter(false);
        appCore.setActivePage("mqtt")
    }

    Settings {
        id: storage
    }

    HandlerMqtt {

    }

    id: contentContainer

    Text {
        id: header
        y: 20
        text: "Mqtt"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 18
        font.bold: true
        color: Styles.white
    }
    Column {
        anchors {
            top: header.bottom
            topMargin: 16
            left: parent.left
            leftMargin: 16
            right: parent.right
            rightMargin: 16
        }

        spacing: 10

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
                text: storage.value("ipMqtt")
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
                text: storage.value("portMqtt")
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
            text: qsTr("Login")
        }

        Rectangle
        {
            color: Styles.dark
            width: parent.width
            height: 25

            TextInput
            {
                id: loginInput
                text: storage.value("userName")
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
            font.pointSize: 10
            color: Styles.white
            text: qsTr("Password")
        }

        Rectangle
        {
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
                id: checkBoxLogin

                property int checkState: 0

                height: 20
                width: 20
                color: Styles.dark

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        checkBoxLogin.checkState = !checkBoxLogin.checkState

                        if(checkBoxLogin.checkState) {
                            checkBoxLogin.color=Styles.blue
                        } else {
                            checkBoxLogin.color=Styles.dark
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
            text: qsTr("Log out")
            anchors.horizontalCenter: parent.horizontalCenter
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    storage.setValue("mqttIsConnected", false);
                    stack.pop();
                    appCore.setFooter(true);
                    appCore.mqttStatusUpdate("Disconnected");
                    mainPageLoader.source = "qrc:/pages/rooms.qml"
                }
            }
        }
    }

    Footer {

        Rectangle
        {
            height: 22
            width: 30
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            anchors.left: parent.left
            color: "transparent"
            Image {
                id: apply
                source: "qrc:/png/apply.png"
                anchors.fill: parent
                smooth: true
                antialiasing: true
            }

            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    if(loginInput.text != "" & portInput.text != "" & ipInput.text != "" & portInput.text != "" |
                       ipInput.text != "" & portInput.text != "" & checkBoxLogin.checkState) {

                        appCore.setMqttConnection(ipInput.text, parseInt(portInput.text), loginInput.text, passInput.text);

                        storage.setValue("ipMqtt", ipInput.text)
                        storage.setValue("portMqtt", parseInt(portInput.text))
                        storage.setValue("userName", loginInput.text)
                        storage.setValue("userPass", passInput.text)
                        storage.sync()

                        stack.pop();
                        appCore.setFooter(true);
                        mainPageLoader.source = "qrc:/pages/rooms.qml"
                    } else {
                        inputErrorLabel.visible=true
                    }
                }
            }
        }

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
