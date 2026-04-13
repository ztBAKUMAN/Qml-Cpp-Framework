import QtQuick 2.12

Rectangle {
    id: root

    // ==========================================
    // 1. 暴露给外部的 Padding 接口
    // ==========================================
    property int padding: 15 // 全局默认内边距
    property int leftPadding: padding
    property int rightPadding: padding
    property int topPadding: padding
    property int bottomPadding: padding

    // ==========================================
    // 2. 卡片的默认视觉外观 (可被外部覆盖)
    // ==========================================
    color: "#2B2B2B"       // 工业风深色背景
    radius: 8              // 圆角
    border.color: "#3F3F3F"
    border.width: 1

    // ==========================================
    // 3. 【核心魔法】：重定向默认属性
    // 只要别人在 CardPanel {} 大括号里写的子组件，
    // 全部会被 QML 引擎自动“拦截”，并塞进 innerContainer 的 data 列表中！
    // ==========================================
    default property alias content: innerContainer.data

    // 内部真实的承载区
    Item {
        id: innerContainer
        anchors.fill: parent

        // 利用 anchors.margins 将内部容器向中心挤压，实现 padding
        anchors.leftMargin: root.leftPadding
        anchors.rightMargin: root.rightPadding
        anchors.topMargin: root.topPadding
        anchors.bottomMargin: root.bottomPadding
    }
}
