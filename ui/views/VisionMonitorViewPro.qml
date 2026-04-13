import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Item {
    id: root
    anchors.fill: parent

    // 抽屉状态保持不变
    property bool isDrawerOpen: true
    property real drawerWidth: isDrawerOpen ? 360 : 0
    Behavior on drawerWidth { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

    RowLayout {
        anchors.fill: parent
        spacing: (root.drawerWidth / 360) * 20

        // ==========================================================
        // 左侧：OpenCV 视觉画面渲染区 (在这里实装 ROI 功能)
        // ==========================================================
        Rectangle {
            id: videoPlaceholder
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: mainWindow.isDarkTheme ? "#050508" : "#E5E5EA"
            border.color: mainWindow.theme.border
            border.width: 1
            radius: 8
            // [极其重要]：必须开启裁剪，保证内部元素不溢出
            clip: true

            Text {
                text: "CAMERA 01 - 实时视频流\n\n[用鼠标在此区域绘制和调整 ROI]"
                color: mainWindow.theme.textSub; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter; anchors.centerIn: parent; opacity: 0.3
            }

            // 网格背景保持不变
            Grid { anchors.fill: parent; rows: 10; columns: 10; Repeater { model: 100; Rectangle { width: parent.width/10; height: parent.height/10; color: "transparent"; border.color: mainWindow.theme.accent; opacity: 0.05 } } }

            // ==========================================================
            // 【核心实装：鼠标自由拖拽缩放的 ROI 选择框】
            // ==========================================================

            // [逻辑层]：用一个普通的 Item 作为 ROI 数据的根
            Item {
                id: roiHandler
                // 给个默认位置和大小 (比如居中，占画面 30%)
                x: parent.width * 0.3
                y: parent.height * 0.3
                width: parent.width * 0.3
                height: parent.height * 0.3

                // 设置最小尺寸约束，防止缩得太小找不到了
                property real minW: 50
                property real minH: 50

                // [视觉层]：展示 ROI 的外观
                Rectangle {
                    id: roiRect
                    anchors.fill: parent
                    // 使用极具辨识度的“工控紫”
                    color: "#1AFF00FF" // 半透明紫填充
                    border.color: "#FF00FF"
                    border.width: 2

                    // 只有鼠标悬浮在 ROI 上时才显示角落把手
                    property bool showHandles: handlerHover.hovered || mouseAreaBody.pressed

                    HoverHandler {
                        id: handlerHover
                    }

                    // --- 逻辑：处理 ROI 主体的拖拽移动 ---
                    MouseArea {
                        id: mouseAreaBody
                        anchors.fill: parent
                        // 设置光标为十字移动形状
                        cursorShape: Qt.SizeAllCursor

                        // 记录按下时的初始鼠标位置 (相对于父级)
                        property point clickPos: "0,0"

                        onPressed: (mouse) => clickPos = Qt.point(mouse.x, mouse.y)

                        onPositionChanged: (mouse) => {
                                               if (!pressed) return;

                                               // 计算偏移量
                                               let deltaX = mouse.x - clickPos.x
                                               let deltaY = mouse.y - clickPos.y

                                               // 计算新位置
                                               let nextX = roiHandler.x + deltaX
                                               let nextY = roiHandler.y + deltaY

                                               // [逻辑核心]：应用边界限制！(x: 0 ~ 画面宽-自己宽)
                                               roiHandler.x = Math.max(0, Math.min(nextX, videoPlaceholder.width - roiHandler.width))
                                               roiHandler.y = Math.max(0, Math.min(nextY, videoPlaceholder.height - roiHandler.height))
                                           }
                    }
                }

                // --- [逻辑层]：封装一个把手组件，用于在 4 个角上复用 ---
                component RoiHandle: Rectangle {
                    id: handleItem
                    property int edgeX: 0 // -1: 左, 1: 右
                    property int edgeY: 0 // -1: 上, 1: 下

                    width: 10; height: 10; color: "white"; border.color: "#FF00FF"; border.width: 1
                    // 默认隐形，外部判定显示时才出现
                    opacity: roiRect.showHandles ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -5 // 扩大可操作区域，方便触摸

                        // 【完美修复】：必须把光标形状定义在 MouseArea 里面！
                        // 并且使用 handleItem.edgeX 明确指代外部属性
                        cursorShape: {
                            if (handleItem.edgeX * handleItem.edgeY > 0) return Qt.SizeBDiagCursor // 左上, 右下
                            if (handleItem.edgeX * handleItem.edgeY < 0) return Qt.SizeFDiagCursor // 右上, 左下
                            return Qt.ArrowCursor
                        }

                        onPositionChanged: (mouse) => {
                                               if (!pressed) return;

                                               // [数学逻辑核心]：处理边缘缩放
                                               // 将把手相对于自己的鼠标坐标，映射到 videoPlaceholder 这个大的坐标系中
                                               let mappedPt = mapToItem(videoPlaceholder, mouse.x, mouse.y);

                                               // 如果控制的是右边缘 (edgeX == 1)
                                               if (handleItem.edgeX === 1) {
                                                   let newW = mappedPt.x - roiHandler.x
                                                   // 限制：不能小于最小宽，不能超出画面右边缘
                                                   roiHandler.width = Math.max(roiHandler.minW, Math.min(newW, videoPlaceholder.width - roiHandler.x))
                                               }
                                               // 如果控制的是左边缘 (edgeX == -1)
                                               else if (handleItem.edgeX === -1) {
                                                   let oldRight = roiHandler.x + roiHandler.width
                                                   // 限制：最左到 0，最右不能挤压超过最小宽度的位置
                                                   let targetX = Math.max(0, Math.min(mappedPt.x, oldRight - roiHandler.minW))
                                                   roiHandler.x = targetX
                                                   // 重新计算宽度 (保持右边缘不动)
                                                   roiHandler.width = oldRight - targetX
                                               }

                                               // 下边缘 (edgeY == 1)
                                               if (handleItem.edgeY === 1) {
                                                   let newH = mappedPt.y - roiHandler.y
                                                   roiHandler.height = Math.max(roiHandler.minH, Math.min(newH, videoPlaceholder.height - roiHandler.y))
                                               }
                                               // 上边缘 (edgeY == -1)
                                               else if (handleItem.edgeY === -1) {
                                                   let oldBottom = roiHandler.y + roiHandler.height
                                                   let targetY = Math.max(0, Math.min(mappedPt.y, oldBottom - roiHandler.minH))
                                                   roiHandler.y = targetY
                                                   roiHandler.height = oldBottom - targetY
                                               }
                                           }
                    }
                }

                // --- [视觉层]：实例化四个角落把手 ---
                // 左上
                RoiHandle { anchors.centerIn: parent.topLeft; edgeX: -1; edgeY: -1 }
                // 右上
                RoiHandle { anchors.centerIn: parent.topRight; edgeX: 1; edgeY: -1 }
                // 右下
                RoiHandle { anchors.centerIn: parent.bottomRight; edgeX: 1; edgeY: 1 }
                // 左下
                RoiHandle { anchors.centerIn: parent.bottomLeft; edgeX: -1; edgeY: 1 }
            }
        }

        // ==========================================================
        // 右侧：隐藏式数据抽屉层 (在此显示 ROI 数据反馈)
        // ==========================================================
        Item {
            Layout.preferredWidth: root.drawerWidth; Layout.fillHeight: true; clip: true
            Rectangle {
                width: 360; anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.right: parent.right
                color: mainWindow.theme.panel; border.color: mainWindow.theme.border; border.width: 1; radius: 8

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 15; spacing: 15

                    // --- 模块 1：核心状态网格 (在此显示 ROI 精准数据) ---
                    Text { text: "ROI 参数反馈"; color: mainWindow.theme.textMain; font.pixelSize: 18; font.bold: true }

                    GridLayout {
                        Layout.fillWidth: true; columns: 2; rowSpacing: 10; columnSpacing: 10

                        // 使用 JS 数学函数取整，防止显示小数
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 60; color: mainWindow.theme.subPanel; radius: 6; Column { anchors.centerIn: parent; Text { text: "X 坐标"; color: mainWindow.theme.textSub; font.pixelSize: 12 } Text { text: Math.round(roiHandler.x); color: "#FF00FF"; font.pixelSize: 20; font.bold: true } } }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 60; color: mainWindow.theme.subPanel; radius: 6; Column { anchors.centerIn: parent; Text { text: "Y 坐标"; color: mainWindow.theme.textSub; font.pixelSize: 12 } Text { text: Math.round(roiHandler.y); color: "#FF00FF"; font.pixelSize: 20; font.bold: true } } }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 60; color: mainWindow.theme.subPanel; radius: 6; Column { anchors.centerIn: parent; Text { text: "宽度"; color: mainWindow.theme.textSub; font.pixelSize: 12 } Text { text: Math.round(roiHandler.width); color: "#FF00FF"; font.pixelSize: 20; font.bold: true } } }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 60; color: mainWindow.theme.subPanel; radius: 6; Column { anchors.centerIn: parent; Text { text: "高度"; color: mainWindow.theme.textSub; font.pixelSize: 12 } Text { text: Math.round(roiHandler.height); color: "#FF00FF"; font.pixelSize: 20; font.bold: true } } }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: mainWindow.theme.border }

                    // 下方日志保持不变
                    Text { text: "近期缺陷抓拍"; color: mainWindow.theme.textMain; font.pixelSize: 18; font.bold: true }
                    ListModel { id: logModel }
                    ListView { id: logListView; Layout.fillWidth: true; Layout.fillHeight: true; model: logModel; spacing: 8; clip: true; HoverHandler { id: listHover } ScrollBar.vertical: ScrollBar { opacity: listHover.hovered || pressed ? 1.0 : 0.0; Behavior on opacity { NumberAnimation { duration: 300 } } } add: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 300 } } Timer { interval: 1500; running: true; repeat: true; onTriggered: { let types = ["表面划痕", "边缘缺角"]; let levels = ["严重"]; logModel.insert(0, { time: Qt.formatTime(new Date(), "hh:mm:ss"), type: types[Math.floor(Math.random()*types.length)], level: levels[Math.floor(Math.random()*levels.length)] }); if (logModel.count > 50) logModel.remove(50, 1) } } delegate: Rectangle { width: logListView.width; height: 60; color: mainWindow.theme.subPanel; radius: 4; border.color: "#55FF3333"; border.width: model.level === "严重" ? 1 : 0; RowLayout { anchors.fill: parent; anchors.margins: 10; Rectangle { width: 40; height: 40; color: "#333"; radius: 4 }
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: model.type; color: "#FF3333"; font.pixelSize: 16; font.bold: true }
                                    Text { text: model.time; color: mainWindow.theme.textSub; font.pixelSize: 12 }
                                }
                            } } }
                }
            }
        }
    }

    // 悬浮触发器保持不变
    Item { width: 30; height: 100; anchors.verticalCenter: parent.verticalCenter; anchors.right: parent.right; anchors.rightMargin: root.drawerWidth; HoverHandler { id: triggerHover } Rectangle { anchors.fill: parent; color: mainWindow.theme.accent; opacity: triggerHover.hovered ? 0.9 : 0.0; Behavior on opacity { NumberAnimation { duration: 300 } } radius: 8; Rectangle { width: 8; height: parent.height; anchors.right: parent.right; color: parent.color } Text { text: root.isDrawerOpen ? "▶" : "◀"; color: "white"; font.bold: true; font.pixelSize: 16; anchors.centerIn: parent } } MouseArea { anchors.fill: parent; onClicked: { root.isDrawerOpen = !root.isDrawerOpen } } }
}
