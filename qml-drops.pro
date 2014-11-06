
TEMPLATE = lib

CONFIG += plugin
QT += qml quick

TARGET = $$qtLibraryTarget(dropsplugin)
uri = org.edgenet.drops

DESTDIR   = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
SRCDIR    = $$PWD/src
BUILDDIR  = $$PWD/build/native

android {
  # Use a default value assuming the drops project sits alongside this one
  isEmpty(DROPS_ROOT) {
    DROPS_ROOT = $$clean_path($$PWD/../drops)
  }
  !exists($$DROPS_ROOT) {
    error(The DROPS_ROOT directory does not exist: \"$$DROPS_ROOT\")
  }
  # Build the drops library for android unless it is already built
  !system($$DROPS_ROOT/builds/qt-android/build.sh) {
    error(Failed to build the drops C library with $$DROPS_ROOT/builds/qt-android/build.sh)
  }
  
  VENDOR_PREFIX = $$DROPS_ROOT/builds/qt-android/prefix/$(TOOLCHAIN_NAME)
  BUILDDIR  = $$PWD/build/$(TOOLCHAIN_NAME)
  QMAKE_LIBDIR += $$VENDOR_PREFIX/lib
  QMAKE_INCDIR += $$VENDOR_PREFIX/include
}

LIBS += -ldrops

HEADERS += $$SRCDIR/dropsplugin.h  \
           $$SRCDIR/qml_drops.h

OBJECTS_DIR = $$BUILDDIR/.obj
MOC_DIR     = $$BUILDDIR/.moc
RCC_DIR     = $$BUILDDIR/.rcc
UI_DIR      = $$BUILDDIR/.ui

target.path  = $$DESTDIR
qmldir.files = $$PWD/qmldir
qmldir.path  = $$DESTDIR

OTHER_FILES += $$SRCDIR/qmldir \
               $$SRCDIR/qml/*

INSTALLS    += target qmldir

# Copy the qmldir file to the same folder as the plugin binary
QMAKE_POST_LINK += \
  $$QMAKE_COPY $$replace($$list($$quote($$SRCDIR/qmldir) $$DESTDIR), /, $$QMAKE_DIR_SEP)

# Copy the dependency shared libraries to the plugin folder (on android only)
android {
  QMAKE_POST_LINK += \
  && $$QMAKE_COPY $$replace($$list($$quote($$VENDOR_PREFIX/lib/*.so)  $$DESTDIR), /, $$QMAKE_DIR_SEP)
}
