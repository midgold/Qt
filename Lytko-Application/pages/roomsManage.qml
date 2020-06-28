import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3

import "../components"
import "../js/styles.js" as Styles

Rectangle
{
    id: back
    color: Styles.dark

    Rectangle {
        color: Styles.gray
        anchors {
            fill:parent
            topMargin: 8
            leftMargin: 8
            rightMargin: 8
            bottomMargin: addNewRoomMode ? 68 : 58
        }

        radius: 5

        id: manageRoomContainer

        SwipeView {
            id: roomsSwipe
            currentIndex: 1
            anchors {
                topMargin: 20
                fill: parent
            }

            ListView {

                clip: true

                model: roomsList

                delegate: Column {
                    width: parent.width - 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Text {
                        id: manageRoomHeader
                        text: qsTr(roomName)
                        y: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pointSize: 18
                        font.bold: true
                        color: Styles.white
                    }
                    Rectangle
                    {
                        color: Styles.dark
                        height: 25
                        width: parent.width - 20
                        anchors.horizontalCenter: parent.horizontalCenter

                        TextInput
                        {
                            id: roomNameInput
                            echoMode: TextInput.Normal
                            color: Styles.dark
                            font.pixelSize: 10
                            anchors.fill: parent
                            anchors.leftMargin: 5
                            anchors.topMargin: 5
                            Text {
                                text: qsTr("Enter new room name")
                                color: "gray"
                                anchors {
                                    left: parent.left
                                    leftMargin: 5
                                }
                                font {
                                    italic: true
                                    pointSize: 10
                                }
                            }
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

                        Repeater {
                            model: ["qrc:/png/kitchen.png", "qrc:/png/kitchen.png", "qrc:/png/kitchen.png"]

                            Image {
                                source: modelData
                                height: 25
                                width: 20
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



                                delegate: Item {
                                    id: deviceItem
                                    //  signal wifiClick(string name)

                                    height: 10
                                    Row {
                                        spacing: 10

                                        Image {
                                            //source: setWifiSignalIcon(signal)
                                            height: 15
                                            width: 20
                                            anchors.verticalCenter: parent.verticalCenter
                                            smooth: true
                                            antialiasing: true
                                        }

                                        Text {
                                            text: name
                                            color: Styles.white
                                            font.pointSize: 10
                                            verticalAlignment: Text.AlignVCenter
                                            font.family: 'Roboto'
                                            MouseArea {
                                                anchors.fill: parent
                                                //                                        onClicked: {
                                                //                                            wifiItem.wifiClick.connect(clickHandler)
                                                //                                            wifiItem.wifiClick(name)
                                                //                                            popup.open()
                                                //                                        }
                                            }
                                        }
                                    }
                                }
                                 model: devicesList
                            }
                        }
                    }

                }
            }
        }
    }



    Footer {
        id: footer
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
                    stack.pop();
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
                }
            }
        }
    }
}
