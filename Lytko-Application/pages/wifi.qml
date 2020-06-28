import QtQuick 2.0
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import "../components"
import "../js/styles.js" as Styles

Container {
    id: wifiPage

    function clickHandler(name) {
        popupWifiName.text = name
    }
    function setWifiSignalIcon(signal) {
        if(signal > 70)
            return "qrc:/png/wifi/wifi3.png"
        else if(signal > 40)
            return "qrc:/png/wifi/wifi2.png"
        else if(signal > 10)
            return "qrc:/png/wifi/wifi1.png"
        else
            return "qrc:/png/wifi/wifi0.png"
    }

    HandlerMqtt {

    }

    Component.onCompleted: {
        appCore.setFooter(false);
        appCore.setActivePage("wifi")

        let currentWifiObj;
        let scanWifiArr;
        try {
            currentWifiObj = JSON.parse(storage.value("currentWifi")).current_wifi;
            currentName.text = currentWifiObj.name;
            currentSignalIcon.source = setWifiSignalIcon(parseInt(currentWifiObj.signal));

            scanWifiArr = JSON.parse(storage.value("scanWifi")).wifi_networks;
            wifiList.clear();
            for(let w = 0; w < scanWifiArr.length; w++)
            {
                let scanWifiObj = {
                    "name": scanWifiArr[w].ssid,
                    "signal": parseInt(scanWifiArr[w].signal)
                }
                wifiList.append(scanWifiObj);
            }
        } catch(e) {
            wifiList.append({
                                "name": "No available Wi-Fi",
                                "signal": 0
                            });
        }
    }

    Text {
        id: header
        y: 20
        text: "Wi-Fi"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 18
        font.bold: true
        color: Styles.white
    }

    Column {
        anchors {
            top: header.bottom
            right: parent.right
            left: parent.left
            margins: 6
        }

        spacing: 10

        Text {
            id: connectedName

            text: qsTr("Connected")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 12
            color: Styles.white
        }
        Rectangle {
            id: currentContainer
            border.color: Styles.dark
            color: Styles.gray
            height: 50
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            Image {
                id: currentSignalIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10

                height: 15
                width: 20
                smooth: true
                antialiasing: true
            }
            Text {
                id: currentName
                text: ""
                anchors.verticalCenter: parent.verticalCenter
                color: Styles.blue
                font.pointSize: 15
                font.family: 'Roboto'
                font.bold: true
                anchors.left: currentSignalIcon.right
                anchors.leftMargin: 10
            }
        }
        // НА БУДУЩЕЕ
//        Button {
//            id: disconnectBtn
//            text: qsTr("Disconnect")
//            anchors.horizontalCenter: parent.horizontalCenter
//            MouseArea {
//                anchors.fill: parent
//                onClicked: {
//                    var wifiDisconnectObj = {
//                        "wifi_disconnect": {
//                            ssid: currentName.text
//                        }
//                    };
//                    appCore.sendMqttMessage("lytko/wifi/disconnect", JSON.stringify(wifiDisconnectObj));
//                }
//            }
//        }

        Text {
            id: available
            text: qsTr("Available networks")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 12
            color: Styles.white
        }

        Rectangle {
            border.color: Styles.dark
            color: Styles.gray
            height: wifiList.count * 33
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
                    id: signalIcon
                    clip: true
                    anchors {
                        fill: parent
                        margins: 10
                    }

                    spacing: 20

                    delegate: Item {
                        id: wifiItem
                        signal wifiClick(string name)

                        height: 10
                        Row {
                            spacing: 10

                            Image {
                                source: setWifiSignalIcon(signal)
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
                                    onClicked: {
                                        wifiItem.wifiClick.connect(clickHandler)
                                        wifiItem.wifiClick(name)
                                        popup.open()
                                    }
                                }
                            }
                        }
                    }
                    model: wifiList
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

    ListModel {
        id: wifiList
    }

    Popup {
        id: popup
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        anchors.centerIn: Overlay.overlay
        height: parent.height/4
        width: parent.width - 30

        background: Item {}

        contentItem: Rectangle {
            id: popupContent
            anchors.fill: parent
            color: Styles.gray
            radius: 5

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: 15
                    verticalCenter: parent.verticalCenter
                }
                spacing: 10
                Text {
                    id: popupWifiName
                    color: Styles.white
                    font {
                        family: 'Roboto'
                        weight: Font.Light
                        pointSize: 14
                    }
                }

                Text {
                    text: "Password"
                    color: Styles.white
                    font {
                        family: 'Roboto'
                        weight: Font.Light
                        pointSize: 14
                    }
                }
                Rectangle
                {
                    color: Styles.dark

                    height: 25
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    TextInput {
                        id: inputPass
                        echoMode: TextInput.Password
                        color: Styles.white
                        font.pixelSize: 12
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.topMargin: 5
                    }
                }
                Button {
                    text: qsTr("Connect")
                    isActive: true
                    anchors.horizontalCenter: parent.horizontalCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var wifiConnectObj = {
                                "wifi_connect": {
                                    ssid: popupWifiName.text,
                                    password: inputPass.text
                                }
                            };
                            appCore.sendMqttMessage("lytko/wifi/connect", JSON.stringify(wifiConnectObj));
                            popup.close();
                        }
                    }
                }
            }
        }
    }
}






