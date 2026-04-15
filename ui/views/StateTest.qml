import QtQuick 2.12
import qmldemo 1.0 // 引入我们之前写的 C++ 模块
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Rectangle {
    anchors.fill: parent
    // 绑定全局面板底色
    color: mainWindow.theme.panel
    radius: 8

    Rectangle {
        anchors.centerIn: parent
        id: motorIndicator
        width: 200; height: 200
        radius: 100
        color: "gray" // 初始默认颜色

        // 假设这是我们的 C++ 后端控制器
        DeviceControllor { id: backend }

        Text {
            id: statusText
            anchors.centerIn: parent
            text: "未知"
            color: "white"
            font.pixelSize: 24
            font.bold: true
        }

        // ==========================================
        // 核心灵感 1：定义状态 (States)
        // ==========================================
        states: [
            State {
                name: "OfflineState"
                // 神奇的 when 关键字：只要 C++ 的枚举等于这个值，QML 自动无缝切入此状态
                when: backend.status === DeviceControllor.Offline
                // PropertyChanges 负责声明在这个状态下，UI 应该长什么样
                PropertyChanges { target: motorIndicator; color: "#6C757D"; scale: 1.0 }
                PropertyChanges { target: statusText; text: "设备离线" }
            },
            State {
                name: "IdleState"
                when: backend.status === DeviceControllor.Idle
                PropertyChanges { target: motorIndicator; color: "#0078D7"; scale: 1.0 }
                PropertyChanges { target: statusText; text: "待机中" }
            },
            State {
                name: "RunningState"
                when: backend.status === DeviceControllor.Running
                // 运行状态下，稍微放大一点点视觉体积
                PropertyChanges { target: motorIndicator; color: "#28A745"; scale: 1.1 }
                PropertyChanges { target: statusText; text: "运行中" }
            },
            State {
                name: "FaultState"
                when: backend.status === DeviceControllor.Fault
                PropertyChanges { target: motorIndicator; color: "#DC3545"; scale: 1.0 }
                PropertyChanges { target: statusText; text: "系统故障!" }
            }
        ]

        // ==========================================
        // 核心灵感 2：定义过渡动画 (Transitions)
        // ==========================================
        transitions: [
            Transition {
                // from: "*" 到 to: "*" 表示任意两个状态之间的切换，都使用下面这套动画
                from: "*"; to: "*"

                // QML 引擎会自动计算旧颜色到新颜色的差值，并在 300 毫秒内平滑过渡
                ColorAnimation { target: motorIndicator; duration: 300 }

                // 让 scale 的变化带有弹簧效果 (OutBack)
                NumberAnimation {
                    target: motorIndicator;
                    property: "scale";
                    duration: 300;
                    easing.type: Easing.OutBack
                }
            }
        ]

        // 模拟纯前端点击测试，你可以点它看看丝滑的动画效果
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (backend.status === DeviceControllor.Offline) backend.status = DeviceControllor.Idle
                else if (backend.status === DeviceControllor.Idle) backend.status = DeviceControllor.Running
                else if (backend.status === DeviceControllor.Running) backend.status = DeviceControllor.Fault
                else backend.status = DeviceControllor.Offline
            }
        }
    }

}

