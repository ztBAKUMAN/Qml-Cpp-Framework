Rectangle {
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