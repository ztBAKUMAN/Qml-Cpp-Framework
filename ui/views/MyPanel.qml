import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import "../components"

Rectangle {
    anchors.fill: parent
    // 绑定全局面板底色
    color: mainWindow.theme.panel
    radius: 8

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        // 第一个卡片：使用统一的 padding
        CardPanel {
            Layout.preferredWidth: 300
            Layout.preferredHeight: 120
            padding: 20 // 一键设置四周内边距

            // 下面的 Rectangle 会自动被塞进 CardPanel 的内层安全区
            // 所以它的 anchors.fill: parent 实际上填满的是已经被挤压过的 innerContainer
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 1.0, 0, 0.2)
                border.color: "green"

                Text {
                    anchors.centerIn: parent
                    text: "这是卡片 1\n自动四周留白 20px"
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // 第二个卡片：单独定制某个方向的 padding
        CardPanel {
            Layout.preferredWidth: 300
            Layout.preferredHeight: 120
            padding: 10
            leftPadding: 40 // 左侧特意留出大空间，比如为了放一个悬浮的图标

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0.59, 1.0, 0.2)
                border.color: "#0096FF"

                Text {
                    anchors.centerIn: parent
                    text: "这是卡片 2\n左侧单独留白 40px"
                    color: "white"
                }
            }
        }
    }
}
