#include "tray/TrayMenu.h"

#include <QAction>
#include <QIcon>
#include <QMenu>
#include <QPainter>

TrayMenuActions buildTrayMenu(QMenu *menu)
{
    // Estilo: bloque QMenu de Theme (paleta de LGA_Base_QT_C_Py/docs/Doc_MenuContextual.md).
    TrayMenuActions a;
    a.header = menu->addAction(QString());
    a.header->setEnabled(false);
    a.toggle = menu->addAction(QString());
    menu->addSeparator();
    a.settings = menu->addAction(QStringLiteral("Settings..."));
    a.calibrate = menu->addAction(QStringLiteral("Calibrate Dope Sheet..."));
    a.updates = menu->addAction(QStringLiteral("Check for Updates..."));
#ifndef Q_OS_WIN
    a.updates->setVisible(false);
#endif
    menu->addSeparator();
    a.quit = menu->addAction(QStringLiteral("Quit"));
    return a;
}

void refreshTrayMenu(const TrayMenuActions &actions, bool enabled)
{
    actions.header->setText(enabled ? QStringLiteral("Nuke Shortcuts · On") : QStringLiteral("Nuke Shortcuts · Paused"));
    actions.toggle->setText(enabled ? QStringLiteral("Pause shortcuts") : QStringLiteral("Resume shortcuts"));
}

QIcon trayIcon(bool paused)
{
    // Un PNG por tamano (tools/icono/armar_tray.ps1): las planchas caen en pixeles enteros en cada uno
    // y QIcon elige el que corresponde a la escala de la pantalla. Reducir el icono de la app dejaba el
    // desregistro en menos de un pixel, un halo finito y borroso. La version monocroma para la barra de
    // menu de macOS (modo template) sale del sistema de iconos LGA: pendiente en el roadmap.
    QIcon icon;
    for (int size : {16, 20, 24, 32, 40, 48}) {
        const QPixmap source(QStringLiteral(":/icons/tray/tray_%1.png").arg(size));
        if (!paused) {
            icon.addPixmap(source);
            continue;
        }
        QPixmap dimmed(source.size());
        dimmed.fill(Qt::transparent);
        QPainter painter(&dimmed);
        painter.setOpacity(0.4);
        painter.drawPixmap(0, 0, source);
        painter.end();
        icon.addPixmap(dimmed);
    }
    return icon;
}
