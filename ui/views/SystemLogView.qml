import QtQuick 2.12

Rectangle {
    anchors.fill: parent
    color: mainWindow.theme.panel
    radius: 8

    Text {
        text: "这里是【系统日志】页面\n\n(显示系统运行中记录的日志信息)"
        color: mainWindow.theme.accent
        font.pixelSize: 36
        horizontalAlignment: Text.AlignHCenter
        anchors.centerIn: parent
    }
}
