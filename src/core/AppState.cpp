#include "core/AppState.h"
#include "core/AppSettings.h"

#include <QDebug>
#include <QVariant>

namespace {

const QString kEnabled = QStringLiteral("enabled");
const QString kCheckUpdates = QStringLiteral("checkUpdatesAtStartup");
const QString kAddKeyframe = QStringLiteral("shortcuts/addKeyframe");
const QString kFrameDopeSheet = QStringLiteral("shortcuts/frameDopeSheet");
const QString kSpotX = QStringLiteral("dopeSheet/x");
const QString kSpotY = QStringLiteral("dopeSheet/y");

bool validFraction(double value)
{
    return value >= 0.0 && value <= 1.0;
}

} // namespace

AppState::AppState(Persistence persistence, QObject *parent)
    : QObject(parent)
    , m_persistence(persistence)
{
    if (m_persistence != Persistence::Settings) {
        return;
    }
    const auto settings = AppSettings::open();
    m_enabled = settings->value(kEnabled, true).toBool();
    m_checkUpdatesAtStartup = settings->value(kCheckUpdates, true).toBool();

    // Un atajo ilegible en el .ini (editado a mano, o de una version futura) vuelve al de fabrica
    // en vez de dejar la accion sin atajo.
    const Shortcut addKeyframe = Shortcut::fromPortableString(settings->value(kAddKeyframe).toString());
    if (addKeyframe.isValid()) {
        m_addKeyframe = addKeyframe;
    }
    const Shortcut frame = Shortcut::fromPortableString(settings->value(kFrameDopeSheet).toString());
    if (frame.isValid()) {
        m_frameDopeSheet = frame;
    }

    bool okX = false;
    bool okY = false;
    const double x = settings->value(kSpotX).toDouble(&okX);
    const double y = settings->value(kSpotY).toDouble(&okY);
    if (okX && okY && validFraction(x) && validFraction(y)) {
        m_hasDopeSheetSpot = true;
        m_dopeSheetSpot = QPointF(x, y);
    }
    qInfo() << "[AppState] Cargado:" << (m_enabled ? "activo" : "en pausa")
            << "| Add keyframe:" << m_addKeyframe.toPortableString()
            << "| Frame Dope Sheet:" << m_frameDopeSheet.toPortableString()
            << "| punto del Dope Sheet:" << (m_hasDopeSheetSpot ? QStringLiteral("%1, %2").arg(x).arg(y)
                                                                  : QStringLiteral("sin calibrar"));
}

Shortcut AppState::shortcut(ShortcutAction action) const
{
    return action == ShortcutAction::AddKeyframe ? m_addKeyframe : m_frameDopeSheet;
}

AppState::Registration AppState::registration(ShortcutAction action) const
{
    return action == ShortcutAction::AddKeyframe ? m_addKeyframeRegistration : m_frameRegistration;
}

QString AppState::actionTitle(ShortcutAction action)
{
    return action == ShortcutAction::AddKeyframe ? QStringLiteral("Add keyframe") : QStringLiteral("Frame Dope Sheet");
}

void AppState::writeValue(const QString &key, const QVariant &value)
{
    if (m_persistence != Persistence::Settings) {
        return;
    }
    const auto settings = AppSettings::open();
    settings->setValue(key, value);
    settings->sync();
    if (settings->status() != QSettings::NoError) {
        qWarning() << "[AppState] No se pudo guardar" << key << "en" << AppSettings::filePath();
    }
}

void AppState::setEnabled(bool enabled)
{
    if (m_enabled == enabled) {
        return;
    }
    m_enabled = enabled;
    writeValue(kEnabled, enabled);
    emit changed();
}

void AppState::setCheckUpdatesAtStartup(bool check)
{
    if (m_checkUpdatesAtStartup == check) {
        return;
    }
    m_checkUpdatesAtStartup = check;
    writeValue(kCheckUpdates, check);
    emit changed();
}

void AppState::setShortcut(ShortcutAction action, const Shortcut &shortcut)
{
    Shortcut &target = action == ShortcutAction::AddKeyframe ? m_addKeyframe : m_frameDopeSheet;
    if (!shortcut.isValid() || target == shortcut) {
        return;
    }
    target = shortcut;
    writeValue(action == ShortcutAction::AddKeyframe ? kAddKeyframe : kFrameDopeSheet, shortcut.toPortableString());
    emit changed();
}

void AppState::setDopeSheetSpot(const QPointF &fraction)
{
    if (!validFraction(fraction.x()) || !validFraction(fraction.y())) {
        return;
    }
    if (m_hasDopeSheetSpot && m_dopeSheetSpot == fraction) {
        return;
    }
    m_hasDopeSheetSpot = true;
    m_dopeSheetSpot = fraction;
    writeValue(kSpotX, fraction.x());
    writeValue(kSpotY, fraction.y());
    emit changed();
}

void AppState::setNukeInFront(bool inFront)
{
    if (m_nukeInFront == inFront) {
        return;
    }
    m_nukeInFront = inFront;
    emit changed();
}

void AppState::setRegistration(ShortcutAction action, Registration registration)
{
    Registration &target = action == ShortcutAction::AddKeyframe ? m_addKeyframeRegistration : m_frameRegistration;
    if (target == registration) {
        return;
    }
    target = registration;
    emit changed();
}

void AppState::setAccessibilityGranted(bool granted)
{
    if (m_accessibilityGranted == granted) {
        return;
    }
    m_accessibilityGranted = granted;
    emit changed();
}
