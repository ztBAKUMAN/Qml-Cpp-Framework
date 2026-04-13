// MenuBar.qml
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Rectangle {
    id: root
    color: mainWindow.theme.subPanel

    // 发射带有目标 QML 文件名的信号
    signal pageRequested(string pageSource)

    // 【核心知识点：ListModel 数据模型】
    // 这里维护按钮的名称和对应的 QML 文件路径。未来想加多少个按钮，直接往这里添就行。
    ListModel {
        id: menuModel
        ListElement { btnName: "本机状态"; pageFile: "SystemStatusView.qml" }
        ListElement { btnName: "设备状态"; pageFile: "DeviceStatusView.qml" }
        ListElement { btnName: "实时监控"; pageFile: "VisionMonitorViewPlus.qml" }
        ListElement { btnName: "系统日志"; pageFile: "SystemLogView.qml" }
        ListElement { btnName: "用户管理"; pageFile: "UserManageView.qml" }
        ListElement { btnName: "其他设置"; pageFile: "OtherSettingsView.qml" }

        // 【新增】：复制几个凑数的，强行让总宽度超过窗口
        ListElement { btnName: "扩展模块A"; pageFile: "StateTest.qml" }
        ListElement { btnName: "扩展模块B"; pageFile: "MyPanel.qml" }
        ListElement { btnName: "扩展模块C"; pageFile: "SystemStatusView.qml" }
        ListElement { btnName: "扩展模块D"; pageFile: "SystemStatusView.qml" }
    }

    // 【核心知识点：ListView 触摸滑动列表】
    ListView {
        id: menuList
        anchors.fill: parent
        anchors.margins: 5

        model: menuModel
        orientation: ListView.Horizontal // 设置为水平排列、水平滑动
        spacing: 10
        clip: true // 裁切掉滑出边界的按钮

        // 物理滑动属性配置，让触摸屏手感更丝滑
        //        boundsBehavior: Flickable.StopAtBounds // 滑到边缘停止，不产生橡皮筋回弹拉扯
        flickableDirection: Flickable.HorizontalFlick // 仅允许水平滑动
        pressDelay: 100

        currentIndex: 0

        // Delegate：定义模型中每个数据的长相（即按钮的外观）
        delegate: Button {
            // 给定固定宽度。当所有按钮宽度总和超过屏幕时，ListView 就会自动允许手指滑动
            width: 160
            height: menuList.height
            text: model.btnName

            property bool isSelected: index === menuList.currentIndex

            background: Rectangle {
                color: parent.pressed ? mainWindow.theme.accent : (parent.hovered ? mainWindow.theme.border : "transparent")
                // 边框逻辑：选中或悬浮时显示青色边框，否则透明
                border.color: isSelected || parent.hovered ? mainWindow.theme.accent : "transparent"
                // 选中时边框稍微加粗一点，增强视觉反馈
                border.width: isSelected ? 2 : 1
                radius: 4
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: 18
                font.bold: isSelected ? true : false
                // 字体颜色逻辑：按下(黑) -> 选中或悬浮(青色) -> 默认(浅灰)
                color: parent.pressed ? "black" : (isSelected || parent.hovered ? mainWindow.theme.accent : mainWindow.theme.textSub)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // 点击时，提取模型里的 pageFile 发送出去
            onClicked: {
                menuList.currentIndex = index
                root.pageRequested(model.pageFile)
            }
        }
    }
}
