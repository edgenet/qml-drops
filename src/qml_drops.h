
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
  
  QString m_path;
  
public slots:
  
  QString path() { return m_path; };
  void setPath(const QString &path) {
    m_path = path;
    if(running)
      start();
  };
  
private:
  
  drops_t* self;
  bool running;
  
public slots:
  
  void start() {
    drops_destroy(&self);
    self = drops_new(m_path.toLatin1().data());
    running = true;
  };
  
  void stop() {
    drops_destroy(&self);
    running = false;
  }
  
public:
  
  Drops() {
    m_path = QString("/tmp/drops"); // Default path, to be overriden by user
    
    self = NULL;
    start();
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
