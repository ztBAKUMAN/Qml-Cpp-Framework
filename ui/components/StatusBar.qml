import QtQuick 2.12
import QtQuick.Layouts 1.12

Item {
    id: root
    property string statusMessage: "系统就绪"
    property bool isMaximized: false

    // 绘制圆角背景
    Rectangle {
        anchors.fill: parent
        color: "#007ACC"
        radius: root.isMaximized ? 0 : 10 // 底部圆角

        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            height: parent.radius
            color: parent.color
            visible: !root.isMaximized
        }
    }

    RowLayout {
        anchors.fill: parent; anchors.leftMargin: 15; anchors.rightMargin: 15
        Text { text: root.statusMessage; color: "white"; font.pixelSize: 14; Layout.alignment: Qt.AlignLeft }
        Item { Layout.fillWidth: true }
        Text { id: timeLabel; color: "white"; font.pixelSize: 14; Layout.alignment: Qt.AlignRight }
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: timeLabel.text = Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss")
        Component.onCompleted: timeLabel.text = Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss")
    }
}
