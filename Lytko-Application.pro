QT += qml quick mqtt xml network widgets gui

CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
    appcore.cpp \
    main.cpp \

RESOURCES += \
            components.qrc \
            js.qrc \
            pages.qrc \
            images.qrc

TRANSLATIONS += \
    Lytko-Application_ru_RU.ts

CODECFORSRC     = UTF-8

QML_IMPORT_PATH =

QML_DESIGNER_IMPORT_PATH =

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    appcore.h \

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml \

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

