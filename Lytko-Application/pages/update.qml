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

        try {
            var devicesArrFromDb = JSON.parse(storage.value("devicesArrJsonProp"));

            deviceList.append(devicesArrFromDb)
        } catch(e) {
            deviceList.append({"name": "No available devices",
                               "version": "-",
                               "isUpdate": false
                              })
        }

        appCore.setActivePage("update")
    }

    HandlerMqtt {

    }

    Text {
        id: header
        y: 20
        text: qsTr("Update")
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 18
        font.bold: true
        color: "#fff"
    }


    ListView {
        id: devicesContainer
        anchors {
            margins: 15
            top: header.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }
        spacing: 15
        clip: true

        delegate: Rectangle {
            width: parent.width
            border {
                color: Styles.dark
                width: 1
            }
            color: Styles.gray
            height: deviceItem.height + 20

            Column {
                id: deviceItem
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: name
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: 10
                    color: "#fff"
                }
                Text {
                    text: version
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: 10
                    color: "#fff"
                }
                Button {
                    text: qsTr("Update")
                    anchors.horizontalCenter: parent.horizontalCenter
                    isActive: isUpdate
                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            appCore.sendMqttMessage(idDevice + "/update/start", 1);
                        }
                    }
                }
            }
        }
        model: deviceList
    }

    ListModel {
        id: deviceList
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

