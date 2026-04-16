import QtQuick 2.12

Rectangle {
    id: root

    // 向外部暴露边距属性
    property int padding: 15 // 全局默认内边距
    property int leftPadding: padding
    property int rightPadding: padding
    property int topPadding: padding
    property int bottomPadding: padding

    // 默认外观
    color: "#2B2B2B"
    radius: 8
    border.color: "#3F3F3F"
    border.width: 1

    // 外部调用时，直接将内容放入 innerContainer 中
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
