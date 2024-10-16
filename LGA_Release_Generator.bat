@echo off
rem Change directory to the folder where the .bat file is located
cd /d "%~dp0"

rem Check if the .zip file exists and delete it if it does
if exist LGA_NukeShortcuts.zip (
    del LGA_NukeShortcuts.zip
)

rem Create the zip file with exclusions from the specified folder
"C:\Program Files\7-Zip\7z.exe" a -tzip LGA_NukeShortcuts.zip * -xr@.exclude.lst

rem Pause the script to see any error messages
pause
