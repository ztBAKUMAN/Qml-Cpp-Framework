import QtQuick 2.12

Rectangle {
    anchors.fill: parent
    color: mainWindow.theme.panel
    radius: 8

    Text {
        text: "这里是【本机状态】页面\n\n(未来展示 CPU、内存、网络信息)"
        color: mainWindow.theme.accent
        font.pixelSize: 36
        horizontalAlignment: Text.AlignHCenter
        anchors.centerIn: parent
    }
}
