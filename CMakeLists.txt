cmake_minimum_required(VERSION 3.16)
project(qmldemo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 先尝试找 Qt6，找不到再找 Qt5
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick)
# 找到后，动态加载对应的组件
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)

message(STATUS "当前使用的 Qt 主版本为: Qt ${QT_VERSION_MAJOR}")

set(CPP_SOURCES
    src/main.cpp
    src/DeviceControllor.cpp
)
set(INCLUDE_FILES
    src/include/DeviceControllor.h
)

if(QT_VERSION_MAJOR EQUAL 6)
#qt6构建
    qt_add_executable(appqmldemo ${CPP_SOURCES} ${INCLUDE_FILES})

    set(UI_COMPONENTS
        ui/components/CyberButton.qml
        ui/components/HeaderBar.qml
        ui/components/TitleBar.qml
        ui/components/MenuBar.qml
        ui/components/StatusBar.qml
        ui/components/CardPanel.qml
        ui/components/DataBox.qml
        ui/components/RoiHandle.qml
    )
    set(UI_VIEWS
        ui/views/SystemStatusView.qml
        ui/views/VisionMonitorView.qml
        ui/views/DeviceStatusView.qml
        ui/views/SystemLogView.qml
        ui/views/UserManageView.qml
        ui/views/OtherSettingsView.qml
        ui/views/VisionMonitorViewPlus.qml
        ui/views/VisionMonitorViewPro.qml
        ui/views/StateTest.qml
        ui/views/MyPanel.qml
    )
    qt_add_qml_module(appqmldemo
        URI qmldemo
        VERSION 1.0
        RESOURCE_PREFIX /   # 添加这一行！强制将模块挂载到 QRC 的根目录下
        QML_FILES
        ui/main.qml
        ${UI_COMPONENTS}
        ${UI_VIEWS}
    )

    target_link_libraries(appqmldemo
        PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
    )

else()
#qt5构建
    set(CMAKE_AUTORCC ON) # 开启 QRC 自动编译
    # 将 qml.qrc 加入编译列表 (确保你已经在根目录创建了该文件)
    set(QRC_SOURCES qml.qrc)
    add_executable(appqmldemo ${CPP_SOURCES} ${INCLUDE_FILES} ${QRC_SOURCES})
    
    target_link_libraries(appqmldemo PRIVATE 
        Qt5::Core Qt5::Gui Qt5::Qml Qt5::Quick Qt5::QuickControls2
    )

endif()

# 通用配置
target_include_directories(appqmldemo PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/include
)

set_target_properties(appqmldemo PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_compile_definitions(appqmldemo
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

