import QtQuick 2.12
import QtQuick.Layouts 1.12
Rectangle {
    property string title: ""
    property string val: ""
    property color valColor: mainWindow.theme.accent

    Layout.fillWidth: true; Layout.preferredHeight: 70
    color: mainWindow.theme.subPanel; radius: 6

    Column {
        anchors.centerIn: parent
        Text { text: parent.parent.title; color: mainWindow.theme.textSub; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter }
        Text { text: parent.parent.val; color: parent.parent.valColor; font.pixelSize: 24; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
    }
}