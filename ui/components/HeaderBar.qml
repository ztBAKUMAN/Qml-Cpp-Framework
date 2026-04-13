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

    // 【核心魔法：补齐下半部分】用一个没有圆角的矩形，盖住下半部分，实现“仅顶部圆角”
    Rectangle {
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        height: root.isMaximized ? parent.height : 10
        color: "#15151C"
    }

    // 拖拽逻辑保持不变
    MouseArea {
        anchors.fill: parent
        // 【核心修复】：双击时，直接判断原生 visibility 并调用原生方法
        onDoubleClicked: {
            if (Window.window.visibility === Window.Maximized) {
                Window.window.showNormal()
            } else {
                Window.window.showMaximized()
            }
        }
        onPressed: (mouse) => { if (mouse.button === Qt.LeftButton) Window.window.startSystemMove() }
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
            text: Window.window.isMaximized ? "❐" : "☐"; width: 40; height: parent.height
            background: Rectangle { color: parent.hovered ? "#333" : "transparent" }
            contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            // 【核心修复】：点击时，直接调用原生方法
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

                // 【完美修正 1：补齐整个左侧】把左上角、左下角的圆弧盖成直角
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.radius
                    color: parent.color // 直接跟随外层 Rectangle 的颜色，极其优雅
                    visible: !root.isMaximized // 最大化时全是直角，不需要显示补丁
                }

                // 【完美修正 2：补齐整个底部】把左下角、右下角的圆弧盖成直角
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
