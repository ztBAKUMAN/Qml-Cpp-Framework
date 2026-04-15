cmake_minimum_required(VERSION 3.16)
project(qmldemo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# 生成 compile_commands.json 供 clangd 使用
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 先尝试找 Qt6，找不到再找 Qt5
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick)
# 找到后，动态加载对应的组件
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)

message(STATUS "当前使用的 Qt 主版本为: Qt ${QT_VERSION_MAJOR}")

# 收集 src 下的所有 cpp 文件
file(GLOB CPP_SOURCES "src/*.cpp")
# 使用 GLOB 自动匹配所有 .qml 文件
file(GLOB UI_COMPONENTS "ui/components/*.qml")
file(GLOB UI_VIEWS "ui/views/*.qml")
# 匹配js脚本文件
file(GLOB JS_FILES "ui/scripts/*.js")

if(QT_VERSION_MAJOR EQUAL 6)
#qt6构建
    qt_add_executable(appqmldemo ${CPP_SOURCES})

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
    add_executable(appqmldemo ${CPP_SOURCES} ${QRC_SOURCES})
    
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

