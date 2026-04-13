import QtQuick 2.12
import QtQuick.Controls 2.5

// 【知识点：自定义组件】
// 最外层用 Item 作为一个透明的容器，方便我们在外部控制它的大小
Item {
    id: root // 【知识点：id】给这个组件起个唯一名字，方便内部互相调用

    // 【知识点：暴露自定义属性】
    // 定义外部可以修改的属性，这样在主界面调用时就可以随便改文字和颜色了
    property string text: "默认按钮"
    property color themeColor: "#00E5FF" // 默认荧光青色

    // 内部实际显示的矩形按钮
    Rectangle {
        id: bgRect
        anchors.fill: parent // 【知识点：锚点】填满整个根 Item
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

        // 【知识点：MouseArea 触摸/鼠标交互核心】
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true // 开启悬浮检测（默认是关闭的）

            // 点击事件抛出（如果外部用了 onClicked 就会触发这里）
            onClicked: console.log("按钮被点击了: " + root.text)
        }

        // 【知识点：状态机 States】
        // 游戏级 UI 的核心！定义按钮在不同交互下的“视觉状态”
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

        // 【知识点：过渡动画 Transitions】
        // 告诉引擎，当状态发生切换时，不要生硬地突变，而是用动画平滑过渡
        transitions: Transition {
            // NumberAnimation 专门用来让数字（比如缩放比例、边框粗细）产生丝滑变化
            NumberAnimation { properties: "scale, border.width"; duration: 150; easing.type: Easing.OutQuad }
            // ColorAnimation 专门用来让颜色平滑渐变
            ColorAnimation { properties: "color"; duration: 150 }
        }
    }
}
