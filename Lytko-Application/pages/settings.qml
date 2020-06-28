import QtQuick 2.12
import QtQuick.Controls 2.12

import "../js/styles.js" as Styles
import "../components"

Item
{
    id: settings

    Component.onCompleted: {
        appCore.setFooter(true);
        appCore.setActivePage("settings")
    }

    HandlerMqtt {

    }

    StackView {
        id: stack
        initialItem: back
        anchors.fill: parent
    }

    Container {
        id: back

        Text {
            id: header
            y: 19
            text: qsTr("Settings")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 18
            font.bold: true
            color: Styles.white
        }

        ListView {
            id: viewIcons
            anchors {
                left: parent.left
                leftMargin: 30
                top: header.bottom
                topMargin: 30
                bottom: parent.bottom
                right: parent.right
            }
            spacing: 15
            clip: true

            delegate: Row {
                clip: true
                spacing: 22

                Image {
                    id: iconImage
                    width: widthImage
                    height: heightImage
                    source: sourceImage

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stack.push(pagePath)
                        }
                    }
                }
                Text {
                    text: qsTr(itemText)
                    color: Styles.white
                    font.pointSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: 'Roboto'
                    font.weight: Font.Normal

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stack.push(pagePath)
                        }
                    }
                }

            }
            model: settingsItems
        }

        ListModel {
            id: settingsItems
            ListElement {
                itemText: "Wifi"
                sourceImage: "qrc:/png/wifi.png"
                widthImage: 36
                heightImage: 26
                pagePath: "qrc:/pages/wifi.qml"
            }
//            ListElement {
//                itemText: "Account"
//                sourceImage: "qrc:/png/user.png"
//                widthImage: 34
//                heightImage: 38
//                pagePath: "qrc:/pages/user.qml"
//            }
            ListElement {
                itemText: "Update"
                sourceImage: "qrc:/png/update.png"
                widthImage: 36
                heightImage: 36
                pagePath: "qrc:/pages/update.qml"
            }
            ListElement {
                itemText: "MQTT"
                sourceImage: "qrc:/png/mqtt.png"
                widthImage: 36
                heightImage: 24
                pagePath: "qrc:/pages/mqtt.qml"
            }
            ListElement {
                itemText: "Rooms"
                sourceImage: "qrc:/png/roomsSettings.png"
                widthImage: 36
                heightImage: 28
                pagePath: "qrc:/pages/roomsSettings.qml"
            }
        }
    }
}
