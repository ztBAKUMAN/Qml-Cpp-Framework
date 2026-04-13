// VisionMonitorView.qml
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Item {
    id: root
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        spacing: 20

        // ==========================================================
        // 左侧：OpenCV 视觉画面渲染区 (自适应拉伸占满剩余空间)
        // ==========================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: mainWindow.isDarkTheme ? "#050508" : "#E5E5EA" // 比主面板更深的纯净底色
            border.color: mainWindow.theme.border
            border.width: 1
            radius: 8
            clip: true

            // 1. 画面占位提示文本
            Text {
                text: "CAMERA 01 - 实时视频流\n(等待 C++ OpenCV 图像帧接入...)"
                color: mainWindow.theme.textSub
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                anchors.centerIn: parent
                opacity: 0.5
            }

            // 2. 模拟 AI 科技感网格线 (仅装饰)
            Grid {
                anchors.fill: parent
                rows: 10; columns: 10
                Repeater {
                    model: 100
                    Rectangle {
                        width: parent.width / 10; height: parent.height / 10
                        color: "transparent"
                        border.color: mainWindow.theme.accent
                        opacity: 0.05 // 极淡的网格
                    }
                }
            }

            // 3. 模拟动态 AI 缺陷捕获框 (呼吸闪烁效果)
            Rectangle {
                x: parent.width * 0.3; y: parent.height * 0.4 // 随便放个位置
                width: 180; height: 120
                color: "#22FF3333" // 半透明红色填充
                border.color: "#FF3333"
                border.width: 2

                Label {
                    text: "⚠️ 划痕缺陷 (98.5%)"
                    color: "white"
                    font.pixelSize: 14; font.bold: true
                    background: Rectangle { color: "#FF3333" }
                    anchors.bottom: parent.top // 贴在框的顶部外面
                    anchors.left: parent.left
                }
                //                Rectangle {
                //                    color: "#FF3333"
                //                    // 尺寸可以写死，或者自适应内部 Text 的大小
                //                    width: innerText.width + 10; height: innerText.height + 4

                //                    Text {
                //                        id: innerText
                //                        text: "⚠️ 划痕缺陷 (98.5%)"
                //                        color: "white"
                //                        anchors.centerIn: parent
                //                    }
                //                }

                // 给捕获框加一个持续的呼吸缩放动画
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.05; duration: 500; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                }
            }
        }

        // ==========================================================
        // 右侧：数据看板与日志区 (固定宽度 360)
        // ==========================================================
        Rectangle {
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            color: mainWindow.theme.panel
            border.color: mainWindow.theme.border
            border.width: 1
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // --- 模块 1：核心状态网格 (GridLayout) ---
                Text { text: "实时检测参数"; color: mainWindow.theme.textMain; font.pixelSize: 18; font.bold: true }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 10; columnSpacing: 10

                    // 封装一个小组件来展示数据块
                    component DataBox: Rectangle {
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

                    DataBox { title: "检测帧率"; val: "59 FPS" }
                    DataBox { title: "当前良率"; val: "99.2 %"; valColor: "#00FF66" }
                    DataBox { title: "检测总数"; val: "12,450" }
                    DataBox { title: "缺陷拦截"; val: "84"; valColor: "#FF3333" }
                }

                // 分割线
                Rectangle { Layout.fillWidth: true; height: 1; color: mainWindow.theme.border }

                // --- 模块 2：实时缺陷抓拍流 (ListView) ---
                Text { text: "近期缺陷抓拍 (最大保留 20 条)"; color: mainWindow.theme.textMain; font.pixelSize: 18; font.bold: true }

                // 初始的日志数据模型
                ListModel {
                    id: logModel
                    ListElement { time: "14:22:10"; type: "表面划痕"; level: "严重" }
                    ListElement { time: "14:21:05"; type: "边缘缺角"; level: "轻微" }
                }

                ListView {
                    id: logListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: logModel
                    spacing: 8
                    clip: true

                    // 【核心逻辑 1：悬浮侦测幽灵】
                    HoverHandler {
                        id: listHover
                    }

                    // 【核心逻辑 2：自定义渐变滚动条】
                    ScrollBar.vertical: ScrollBar {
                        id: vScrollBar
                        // 显隐逻辑：鼠标悬浮在列表上，或者正按着滚动条拖拽时，显示；否则隐藏
                        opacity: listHover.hovered || vScrollBar.pressed ? 1.0 : 0.0
                        // 加上透明度的丝滑渐变动画
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        // 自定义滚动条的“胶囊”外观
                        contentItem: Rectangle {
                            implicitWidth: 6
                            implicitHeight: 40
                            radius: width / 2
                            // 按下时变成高亮青色，平时是深灰色
                            color: vScrollBar.pressed ? mainWindow.theme.accent : (mainWindow.isDarkTheme ? "#555566" : "#AAAAAA")
                        }
                    }

                    // 【修复报错 2：使用 Qt6 标准的 Transition 属性来处理入场动画】
                    // 把它写在 ListView 层级，而不是 delegate 层级
                    add: Transition {
                        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 300 }
                    }

                    // 【核心逻辑 3：模拟后端实时推送的定时器】
                    Timer {
                        interval: 1500 // 每 1.5 秒来一条新报警
                        running: true
                        repeat: true
                        onTriggered: {
                            // 随机生成假数据
                            let types = ["表面划痕", "边缘缺角", "异物残留", "丝印模糊", "尺寸超差"]
                            let levels = ["轻微", "中等", "严重"]
                            let randType = types[Math.floor(Math.random() * types.length)]
                            let randLevel = levels[Math.floor(Math.random() * levels.length)]
                            let timeStr = Qt.formatTime(new Date(), "hh:mm:ss")

                            // 关键点 A：插入到最顶部 (index: 0)，而不是追加到底部。
                            // 这样操作员永远第一眼看到最新的报警，不需要手动往下拉。
                            logModel.insert(0, { time: timeStr, type: randType, level: randLevel })

                            // 关键点 B：内存保护机制。如果超过 20 条，删掉最底下那条老数据。
                            if (logModel.count > 20) {
                                logModel.remove(20, 1)
                            }
                        }
                    }

                    delegate: Rectangle {
                        width: logListView.width; height: 60
                        color: mainWindow.theme.subPanel
                        border.color: model.level === "严重" ? "#55FF3333" : "transparent"
                        border.width: 1
                        radius: 4

                        RowLayout {
                            id: delegateItem
                            anchors.fill: parent; anchors.margins: 10

                            Rectangle { width: 40; height: 40; color: "#333"; radius: 4; Text { text: "IMG"; color: "#666"; font.pixelSize: 10; anchors.centerIn: parent } }

                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                Text { text: model.type; color: model.level === "严重" ? "#FF3333" : mainWindow.theme.textMain; font.pixelSize: 16; font.bold: true }
                                Text { text: model.time; color: mainWindow.theme.textSub; font.pixelSize: 12 }
                            }

                            Text { text: model.level; color: model.level === "严重" ? "#FF3333" : "#FFaa00"; font.pixelSize: 14; font.bold: true }
                        }
                    }
                }
            }
        }
    }
}
