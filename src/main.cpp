#include "actions/ActionRunner.h"
#include "core/AppPaths.h"
#include "core/BuildTree.h"
#include "core/DebugFlags.h"
#include "core/LgaRegistry.h"
#include "core/Shortcut.h"
#include "platform/AutoStart.h"
#include "platform/InputInjector.h"
#include "platform/NukeWatcher.h"
#include "qa/UiShot.h"
#include "tray/TrayController.h"
#include "ui/Theme.h"

#include <QApplication>
#include <QCoreApplication>
#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QEventLoop>
#include <QFile>
#include <QIcon>
#include <QLockFile>
#include <QSystemTrayIcon>
#include <QTextStream>
#include <QTimer>

#include <cstdio>
#include <functional>

namespace {

/**
 * Marcador de version embebido en el binario. Lo lee un guard del instalador (findstr sobre el exe)
 * para verificar QUE VERSION quedo compilada antes de empaquetar. Mismo mecanismo que
 * LGA_FolderSwitch y LGA_MediaTools_v2. Dos condiciones:
 *  - Literal NARROW (char[]): findstr busca bytes, y un literal UTF-16 no aparece.
 *  - REFERENCIADO: sin uso, el linker lo descarta. El qDebug() de main() lo referencia.
 */
const char kBuildVersionMarker[] = "LGA_NUKESHORTCUTS_BUILD_VERSION=" NUKESHORTCUTS_VERSION;

// Log a archivo: la app no tiene consola, sin esto qDebug es invisible. Se activa con log=true en
// config/debug_flags.txt. La ruta sale de AppPaths, que no depende del directorio de trabajo
// (lanzada por la Run key, el cwd es System32).
void fileMessageHandler(QtMsgType, const QMessageLogContext &, const QString &msg)
{
    static const bool enabled = DebugFlags::isOn(QStringLiteral("log"));
    if (!enabled) {
        return;
    }
    static QFile logFile(AppPaths::logFile());
    static const bool opened = logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text);
    if (!opened) {
        return;
    }
    QTextStream out(&logFile);
    out << QDateTime::currentDateTime().toString(QStringLiteral("HH:mm:ss.zzz")) << ' ' << msg << '\n';
    out.flush();
}

// Lo que hace falta leer del log cuando "no arranca con el sistema".
void logStartupDiagnostics()
{
    const QString stored = AutoStart::storedCommand();
    qInfo() << "Exe:" << QDir::toNativeSeparators(QCoreApplication::applicationFilePath())
            << "| arbol de build:" << AppPaths::isBuildTree() << "| raiz:" << AppPaths::rootDir()
            << "| inicio automatico disponible:" << AutoStart::availability().available;
    qInfo() << "Inicio con la sesion:" << (AutoStart::isEnabled() ? "activo" : "inactivo")
            << "| valor en Run:" << (stored.isEmpty() ? QStringLiteral("(ninguno)") : stored)
            << "| deshabilitado en Task Manager:" << AutoStart::disabledByTaskManager();
}

bool hasArg(int argc, char *argv[], const char *name)
{
    for (int i = 1; i < argc; ++i) {
        if (qstrcmp(argv[i], name) == 0) {
            return true;
        }
    }
    return false;
}

