#ifndef NUKESHORTCUTS_UPDATEDIALOG_H
#define NUKESHORTCUTS_UPDATEDIALOG_H

#include <QString>

class QDialog;
class QWidget;

// Dialogo "Update Available" de UpdateService, armado aparte para que --ui-shot lo pueda dibujar
// sin UpdateService ni QNetworkAccessManager. Accept = "Update now", reject = "Later".
QDialog *createUpdateAvailableDialog(QWidget *parent, const QString &displayName, const QString &version,
                                     const QString &currentVersion);

#endif // NUKESHORTCUTS_UPDATEDIALOG_H
