import QtQuick 2.0
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import "qrc:/js/styles.js" as Styles

Rectangle {
    property alias text: btnText.text
    property bool isActive: true

    Text {
        id: btnText
        text: ""
        anchors.centerIn: parent
        color: Styles.white
    }
    
    height: 30
    width: 95
    color: "transparent"
    border.color: isActive ? Styles.blue : Styles.dark
}
