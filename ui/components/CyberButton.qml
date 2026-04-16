import QtQuick 2.12
import QtQuick.Controls 2.5

// 自定义组件可用 Item 作为一个透明的容器，方便我们在外部控制它的大小
Item {
    id: root

    // 暴露自定义属性
    property string text: "默认按钮"
    property color themeColor: "#00E5FF"

    // 内部实际显示的矩形按钮
    Rectangle {
        id: bgRect
        anchors.fill: parent
        color: "#1A1A24"
        border.color: root.themeColor
        border.width: 1
        radius: 4

        // 按钮上的文字
        Text {
            id: btnText
            text: root.text
            color: root.themeColor
            font.pixelSize: 18
            font.bold: true
            anchors.centerIn: parent
        }

        // 鼠标交互区域
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true // 开启悬浮检测（默认是关闭的）

            // 点击事件抛出（如果外部用了 onClicked 就会触发这里）
            onClicked: console.log("按钮被点击了: " + root.text)
        }

        // 定义按钮在不同交互下的“视觉状态”
        states: [
            State {
                name: "hovered"
                // 当鼠标悬浮且没有按下时，进入此状态
                when: mouseArea.containsMouse && !mouseArea.pressed
                // 在这个状态下，改变背景色和边框粗细
                PropertyChanges { target: bgRect; color: "#2A2A35"; border.width: 2 }
            },
            State {
                name: "pressed"
                // 当鼠标按下时，进入此状态
                when: mouseArea.pressed
                // 按下时稍微缩小一点点，产生物理按压感
                PropertyChanges { target: bgRect; scale: 0.95; color: root.themeColor }
                // 文字反色
                PropertyChanges { target: btnText; color: "#000000" }
            }
        ]

        // 过渡动画
        transitions: Transition {
            // NumberAnimation 专门用来让数字（比如缩放比例、边框粗细）产生丝滑变化
            NumberAnimation { properties: "scale, border.width"; duration: 150; easing.type: Easing.OutQuad }
            // ColorAnimation 专门用来让颜色平滑渐变
            ColorAnimation { properties: "color"; duration: 150 }
        }
    }
}
