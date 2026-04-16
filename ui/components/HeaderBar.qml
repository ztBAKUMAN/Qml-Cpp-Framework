import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12

Item {
    id: root
    // 接收主窗口传来的真实状态
    property bool isMaximized: false

    // 绘制圆角背景
    Rectangle {
        anchors.fill: parent
        color: "#15151C"
        radius: root.isMaximized ? 0 : 10 // 顶部圆角
    }

    // 用一个没有圆角的矩形，盖住下半部分，实现“仅顶部圆角”
    Rectangle {
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        height: root.isMaximized ? parent.height : 10
        color: "#15151C"
    }

    // 拖拽
    MouseArea {
        anchors.fill: parent

        // 记录鼠标按下的初始坐标
        property point clickPos: "0,0"

        // 双击时，直接判断原生 visibility 并调用原生方法
        onDoubleClicked: {
            if (Window.window.visibility === Window.Maximized) {
                Window.window.showNormal()
            } else {
                Window.window.showMaximized()
            }
        }
        // 记录初始坐标点
        onPressed: { 
            if (mouse.button === Qt.LeftButton) {
                clickPos = Qt.point(mouse.x, mouse.y)
            }
        }

        // 根据鼠标位移手动更新原生窗口坐标
        onPositionChanged: {
            if (mouse.buttons & Qt.LeftButton) {
                Window.window.x += (mouse.x - clickPos.x)
                Window.window.y += (mouse.y - clickPos.y)
            }
        }
    }

    // 右上角按钮保持不变
    Row {
        anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom
        Button {
            text: "—"; width: 40; height: parent.height
            background: Rectangle { color: parent.hovered ? "#333" : "transparent" }
            contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            onClicked: Window.window.showMinimized()
        }
        Button {
            text: root.isMaximized ? "❐" : "☐"; width: 40; height: parent.height
            background: Rectangle { color: parent.hovered ? "#333" : "transparent" }
            contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            // 点击时，直接调用原生方法
            onClicked: {
                if (Window.window.visibility === Window.Maximized) {
                    Window.window.showNormal()
                } else {
                    Window.window.showMaximized()
                }
            }
        }
        Button {
            text: "✕"; width: 40; height: parent.height

            background: Rectangle {
                // 父背景颜色逻辑不变
                color: parent.hovered ? "#E81123" : "transparent"
                radius: root.isMaximized ? 0 : 10

                // 把左上角、左下角的圆弧盖成直角
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.radius
                    color: parent.color
                    visible: !root.isMaximized
                }

                // 把左下角、右下角的圆弧盖成直角
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.radius
                    color: parent.color
                    visible: !root.isMaximized
                }
            }

            contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            onClicked: Window.window.close()
        }
    }
}
