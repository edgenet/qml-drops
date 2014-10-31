
#include <QQmlExtensionPlugin>

#include <qqml.h>

#include "qml_drops.h"


class ZMQPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")
    
public:
    void registerTypes(const char *uri)
    {
        qmlRegisterType<Drops> (uri, 1, 0, "Drops");
        qmlRegisterType<DropsAttached>();
    };
};
