import QtQuick 2.12
import "qrc:/js/styles.js" as Styles

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
            bottomMargin: 58
        }

        radius: 5
    }
}
