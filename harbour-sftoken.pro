# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-sftoken

CONFIG += sailfishapp

include(../stoken_main/stoken_lib/stoken_lib.pri)

SOURCES += src/harbour-sftoken.cpp \
    src/stokencommon.cpp

OTHER_FILES += qml/harbour-sftoken.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-sftoken.changes.in \
    rpm/harbour-sftoken.spec \
    rpm/harbour-sftoken.yaml \
    translations/*.ts \
    harbour-sftoken.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
# CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
#TRANSLATIONS += translations/harbour-sftoken-de.ts

unix:!macx: LIBS += -L$$PWD/lib/ -lstoken_lib
unix:!macx: LIBS += -L$$PWD/lib/ -lnettle
unix:!macx: LIBS += -L$$PWD/lib/ -lhogweed
unix:!macx: LIBS += -L$$PWD/lib/ -lgmp
unix:!macx: LIBS += -lxml2

INCLUDEPATH += $$PWD/''
DEPENDPATH += $$PWD/''

LibFiles.path = /usr/share/harbour-sftoken/lib
LibFiles.files += $$files(lib/*.so.*)

INSTALLS += LibFiles

DISTFILES += \
    qml/pages/ImportToken.qml \
    qml/pages/MainView.qml \
    lib/libstoken_lib.so.1 \
    harbour-sftoken.pro.user \
    icons/108x108/harbour-sftoken.png \
    icons/128x128/harbour-sftoken.png \
    icons/256x256/harbour-sftoken.png \
    icons/86x86/harbour-sftoken.png \
    qml/harbour-sftoken.png \
    qml/pages/AboutPage.qml \
    qml/components/PinDialog.qml

HEADERS += \
    src/stokencommon.h
