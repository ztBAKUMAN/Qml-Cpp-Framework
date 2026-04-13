import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Item {
    id: root
    anchors.fill: parent

    // 【核心逻辑 1：抽屉状态与宽度计算】
    property bool isDrawerOpen: true
    // 当抽屉打开时宽度 360，关闭时宽度 0
    property real drawerWidth: isDrawerOpen ? 360 : 0

    // 使用 Behavior 监听 drawerWidth 的变化，只要它变了，就自动用动画过渡！
    Behavior on drawerWidth {
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }

    RowLayout {
        anchors.fill: parent
        // 【细节】：间距也跟随宽度等比例缩小，保证合上时严丝合缝
        spacing: (root.drawerWidth / 360) * 20

        // ==========================================================
        // 左侧：OpenCV 视觉画面渲染区
        // ==========================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: mainWindow.isDarkTheme ? "#050508" : "#E5E5EA"
            border.color: mainWindow.theme.border
            border.width: 1
            radius: 8
            clip: true

            Text {
                text: "CAMERA 01 - 实时视频流\n(左侧画面会自动拉伸填满空白)"
                color: mainWindow.theme.textSub
                font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter; anchors.centerIn: parent; opacity: 0.5
            }

            // 简单的网格背景占位
            Grid { anchors.fill: parent; rows: 10; columns: 10; Repeater { model: 100; Rectangle { width: parent.width/10; height: parent.height/10; color: "transparent"; border.color: mainWindow.theme.accent; opacity: 0.05 } } }
        }

        // ==========================================================
        // 右侧：隐藏式数据抽屉层
        // ==========================================================
        Item {
            // 这个 Item 就是抽屉的“导轨”，它的宽度会从 360 动画缩小到 0
            Layout.preferredWidth: root.drawerWidth
            Layout.fillHeight: true
            // 【核心逻辑 2：裁剪遮罩】极其重要！宽度归零时，把超出的内容直接一刀切掉
            clip: true

            // 这是真正的抽屉实体
            Rectangle {
                // 【核心逻辑 3：防挤压魔法】
                // 实体宽度永远锁死在 360，不会因为导轨变窄而被挤压变形
                width: 360
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                // 让它永远贴紧导轨的最右侧。这样导轨变窄时，抽屉就像退回了屏幕边缘的墙壁里
                anchors.right: parent.right

                color: mainWindow.theme.panel
                border.color: mainWindow.theme.border
                border.width: 1
                radius: 8

                // --- 下面全是原来的数据逻辑，一字未改 ---
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Text { text: "实时检测参数"; color: mainWindow.theme.textMain; font.pixelSize: 18; font.bold: true }

                    GridLayout {
                        Layout.fillWidth: true; columns: 2; rowSpacing: 10; columnSpacing: 10
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 70; color: mainWindow.theme.subPanel; radius: 6; Column { anchors.centerIn: parent; Text { text: "检测帧率"; color: mainWindow.theme.textSub; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "59 FPS"; color: mainWindow.theme.accent; font.pixelSize: 24; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter } } }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 70; color: mainWindow.theme.subPanel; radius: 6; Column { anchors.centerIn: parent; Text { text: "当前良率"; color: mainWindow.theme.textSub; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "99.2 %"; color: "#00FF66"; font.pixelSize: 24; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter } } }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 70; color: mainWindow.theme.subPanel; radius: 6; Column { anchors.centerIn: parent; Text { text: "检测总数"; color: mainWindow.theme.textSub; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "12,450"; color: mainWindow.theme.accent; font.pixelSize: 24; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter } } }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 70; color: mainWindow.theme.subPanel; radius: 6; Column { anchors.centerIn: parent; Text { text: "缺陷拦截"; color: mainWindow.theme.textSub; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter } Text { text: "84"; color: "#FF3333"; font.pixelSize: 24; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter } } }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: mainWindow.theme.border }
                    Text { text: "近期缺陷抓拍"; color: mainWindow.theme.textMain; font.pixelSize: 18; font.bold: true }

                    ListModel { id: logModel }

                    ListView {
                        id: logListView
                        Layout.fillWidth: true; Layout.fillHeight: true
                        model: logModel; spacing: 8; clip: true

                        HoverHandler { id: listHover }
                        ScrollBar.vertical: ScrollBar {
                            opacity: listHover.hovered || pressed ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 300 } }
                        }

                        add: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 300 } }

                        Timer {
                            interval: 1500; running: true; repeat: true
                            onTriggered: {
                                let types = ["表面划痕", "边缘缺角", "异物残留"]
                                let levels = ["轻微", "严重"]
                                logModel.insert(0, { time: Qt.formatTime(new Date(), "hh:mm:ss"), type: types[Math.floor(Math.random()*types.length)], level: levels[Math.floor(Math.random()*levels.length)] })
                                if (logModel.count > 50) logModel.remove(50, 1)
                            }
                        }

                        delegate: Rectangle {
                            width: logListView.width; height: 60
                            color: mainWindow.theme.subPanel; radius: 4
                            border.color: model.level === "严重" ? "#55FF3333" : "transparent"; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 10
                                Rectangle { width: 40; height: 40; color: "#333"; radius: 4 }
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

    // ==========================================================
    // 悬浮触发器：永远贴在抽屉左侧的“窄边按钮”
    // ==========================================================
    Item {
        width: 30
        height: 100
        anchors.verticalCenter: parent.verticalCenter
        // 让按钮永远锚定在父级右侧，但向左偏移出抽屉的宽度！
        // 这样抽屉收进去时，它刚好贴在屏幕最右侧；抽屉拉出来时，它贴在抽屉左侧。
        anchors.right: parent.right
        anchors.rightMargin: root.drawerWidth

        // 捕捉鼠标悬浮
        HoverHandler {
            id: triggerHover
        }

        // 按钮本体
        Rectangle {
            anchors.fill: parent
            color: mainWindow.theme.accent
            // 只有鼠标悬浮时才出现，平时完全隐形，不打扰画面
            opacity: triggerHover.hovered ? 0.9 : 0.0
            Behavior on opacity { NumberAnimation { duration: 300 } }

            // 为了美观，做成左侧两个角是圆角的胶囊形状
            radius: 8
            Rectangle { width: 8; height: parent.height; anchors.right: parent.right; color: parent.color }

            Text {
                text: root.isDrawerOpen ? "▶" : "◀"
                color: "white"
                font.bold: true
                font.pixelSize: 16
                anchors.centerIn: parent
            }
        }

        // 点击事件
        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.isDrawerOpen = !root.isDrawerOpen
            }
        }
    }
}
