import QtQuick 2.12

Rectangle {
    anchors.fill: parent
    color: mainWindow.theme.panel
    radius: 8

    Text {
        text: "这里是【设备状态】页面\n\n(展示设备部件运行状态)"
        color: mainWindow.theme.accent
        font.pixelSize: 36
        horizontalAlignment: Text.AlignHCenter
        anchors.centerIn: parent
    }
}
