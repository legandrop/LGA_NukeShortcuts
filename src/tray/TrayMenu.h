#ifndef NUKESHORTCUTS_TRAYMENU_H
#define NUKESHORTCUTS_TRAYMENU_H

#include <QIcon>

class QAction;
class QMenu;

// Acciones del menu de la bandeja (Windows) o de la barra de menu (macOS, donde el menu es nativo y
// el QSS no le llega).
struct TrayMenuActions
{
    QAction *header = nullptr;    // "Nuke Shortcuts · On|Paused", deshabilitado
    QAction *toggle = nullptr;    // Pause shortcuts / Resume shortcuts
    QAction *settings = nullptr;
    QAction *calibrate = nullptr;
    QAction *updates = nullptr;   // solo Windows
    QAction *quit = nullptr;
};

// Arma el menu (lo usan TrayController y la captura de QA, para que sean el mismo menu).
TrayMenuActions buildTrayMenu(QMenu *menu);
void refreshTrayMenu(const TrayMenuActions &actions, bool enabled);

// Icono de la bandeja: los dos keys con el desregistro ajustado al pixel, atenuado en pausa.
QIcon trayIcon(bool paused);

#endif // NUKESHORTCUTS_TRAYMENU_H
