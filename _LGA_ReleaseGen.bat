@echo off
setlocal enabledelayedexpansion

rem Cambiar directorio a la carpeta donde se encuentra el archivo .bat
cd /d "%~dp0"

rem Definir el nombre base del archivo zip
set "ZIPNAME=LGA_NukeShortcuts"

rem Inicializar el número de versión máximo
set "maxver=0"
set "version_exists=false"

rem Buscar archivos que coincidan con el patrón ZIPNAME_v*.zip
for %%F in ("%ZIPNAME%_v*.zip") do (
    set "version_exists=true"
    set "verstr=%%~nF"
    set "verstr=!verstr:%ZIPNAME%_v=!"
    for /f "tokens=1 delims=_" %%G in ("!verstr!") do (
        set "ver=%%G"
        set "vernum=!ver:.=!"
        if !vernum! GTR !maxver! (
            set "maxver=!vernum!"
        )
    )
)

rem Calcular el nuevo número de versión
if "!version_exists!"=="false" (
    set "newver=1.0"
) else (
    set /a newvernum=maxver+1
    set /a newverint=newvernum / 10
    set /a newverdec=newvernum %% 10
    set "newver=!newverint!.!newverdec!"
)

rem Definir el nombre completo del nuevo archivo zip
set "NEWZIPNAME=%ZIPNAME%_v!newver!.zip"

rem Crear el archivo zip con las exclusiones especificadas
rem Ademas se excluye lo que ignora .git\info\exclude: archivos locales de trabajo que viven en
rem la carpeta pero no en el repo, y que tampoco tienen que entrar al zip. Sus lineas de
rem comentario no matchean ningun archivo, asi que 7-Zip las puede leer como patrones.
rem El zip se arma con toda la carpeta: sin el .git\info\exclude que escribe RepoRules
rem (apply-excludes de LGA_RepoTools), los archivos locales de trabajo entrarian al zip
rem publico. En un clon nuevo ese archivo no existe todavia: se corta aca.
findstr /c:"Generado por apply-excludes" ".git\info\exclude" >nul 2>&1
if errorlevel 1 (
    echo ERROR: falta el .git\info\exclude de RepoRules. Correr apply-excludes de LGA_RepoTools y reintentar.
    exit /b 1
)
"C:\Program Files\7-Zip\7z.exe" a -tzip "!NEWZIPNAME!" * -xr@.exclude.lst -xr@.git\info\exclude

echo Se ha creado el archivo !NEWZIPNAME!

rem Pausar el script para ver cualquier mensaje de error
pause

endlocal
