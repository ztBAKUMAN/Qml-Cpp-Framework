#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>         // 引入上下文头文件
#include <QQmlEngine>
#include <QQuickStyle>
#include "DeviceControllor.h"  // 引入控制器头文件

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling); // Qt5 推荐添加：开启高分屏支持
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    // Qt5 手动注册
    // 这样你在 QML 里就可以直接 import cppmodule.DeviceControllor 1.0 然后使用 DeviceControllor {} 实例化了
    qmlRegisterType<DeviceControllor>("cppmodule.DeviceControllor", 1, 0, "DeviceControllor");
    // 注意路径：我们将通过传统的 qrc 文件来管理资源
    const QUrl url(QStringLiteral("qrc:/ui/main.qml"));
#else
    // Qt6 依赖 CMake 自动注册，且支持 u""_qs 字面量
    QQuickStyle::setStyle("Basic");
    const QUrl url(u"qrc:/qmlproject/ui/main.qml"_qs);
#endif

    
#if QT_VERSION > QT_VERSION_CHECK(6, 0, 0)
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);
#else
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);
#endif
    return app.exec();
}
