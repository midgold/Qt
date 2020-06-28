import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Window 2.14
import Qt.labs.settings 1.0

ApplicationWindow {
    width: 1920 //375
    height: 1080//812
    title: qsTr("Lytko App")
    visible: true
    id: mainWindow
    Grid {
        spacing: 1
        columns: 1920
        anchors.fill: parent
        Repeater {
            model: 200000
            Rectangle {
                color:  Qt.rgba(Math.random(),Math.random(),Math.random(),1);
                height: 1
                width: 1
            }
        }
    }
}


