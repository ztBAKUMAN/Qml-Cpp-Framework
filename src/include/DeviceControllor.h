#ifndef DEVICECONTROLLOR_H
#define DEVICECONTROLLOR_H

#include <QObject>
#include <QtGlobal> // 必须引入以获取版本宏

// 仅在 Qt6 环境下包含注册头文件
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    #include <QtQml/qqmlregistration.h>
#endif

class DeviceControllor : public QObject {
    Q_OBJECT
// 仅在 Qt6 环境下启用自动化注册宏
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    QML_ELEMENT
#endif

public:
    // 1. 正常的 C++ 枚举定义
    enum class DeviceStatus {
        Offline = 0,
        Idle = 1,
        Running = 2,
        Fault = 3
    };
    // 2. 核心魔法宏：向 Qt 元对象系统注册这个枚举
    Q_ENUM(DeviceStatus)

    // 3. 将其作为属性暴露给 QML
    Q_PROPERTY(DeviceStatus status READ status WRITE setStatus NOTIFY statusChanged)

public:
    explicit DeviceControllor(QObject *parent = nullptr);
    ~DeviceControllor();

    inline DeviceStatus status() const { return m_status; }
    void setStatus(DeviceStatus newStatus);

signals:
    void statusChanged();

private:
    DeviceStatus m_status;
};

#endif
