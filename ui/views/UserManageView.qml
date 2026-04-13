import QtQuick 2.12

Rectangle {
    anchors.fill: parent
    color: mainWindow.theme.panel
    radius: 8

    Text {
        text: "这里是【用户管理】页面\n\n(显示可查看的用户信息)"
        color: mainWindow.theme.accent
        font.pixelSize: 36
        horizontalAlignment: Text.AlignHCenter
        anchors.centerIn: parent
    }
}
