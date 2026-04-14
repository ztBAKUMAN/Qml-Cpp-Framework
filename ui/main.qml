import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import "./components"
import "./views"

Window {
    id: mainWindow
    width: 1280; height: 800
    visible: true
    flags: Qt.Window | Qt.FramelessWindowHint
    //    color: "#0D0D12"
    color: "transparent"

    // 【核心修复】：删除原来的 property bool isMaximized: false
    // 换成下面这句！这叫“派生属性绑定”，只要窗口 visibility 变了，它自动变 true/false
    readonly property bool isMaximized: mainWindow.visibility === Window.Maximized

    // 定义一个布尔值来记录当前模式
    property bool isDarkTheme: true

    // 将所有颜色统一管理。利用三元运算符，当 isDarkTheme 变化时，所有颜色自动重算
    property QtObject theme: QtObject {
        // 主背景色
        property color bg: isDarkTheme ? "#0D0D12" : "#F0F0F5"
        // 面板/栏目底色
        property color panel: isDarkTheme ? "#1A1A24" : "#FFFFFF"
        // 次级面板底色（如菜单栏）
        property color subPanel: isDarkTheme ? "#222230" : "#E8E8ED"
        // 主文字颜色
        property color textMain: isDarkTheme ? "#FFFFFF" : "#333333"
        // 次文字颜色
        property color textSub: isDarkTheme ? "#CCCCCC" : "#666666"
        // 高亮强调色（夜间荧光青，白天工业蓝）
        property color accent: isDarkTheme ? "#00E5FF" : "#007ACC"
        // 边框颜色
        property color border: isDarkTheme ? "#333344" : "#33FFFFFF"

    }

    Rectangle {
        id: rootBg
        anchors.fill: parent
        radius: mainWindow.isMaximized ? 0 : 10
        color: mainWindow.theme.bg
        border.color: mainWindow.theme.border
        border.width: mainWindow.isMaximized ? 0 : 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 1. 呼叫头部层
            HeaderBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                isMaximized: mainWindow.isMaximized
            }

            // 2. 呼叫标题层，并赋予具体文字
            TitleBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                titleText: "RK3588 边缘视觉控制中枢"
            }

            // 3. 呼叫菜单层，并监听它的信号
            MenuBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 60

                // 【核心架构魔法：信号捕捉与路由】
                // 捕捉菜单发出的信号
                onPageRequested: {
                                     console.log("准备切换到界面: " + pageSource)
                                     // 直接让第四层的 Loader 加载对应的 QML 文件
                                     contentLoader.source = "views/" + pageSource
                                 }
            }

            // 4. 内容层 (直接内嵌 Loader 即可)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    anchors.margins: 20
                    // 程序启动时，默认加载第一个页面
                    source: "views/SystemStatusView.qml"
                }
            }

            // 5. 呼叫状态层
            StatusBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                isMaximized: mainWindow.isMaximized
                statusMessage: "通信模块已启动 | OpenCV 引擎待命中"
            }
        }

    }
}
