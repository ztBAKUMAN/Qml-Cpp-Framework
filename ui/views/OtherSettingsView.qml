// OtherSettingsView.qml
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Rectangle {
    anchors.fill: parent
    // 绑定全局面板底色
    color: mainWindow.theme.panel
    radius: 8

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 30

        // 页面标题
        Text {
            text: "个性化与界面外观"
            color: mainWindow.theme.textMain
            font.pixelSize: 28
            font.bold: true
        }

        // 分割线
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: mainWindow.theme.border
        }

        Text {
            text: "色彩模式"
            color: mainWindow.theme.textSub
            font.pixelSize: 18
        }

        // 模式选择卡片区
        RowLayout {
            spacing: 20

            // 黑夜模式按钮
            Rectangle {
                width: 180; height: 120
                color: "#1A1A24" // 内部固定显示为黑夜风格的示意色
                border.color: mainWindow.isDarkTheme ? mainWindow.theme.accent : mainWindow.theme.border
                border.width: mainWindow.isDarkTheme ? 3 : 1
                radius: 8

                Text { text: "🌙 黑夜模式"; color: "white"; font.pixelSize: 18; anchors.centerIn: parent }

                MouseArea {
                    anchors.fill: parent
                    onClicked: mainWindow.isDarkTheme = true // 切换全局变量
                }
            }

            // 白天模式按钮
            Rectangle {
                width: 180; height: 120
                color: "#FFFFFF" // 内部固定显示为白天风格的示意色
                border.color: !mainWindow.isDarkTheme ? mainWindow.theme.accent : mainWindow.theme.border
                border.width: !mainWindow.isDarkTheme ? 3 : 1
                radius: 8

                Text { text: "☀️ 白天模式"; color: "#333333"; font.pixelSize: 18; anchors.centerIn: parent }

                MouseArea {
                    anchors.fill: parent
                    onClicked: mainWindow.isDarkTheme = false // 切换全局变量
                }
            }
        }

        Item { Layout.fillHeight: true } // 弹簧占位，把内容顶上去
    }
}
