#Requires AutoHotkey v2.0.2+
#SingleInstance Force ;Limit one running version of this script
DetectHiddenWindows true ;ensure can find hidden windows
ListLines True ;on helps debug a script-this is already on by default
SetWorkingDir A_InitialWorkingDir ;Set the working directory to the scripts directory

; Leer configuración
configFile := "LGA_Nuke_Shortcuts_Settings.ini"
if (FileExist(configFile)) {
    targetX := IniRead(configFile, "MousePosition", "TargetX", 900)
    targetY := IniRead(configFile, "MousePosition", "TargetY", 1230)
} else {
    MsgBox "Archivo de configuración no encontrado. Se usarán valores predeterminados."
    targetX := 900
    targetY := 1230
}

; Obtener la resolución actual de la pantalla
screenWidth := A_ScreenWidth
screenHeight := A_ScreenHeight

; Calcular la resolución de referencia
referenceWidth := 3440  ; Valor de referencia para el ancho
referenceHeight := Round(referenceWidth * (screenHeight / screenWidth))

;---------Nuke--------

^+d:: ; Ctrl+Shift+D Para agregar un keyframe en donde está el cursor parpadeando o sino en donde esta el puntero del mouse
{
    CoordMode "Mouse", "Screen"
    if (CaretGetPos(&caretX, &caretY)) {
        ; Si se puede obtener la posición del cursor, usamos esa
        MouseMove caretX, caretY, 0
    } else {
        ; Si no, usamos la posición actual del mouse
        MouseGetPos(&mouseX, &mouseY)
        MouseMove mouseX, mouseY, 0
    }
    Click "Right"
    Sleep 50 ; Espera breve para que se abra el menú contextual
    Send "{Down}"
    Sleep 30 ; Espera breve antes de enviar Enter
    Send "{Enter}"
}

^!+d::  ; Click en la parte de abajo del viewer para que anden los shortcuts para saltar de key a key
{
    if (WinExist("ahk_exe Nuke*.exe") or WinExist("ahk_class Qt5152WindowIcon") or WinExist("NukeX")) {
        WinActivate
        CoordMode "Mouse", "Screen"
        MouseGetPos(&startX, &startY)
        
        ; Calcular posición relativa
        adjustedX := Round(targetX * screenWidth / referenceWidth)
        adjustedY := Round(targetY * screenHeight / referenceHeight)
        
        Send "{Ctrl Down}{Ctrl Up}{Alt Down}{Alt Up}"
        MouseMove adjustedX, adjustedY, 0
        Click
        Send "^a"
        Sleep 10
        Send "f"
        MouseMove startX, startY, 0
    } else {
        activeWindow := WinGetTitle("A")
        activeClass := WinGetClass("A")
        activeExe := WinGetProcessName("A")
        MsgBox "No se pudo encontrar la ventana de Nuke. Asegúrate de que Nuke esté abierto.`n`nVentana activa: " activeWindow "`nClase de ventana activa: " activeClass "`nEjecutable activo: " activeExe

        ; Listar todas las ventanas detectables
        windowList := ""
        idList := WinGetList()
        for id in idList {
            try {
                title := WinGetTitle("ahk_id " id)
                class := WinGetClass("ahk_id " id)
                exe := WinGetProcessName("ahk_id " id)
                if (title != "" or class != "" or exe != "") {
                    windowList .= "Título: " title "`nClase: " class "`nEjecutable: " exe "`n`n"
                }
            } catch as err {
                ; Ignorar ventanas a las que no podemos acceder
                continue
            }
        }
        FileAppend windowList, "ventanas_detectadas.txt"
        Run "ventanas_detectadas.txt"
    }
}
