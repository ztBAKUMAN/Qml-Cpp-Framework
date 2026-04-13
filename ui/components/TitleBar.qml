// TitleBar.qml
import QtQuick 2.12

Rectangle {
    id: root
    // 把 "#1A1A24" 换成 mainWindow.theme.panel
    color: mainWindow.theme.panel

    property string titleText: "未命名主控台"

    Text {
        text: root.titleText
        // 把 "#00E5FF" 换成 mainWindow.theme.accent
        color: mainWindow.theme.accent
        font.pixelSize: 32; font.bold: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left; anchors.leftMargin: 30
    }
}
