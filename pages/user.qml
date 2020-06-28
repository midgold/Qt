import QtQuick 2.0
import Qt.labs.settings 1.0

import "../components"
import "../js/styles.js" as Styles

Container {

    Settings {
        id: storage
    }

    Component.onCompleted: {
        appCore.setFooter(false);
        userNameLabel.text = storage.value("userName")
//        connectionLabel.text = appCore.mqttIsConnected() ? "online" : "offline"

        appCore.setActivePage("user")
    }

    HandlerMqtt {

    }

    Text {
        id: header
        y: 20
        text: qsTr("Account")
        anchors.horizontalCenter: parent.horizontalCenter
        font {
            pointSize: 18
            bold: true
        }
        color: Styles.white
    }

    Column {
        anchors {
            top: header.bottom
            right: parent.right
            left: parent.left
            margins: 20
        }

        spacing: 10

        Row {
            spacing: 5
            Text {
                text: qsTr("Username: ")
                color: Styles.white
                font {
                    family: 'Roboto'
                }
            }

            Text {
                id: userNameLabel
                color: Styles.white
                font {
                    family: 'Roboto'
                }
            }
        }

        Row {
            spacing: 5
            Text {
                text: qsTr("Connect to MQTT server: ")
                color: Styles.white
                font {
                    family: 'Roboto'
                }
            }

            Text {
                id: connectionLabel
                color: Styles.white
                font {
                    family: 'Roboto'
                }
            }
        }
    }

    Footer {
        Rectangle
        {
            height: 25
            width: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            anchors.right: parent.right
            color: "transparent"
            Image {
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

