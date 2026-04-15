#include "DeviceControllor.h"

DeviceControllor::DeviceControllor(QObject *parent) : QObject(parent), m_status(DeviceStatus::Idle)
{
}

DeviceControllor::~DeviceControllor()
{
}

void DeviceControllor::setStatus(DeviceStatus newStatus)
{
    if (m_status == newStatus) return;
        m_status = newStatus;
        emit statusChanged();
}

// 若链接错误需强制包含moc文件
// #include "moc_DeviceControllor.cpp"