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

QPixmap trayIconPixmap(bool paused)
{
    // El icono a color de la app, reducido con el filtro de QIcon. La version monocroma para la
    // barra de menu de macOS (modo template) sale del sistema de iconos LGA: pendiente en el roadmap.
    const QPixmap source = QIcon(QStringLiteral(":/icons/LGA_NukeShortcuts.png")).pixmap(QSize(64, 64));
    if (!paused) {
        return source;
    }
    QPixmap dimmed(source.size());
    dimmed.fill(Qt::transparent);
    QPainter painter(&dimmed);
    painter.setOpacity(0.4);
    painter.drawPixmap(0, 0, source);
    painter.end();
    return dimmed;
}