// --self-test: la logica que no necesita pantalla, contra el codigo de produccion (no una replica).
// Cada guarda tiene su caso negativo. Sale 0 si todo paso.
int runSelfTest()
{
    int failures = 0;
    const auto check = [&failures](bool ok, const QString &what) {
        std::printf("%s %s\n", ok ? "ok  " : "FAIL", qPrintable(what));
        if (!ok) {
            ++failures;
        }
    };

    // Nuke por el nombre del ejecutable.
    for (const char *yes : {"Nuke15.1.exe", "Nuke16.0.exe", "nuke14.0.exe", "Nuke15.1", "Nuke15.1v4", "Nuke.exe"}) {
        check(NukeWatcher::isNukeExecutable(QString::fromLatin1(yes)), QStringLiteral("es Nuke: %1").arg(QLatin1String(yes)));
    }
    for (const char *no : {"LGA_NukeShortcuts.exe", "NukeShortcuts.exe", "NukeX.exe", "Nuke15.1.exe.bak",
                           "explorer.exe", "Nukeitall.exe", ""}) {
        check(!NukeWatcher::isNukeExecutable(QString::fromLatin1(no)), QStringLiteral("no es Nuke: '%1'").arg(QLatin1String(no)));
    }

    // Atajos: ida y vuelta por el texto del .ini, y textos invalidos.
    for (const Shortcut &s : {Shortcut::defaultAddKeyframe(), Shortcut::defaultFrameDopeSheet()}) {
        check(Shortcut::fromPortableString(s.toPortableString()) == s,
              QStringLiteral("ida y vuelta: %1").arg(s.toPortableString()));
    }
    check(Shortcut::defaultAddKeyframe().toPortableString() == QLatin1String("Ctrl+Shift+D"),
          QStringLiteral("texto portable de Add keyframe"));
    for (const char *bad : {"", "Ctrl+Shift+", "Ctrl+Shift+!", "Ctrl+Space", "Ctrl+A, Ctrl+B", "basura"}) {
        check(!Shortcut::fromPortableString(QString::fromLatin1(bad)).isValid(),
              QStringLiteral("atajo invalido rechazado: '%1'").arg(QLatin1String(bad)));
    }

    // Punto calibrado: fraccion <-> nativo, con marcos en otra posicion y otro tamano.
    const QRect frameA(100, 50, 2000, 1000);
    const QPoint click(1880, 770);
    const QPointF spot = ActionRunner::nativeToSpot(frameA, click);
    check(ActionRunner::spotToNative(frameA, spot) == click, QStringLiteral("ida y vuelta del punto en el mismo marco"));
    const QRect frameB(-1920, 0, 1000, 500); // otro monitor, a la izquierda, mitad de tamano
    const QPoint moved = ActionRunner::spotToNative(frameB, spot);
    check(moved == QPoint(-1920 + 890, 360), QStringLiteral("el punto sigue a la ventana: %1,%2").arg(moved.x()).arg(moved.y()));
    const QPointF invalid = ActionRunner::nativeToSpot(QRect(), click);
    check(invalid.x() < 0, QStringLiteral("marco vacio no da un punto valido"));

    std::printf("%s: %d fallas\n", failures == 0 ? "self-test ok" : "self-test FALLO", failures);
    return failures == 0 ? 0 : 1;
}

// --simulate-action <add-keyframe|frame-dope-sheet>: corre la secuencia REAL de ActionRunner con un
// InputInjector en dry-run (no mueve el mouse ni aprieta nada) e imprime los pasos.
int runSimulateAction(const QString &which)
{
    InputInjector injector(true);
    ActionRunner runner(&injector);
    QEventLoop loop;
    QObject::connect(&runner, &ActionRunner::finished, &loop, &QEventLoop::quit);
    bool started = false;
    if (which == QLatin1String("add-keyframe")) {
        started = runner.runAddKeyframe();
    } else if (which == QLatin1String("frame-dope-sheet")) {
        started = runner.runFrameDopeSheet(QRect(0, 0, 3440, 1440), QPointF(0.89, 0.72));
    } else {
        std::fprintf(stderr, "usage: --simulate-action <add-keyframe|frame-dope-sheet>\n");
        return 2;
    }
    if (!started) {
        std::fprintf(stderr, "simulate-action: la secuencia no arranco\n");
        return 1;
    }
    QTimer::singleShot(5000, &loop, &QEventLoop::quit);
    loop.exec();
    for (const QString &step : injector.steps()) {
        std::printf("%s\n", qPrintable(step));
    }
    return runner.isBusy() ? 1 : 0;
}

// Fuentes embebidas, icono y hoja de estilo: lo comparten la app y la captura de QA.
void applyAppStyle(QApplication &app)
{
    Theme::apply(app);
    app.setWindowIcon(QIcon(QStringLiteral(":/icons/LGA_NukeShortcuts.png")));
}

