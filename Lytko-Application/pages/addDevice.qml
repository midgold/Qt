import QtQuick 2.12
import QtQuick.Controls 2.12
import "qrc:/js/styles.js" as Styles

Rectangle {

    Component.onCompleted: {
        appCore.setActivePage("addDevice")
    }

    anchors.fill: parent
    color: Styles.dark
    Image {
        source: "qrc:/png/plus.png"
        anchors.centerIn: parent
        height: 40
        width: 40
        smooth: true
        antialiasing: true
    }

}

