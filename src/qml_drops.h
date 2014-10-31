
#ifndef QML_DROPS_H
#define QML_DROPS_H

#include <QtQml>

#include <drops.h>


class Drops;

class DropsAttached : public QObject
{
    Q_OBJECT
    
    QObject* m_attached;
    
public:
    
    DropsAttached(QObject* attached) { m_attached = attached; };
    
public slots:
    
    void selfTest(bool verbose) {
        return drops_test(verbose);
    };
};


class Drops : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QString path READ path WRITE setPath)
    Q_PROPERTY(bool running READ running)
    
    QString m_path;
    bool m_running;
    
public slots:
    
    QString path() { return m_path; };
    void setPath(const QString &path) {
        m_path = path;
        if(m_running)
            start();
    };
    
    bool running() { return m_running; };
    
private:
    
    drops_t* self;
    
public slots:
    
    void start() {
        drops_destroy(&self);
        self = drops_new(m_path.toLatin1().data());
        m_running = !!self;
    };
    
    void stop() {
        drops_destroy(&self);
        m_running = false;
    }
    
public:
    
    Drops() {
        m_path = QString("/tmp/drops"); // Default path, to be overriden by user
        m_running = false;
        
        self = NULL;
    };
    
    ~Drops() {
        stop();
    };
    
    static QObject* qmlAttachedProperties(QObject* object) {
        return new DropsAttached(object);
    }
};


QML_DECLARE_TYPEINFO(Drops, QML_HAS_ATTACHED_PROPERTIES)

#endif
