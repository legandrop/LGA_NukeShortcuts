#ifndef NUKESHORTCUTS_APPSETTINGS_H
#define NUKESHORTCUTS_APPSETTINGS_H

#include <QSettings>
#include <QString>

#include <memory>

// Donde vive la configuracion: settings.ini en la carpeta de la app dentro de AppData, igual que
// las otras apps LGA.
//  - Windows: %APPDATA%\LGA\LGA_NukeShortcuts\settings.ini (el desinstalador borra la carpeta).
//  - macOS:   ~/Library/Application Support/LGA/LGA_NukeShortcuts/settings.ini (nunca adentro
//             del .app: escribir en el bundle invalida la firma).
namespace AppSettings {

QString filePath();
std::unique_ptr<QSettings> open();

} // namespace AppSettings

#endif // NUKESHORTCUTS_APPSETTINGS_H
