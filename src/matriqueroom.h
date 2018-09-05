#ifndef MATRIQUEROOM_H
#define MATRIQUEROOM_H

#include "room.h"

#include <QObject>
#include <QTimer>

using namespace QMatrixClient;

class MatriqueRoom : public Room {
  Q_OBJECT
  Q_PROPERTY(bool hasUsersTyping READ hasUsersTyping NOTIFY typingChanged)
  Q_PROPERTY(QString usersTyping READ getUsersTyping NOTIFY typingChanged)
  Q_PROPERTY(QString cachedInput READ cachedInput WRITE setCachedInput NOTIFY
                 cachedInputChanged)
 public:
  explicit MatriqueRoom(Connection* connection, QString roomId,
                        JoinState joinState = {});

  const QString& cachedInput() const { return m_cachedInput; }
  void setCachedInput(const QString& input) {
    if (input != m_cachedInput) {
      m_cachedInput = input;
      emit cachedInputChanged();
    }
  }

  bool hasUsersTyping();
  QString getUsersTyping();

  QString lastEvent();

 private:
  QString m_cachedInput;

  QString getMIME(const QUrl& fileUrl) const;
  void postFile(const QUrl& localFile, const QUrl& mxcUrl);

 signals:
  void cachedInputChanged();

 public slots:
  void chooseAndUploadFile();
  void saveFileAs(QString eventId);
  void acceptInvitation();
  void forget();
  void sendTypingNotification(bool isTyping);
};

#endif  // MATRIQUEROOM_H