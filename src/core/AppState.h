#ifndef NUKESHORTCUTS_APPSTATE_H
#define NUKESHORTCUTS_APPSTATE_H

#include "core/Shortcut.h"

#include <QObject>
#include <QPointF>

// Las dos acciones que la app sabe hacer sobre Nuke.
enum class ShortcutAction { AddKeyframe, FrameDopeSheet };

// Estado de la app que ve el usuario: la UNICA fuente de verdad. La tarjeta de estado, el menu del
// tray, su encabezado y el icono leen de aca y escriben aca, asi no pueden quedar dos controles
// diciendo cosas distintas.
//
// Persistence::Settings lee y escribe settings.ini (AppSettings). Persistence::None no toca el
// disco nunca: es el de la captura --ui-shot y el de los modos de prueba.
class AppState : public QObject
{
    Q_OBJECT

public:
    enum class Persistence { Settings, None };

    // Que paso la ultima vez que se intento registrar el atajo de una accion.
    enum class Registration {
        Idle,       ///< no esta registrado porque no hace falta (Nuke no esta al frente, o en pausa)
        Registered, ///< registrado: la combinacion le llega a la app
        Failed,     ///< el sistema lo rechazo: otra app ya tiene esa combinacion
    };

    explicit AppState(Persistence persistence, QObject *parent = nullptr);

    // ---- Persistente
    bool enabled() const { return m_enabled; }
    bool checkUpdatesAtStartup() const { return m_checkUpdatesAtStartup; }
    Shortcut shortcut(ShortcutAction action) const;
    // Punto guardado del Dope Sheet, en fraccion de la ventana principal de Nuke (0..1 en x e y).
    bool hasDopeSheetSpot() const { return m_hasDopeSheetSpot; }
    QPointF dopeSheetSpot() const { return m_dopeSheetSpot; }

    // ---- De esta sesion
    bool nukeInFront() const { return m_nukeInFront; }
    Registration registration(ShortcutAction action) const;
    // Permiso de Accesibilidad de macOS. En Windows siempre true.
    bool accessibilityGranted() const { return m_accessibilityGranted; }

    // Cada setter escribe (si corresponde) y avisa SOLO si el valor cambio.
    void setEnabled(bool enabled);
    void setCheckUpdatesAtStartup(bool check);
    void setShortcut(ShortcutAction action, const Shortcut &shortcut);
    void setDopeSheetSpot(const QPointF &fraction);
    void setNukeInFront(bool inFront);
    void setRegistration(ShortcutAction action, Registration registration);
    void setAccessibilityGranted(bool granted);

    static QString actionTitle(ShortcutAction action);

signals:
    void changed();

private:
    void writeValue(const QString &key, const QVariant &value);

    Persistence m_persistence;
    bool m_enabled = true;
    bool m_checkUpdatesAtStartup = true;
    Shortcut m_addKeyframe = Shortcut::defaultAddKeyframe();
    Shortcut m_frameDopeSheet = Shortcut::defaultFrameDopeSheet();
    bool m_hasDopeSheetSpot = false;
    QPointF m_dopeSheetSpot;

    bool m_nukeInFront = false;
    Registration m_addKeyframeRegistration = Registration::Idle;
    Registration m_frameRegistration = Registration::Idle;
    bool m_accessibilityGranted = true;
};

#endif // NUKESHORTCUTS_APPSTATE_H
