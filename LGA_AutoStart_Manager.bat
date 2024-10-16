@echo off
chcp 65001 > nul
set EXE_PATH=%~dp0LGA_Nuke_Shortcuts.exe
set SHORTCUT_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\LGA_Nuke_Shortcuts.lnk

if not exist "%EXE_PATH%" (
    echo LGA_Nuke_Shortcuts.exe no se encuentra en la carpeta actual.
    echo Asegúrate de que el archivo exista antes de ejecutar este script.
    goto :exit
)

if exist "%SHORTCUT_PATH%" (
    echo El acceso directo ya existe. Procediendo a eliminarlo...
    del "%SHORTCUT_PATH%"
    echo Acceso directo eliminado. LGA_Nuke_Shortcuts ya no se iniciará con Windows.
) else (
    echo El acceso directo no existe. Procediendo a crearlo...
    powershell -command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT_PATH%');$s.TargetPath='%EXE_PATH%';$s.Save()"
    echo Acceso directo creado. LGA_Nuke_Shortcuts se iniciará con Windows.
)

:exit
echo.
echo Presiona cualquier tecla para salir...
pause >nul
