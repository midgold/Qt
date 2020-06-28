import QtQuick 2.14
import QtQuick.Controls 2.12
import "../js/styles.js" as Styles

Popup {

    Connections
    {
        target: appCore

        onChangePopupData:
        {
            idDeviceLabel.text = idDevice
            zoneIdLabel.text = zoneId
            targetTempLabel.text = targetTemp
            currentTempLabel.text = currentTemp
            hBtn.color = hState === "1" ? Styles.red : Styles.dark
            hBtnStateLabel.text = hState
            deviceName.text = name

            if(parseInt(relay)) {
                arrowTempAnim.start()
            } else {
                arrowTempAnim.stop()
                arrowTemp.opacity=0
            }
        }
    }

    Component.onCompleted: {
        appCore.setActivePage("thermostatSettings")
    }

    function pressIconAnimation(imageId, iconName) {
        plusPressedAnim.target = imageId
        plusReleasedAnim.target = imageId

        plusPressedAnim.from = "qrc:/png/" + iconName + ".png"
        plusPressedAnim.to = "qrc:/png/pressed/" + iconName + ".png"

        plusReleasedAnim.from = "qrc:/png/pressed/" + iconName + ".png"
        plusReleasedAnim.to = "qrc:/png/" + iconName + ".png"
    }


    id: popup
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    anchors.centerIn: Overlay.overlay
    width: parent.width - 5
    height: contentHeight + 70

    background: Item {}

    contentItem: Rectangle {

        color: Styles.gray
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 20

        PropertyAnimation {
            id: plusPressedAnim
            properties: "source"
            duration: 100

            onStopped: {
                plusReleasedAnim.start()
            }
        }
        PropertyAnimation {
            id: plusReleasedAnim
            properties: "source"
            duration: 100
        }

        PropertyAnimation {
            id: arrowTempAnim
            target: arrowTemp
            properties: "opacity"
            duration: 2000
            from: 0
            to: 1
            loops: Animation.Infinite
            easing {type: Easing.InOutCubic}
        }

        Column {
            anchors.fill: parent
            anchors.topMargin: 20
            Text {
                id: deviceName
                font {
                    bold: true
                    pointSize: 20
                    family: 'Roboto'
                }
                color: Styles.white
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: idDeviceLabel
                visible: false
            }
            Text {
                id: zoneIdLabel
                visible: false
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5
                    Text {
                        id: currentTempLabel
                        color: Styles.white
                        font {
                            pointSize: 30
                            family: 'Roboto'
                            weight: Font.Light
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Image {
                        id: arrowTemp
                        source: "qrc:/png/tempArrow.png"
                        smooth: true
                        antialiasing: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: 20
                        width: 30
                    }
                    Text {
                        id: hBtn
                        text: "H"
                        font {
                            bold: true
                            pointSize: 20
                            family: 'Roboto'
                        }
                        anchors.horizontalCenter: parent.horizontalCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var heating = hBtnStateLabel.text === "0" ? 1 : 0;
                                appCore.sendMqttMessage(idDeviceLabel.text + "/set/heating", heating);
                            }
                        }
                    }
                    Text {
                        id: hBtnStateLabel
                        visible: false
                        enabled: false
                    }
                }
                Text {
                    id: targetTempLabel
                    font {
                        pointSize: 100
                        family: 'Roboto'
                        weight: Font.Light
                    }
                    color: Styles.white
                }
                Image {
                    source: "qrc:/png/celsius.png"
                    smooth: true
                    antialiasing: true
                    height: 90
                    width: 25
                    anchors.verticalCenter: parent.verticalCenter
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20
                    Image {
                        id: tempUp
                        signal pressSignal(var imageId, string iconName)

                        source: "qrc:/png/tempUp.png"
                        smooth: true
                        antialiasing: true
                        height: 40
                        width: 40

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                appCore.sendMqttMessage(idDeviceLabel.text + "/set/tempUp", 1);
                                tempUp.pressSignal.connect(pressIconAnimation)
                                tempUp.pressSignal(tempUp, "tempUp")
                                plusPressedAnim.start()
                            }
                        }
                    }
                    Image {
                        id: tempDown
                        signal pressSignal(var imageId, string iconName)

                        source: "qrc:/png/tempDown.png"
                        smooth: true
                        antialiasing: true
                        height: 40
                        width: 40

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                appCore.sendMqttMessage(idDeviceLabel.text + "/set/tempDown", 1);
                                tempDown.pressSignal.connect(pressIconAnimation)
                                tempDown.pressSignal(tempDown, "tempDown")
                                plusPressedAnim.start()
                            }
                        }
                    }
                }
            }
            // СКРИПТЫ. ДОБАВЯТСЯ ПОЗЖЕ
//            Text {
//                text: qsTr("Add script")
//                font {
//                    bold: true
//                    pointSize: 20
//                    family: 'Roboto'
//                }
//                color: Styles.white
//                anchors.horizontalCenter: parent.horizontalCenter
//            }
//            Rectangle {
//                height: 50
//                width: 50
//                color: Styles.dark
//                radius: 10
//                anchors.horizontalCenter: parent.horizontalCenter
//                Image {
//                    id: addScriptIcon
//                    signal pressSignal(var imageId, string iconName)

//                    height: 30
//                    width: 30
//                    source: "qrc:/png/plus.png"
//                    smooth: true
//                    antialiasing: true
//                    anchors.centerIn: parent
//                }

//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        addScriptIcon.pressSignal.connect(pressIconAnimation)
//                        addScriptIcon.pressSignal(addScriptIcon, "plus")
//                        plusPressedAnim.start()
//                    }
//                }
//            }
        }
    }
}



