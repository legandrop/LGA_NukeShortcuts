#ifndef NUKESHORTCUTS_MAINWINDOW_H
#define NUKESHORTCUTS_MAINWINDOW_H

#include "core/AppState.h"
#include "ui/ShortcutRow.h"

#include <QMainWindow>

#include <functional>

class Chip;
class QCheckBox;
class QFrame;
class QLabel;
class QPushButton;
class SpotThumbnail;
class TitleBar;

// Ventana de Settings, segun el diseno aprobado: barra de titulo propia y cuatro tarjetas.
//  1. Estado: activos / en pausa / un atajo tomado / falta el permiso (mac).
//  2. Shortcuts: las dos acciones, cada una con sus teclas y el lapiz para cambiarlas.
//  3. Dope Sheet position: el punto guardado sobre la captura del layout de Nuke y "Calibrate...".
//  4. La app: inicio con la sesion y updates.
// Todo lo que muestra sale de AppState; lo que el usuario cambia se escribe en AppState (o en
// AutoStart). Cerrar no cierra la app: oculta la ventana a la bandeja (closeEvent).
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    // Capture: la arma --ui-shot. No lee el sistema, no hace NINGUN connect y el estado sale solo
    // del AppState de prueba y de applyAutoStartFixture().
    enum class Mode { Normal, Capture };

    MainWindow(AppState *state, Mode mode, QWidget *parent = nullptr);
    ~MainWindow() override;

    TitleBar *titleBar() const { return m_titleBar; }
    ShortcutRow *shortcutRow(ShortcutAction action) const;

    // Quien valida un atajo nuevo (lo arma TrayController con HotkeyService::probe).
    using ShortcutValidator = std::function<QString(ShortcutAction, const Shortcut &)>;
    void setShortcutValidator(ShortcutValidator validator);

    // Solo para Mode::Capture: estado del checkbox de inicio con la sesion.
    void applyAutoStartFixture(bool enabled, bool available);
    // Vuelve a leer AppState y ajusta el alto de la ventana a su contenido.
    void refresh();

signals:
    void helpRequested();
    void checkUpdatesRequested();
    void calibrateRequested();
    void accessibilityRequested();

protected:
    void closeEvent(QCloseEvent *event) override;
    void showEvent(QShowEvent *event) override;
    void changeEvent(QEvent *event) override;
#ifdef Q_OS_WIN
    bool nativeEvent(const QByteArray &eventType, void *message, qintptr *result) override;
#endif

private slots:
    void onAutoStartToggled(bool checked);
    void onStatusButtonClicked();

private:
    enum class Status { On, Paused, ShortcutTaken, NeedsPermission };

    void buildUi();
    void connectWrites();
    Status currentStatus() const;
    void syncAutoStartCheck();
    void setAutoStartTooltip(bool available);
    void fitHeight();
    void cancelRecordings();
#ifdef Q_OS_WIN
    // Sin el marco de Windows pero con su sombra, sus esquinas y su minimizar: ver el .cpp.
    void applyNativeFrame();
    bool m_nativeFrameApplied = false;
#endif

    AppState *m_state = nullptr;
    Mode m_mode = Mode::Normal;

    TitleBar *m_titleBar = nullptr;
    QFrame *m_statusCard = nullptr;
    QLabel *m_statusDot = nullptr;
    QLabel *m_statusTitle = nullptr;
    QLabel *m_statusCaption = nullptr;
    QPushButton *m_statusButton = nullptr;

    ShortcutRow *m_addKeyframeRow = nullptr;
    ShortcutRow *m_frameRow = nullptr;

    Chip *m_spotChip = nullptr;
    SpotThumbnail *m_spotThumb = nullptr;
    QLabel *m_spotValue = nullptr;
    QLabel *m_spotCaption = nullptr;
    QPushButton *m_calibrateButton = nullptr;

    QCheckBox *m_autoStartCheck = nullptr;
    QCheckBox *m_updatesCheck = nullptr;
    QPushButton *m_checkNowButton = nullptr;
};

#endif // NUKESHORTCUTS_MAINWINDOW_H