void setNames()
{
    // Los dos nombres ANTES de cualquier QStandardPaths: AppDataLocation saltea los vacios.
    QCoreApplication::setOrganizationName(QStringLiteral("LGA"));
    QCoreApplication::setApplicationName(QStringLiteral("LGA_NukeShortcuts"));
    QCoreApplication::setApplicationVersion(QStringLiteral(NUKESHORTCUTS_VERSION));
}

} // namespace

int main(int argc, char *argv[])
{
    AppPaths::init(argc > 0 ? argv[0] : nullptr);

    // Arneses sin pantalla: QCoreApplication, sin plugin de plataforma, sin log a archivo.
    if (hasArg(argc, argv, "--self-test")) {
        QCoreApplication app(argc, argv);
        setNames();
        return runSelfTest();
    }
    if (hasArg(argc, argv, "--simulate-action")) {
        QCoreApplication app(argc, argv);
        setNames();
        const QStringList args = app.arguments();
        return runSimulateAction(args.value(args.indexOf(QStringLiteral("--simulate-action")) + 1));
    }

    // --ui-shot no escribe en el debug.log: una captura no deja rastros fuera del PNG y su .json.
    const bool uiShot = hasArg(argc, argv, "--ui-shot");
    if (!uiShot) {
        qInstallMessageHandler(fileMessageHandler);
    }
    qDebug() << kBuildVersionMarker;
    LgaBuildTree::warnIfInvalidOverride();

    QApplication app(argc, argv);
    setNames();
    QApplication::setQuitOnLastWindowClosed(false);

    // Captura de QA: sale antes de la instancia unica, de la bandeja, de los atajos y del updater.
    // Dibujar un estado no toca nada de la copia que el usuario tiene abierta.
    if (uiShot) {
        applyAppStyle(app);
        return runUiShot(app.arguments());
    }

    // Instancia unica.
    static QLockFile singleInstanceLock(QDir(QDir::tempPath()).filePath(QStringLiteral("com.lga.nukeshortcuts.singleton.lock")));
    if (!singleInstanceLock.tryLock(100)) {
        qWarning() << "LGA_NukeShortcuts ya esta corriendo; esta instancia sale para no duplicar.";
        return 0;
    }

    // Registro compartido de las apps LGA (Doc_Registro_LGA.md de la Base). Desde un build no se
    // registra, a proposito; el false no es un error.
    LgaRegistry::registerThisApp(QStringLiteral("LGA_NukeShortcuts"), QStringLiteral(NUKESHORTCUTS_VERSION));

    applyAppStyle(app);

    const bool dryRunInput = hasArg(argc, argv, "--dry-run-input") || DebugFlags::isOn(QStringLiteral("dryRunInput"));

    // Al arrancar con la sesion, el shell suele no tener la bandeja lista todavia. El reintento vive
    // DENTRO del event loop (nunca un loop bloqueante antes de exec(): el proceso quedaria sin
    // bombear mensajes y el shell lo mostraria colgado). Patron de FolderSwitch.
    constexpr int kTrayWaitMs = 90000;
    constexpr int kTrayPollMs = 500;
    int trayWaitedMs = 0;
    std::function<void()> pollTray;
    pollTray = [&app, &trayWaitedMs, &pollTray, dryRunInput]() {
        if (QSystemTrayIcon::isSystemTrayAvailable()) {
            if (trayWaitedMs > 0) {
                qInfo() << "La bandeja tardo" << trayWaitedMs << "ms en estar disponible.";
            }
            new TrayController(dryRunInput, &app);
            qInfo() << "LGA_NukeShortcuts" << NUKESHORTCUTS_VERSION << "iniciado.";
            logStartupDiagnostics();
            return;
        }
        if (trayWaitedMs >= kTrayWaitMs) {
            // Nada de cartel: es una app de bandeja, un modal al arranque no lo ve nadie.
            qWarning() << "No hay bandeja del sistema despues de esperar" << (kTrayWaitMs / 1000) << "s; se sale.";
            QCoreApplication::exit(1);
            return;
        }
        trayWaitedMs += kTrayPollMs;
        QTimer::singleShot(kTrayPollMs, qApp, pollTray);
    };
    QTimer::singleShot(0, qApp, pollTray);

    return app.exec();
}
