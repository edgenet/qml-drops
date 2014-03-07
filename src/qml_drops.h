
#ifndef QML_DROPS_H
#define QML_DROPS_H

#include <QtQml>

#include <drops.h>


class Drops : public QThread
{
  Q_OBJECT
  void _() {};
  
  Q_PROPERTY(QString path READ path WRITE setPath)
  
  QString m_path;
  
  drops_t*  service = NULL;
  
  zctx_t*  kill_ctx = NULL;
  void*   kill_sock = NULL;
  void* killer_sock = NULL;
  
  void new_service() {
    if(service) drops_destroy(&service);
    service = drops_new(m_path.toLatin1().data());
  }
  
public:
  
  Drops() {
    m_path = QString("/tmp/drops"); // Default path, to be overriden by user
    
    kill_ctx = zctx_new();
    
    killer_sock = zsocket_new(kill_ctx, ZMQ_PUSH);
    kill_sock   = zsocket_new(kill_ctx, ZMQ_PULL);
    
    zsocket_bind(killer_sock,  "inproc://kill");
    zsocket_connect(kill_sock, "inproc://kill");
  }
  
  ~Drops() {
    zsocket_destroy(kill_ctx, killer_sock);
    zsocket_destroy(kill_ctx, kill_sock);
    
    zctx_destroy(&kill_ctx);
  }
  
public slots:
  
  QString path() { return m_path; }
  void setPath(const QString& p) { m_path = p; new_service(); }
  
  void start() {
    if(!service) new_service();
    QThread::start();
  };
  
  void stop() {
    zstr_send(killer_sock, "KILL");
    wait();
  }
  
private:
  
  void run() Q_DECL_OVERRIDE {
    qDebug() << "Running...";
    
    void* drops_sock = drops_socket(service);
    
    zpoller_t* poller = zpoller_new(drops_sock, kill_sock, NULL);
    
    while (true) {
      void* which = zpoller_wait(poller, -1);
      
      if(which == drops_socket(service)) {
        zmsg_t* msg = drops_recv(service);
        zmsg_dump(msg);
        zmsg_destroy(&msg);
      }
      else if(which == kill_sock) {
        zstr_recv(kill_sock);
        break;
      }
      else {
        qWarning() << "Error while polling in thread" \
                   << QThread::currentThread();
        break;
      }
    }
    
    qDebug() << "Done.";
    
    exit(0);
  }
  
};

#endif
