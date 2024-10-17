#Requires AutoHotkey v2.0.2+
#SingleInstance Force
DetectHiddenWindows true
ListLines True
SetWorkingDir A_InitialWorkingDir

; Crear la GUI principal
calibrateGui := Gui()
calibrateGui.Opt("+AlwaysOnTop")
calibrateGui.SetFont("s10")
calibrateGui.Add("Text", "w500", "Este programa ayuda a LGA_Nuke_Shortcuts a encontrar la ubicación del Dope Sheet en la pantalla.")
calibrateGui.Add("Text", "w500", "Instrucciones:")
calibrateGui.Add("Text", "w500", "1. Asegúrate de que Nuke esté abierto y visible.")
calibrateGui.Add("Text", "w500", "2. Haz clic en 'Comenzar' y luego en el área del Dope Sheet en Nuke.")
calibrateGui.Add("Text", "w500", "3. Se mostrará la posición X e Y capturada.")
calibrateGui.Add("Text", "w500", "4. Usa estos valores para TargetX y TargetY en LGA_Nuke_Shortcuts_Settings.ini")

; Cargar y mostrar la imagen
imagePath := A_ScriptDir "\+resources\DopeSheetPos.bmp"

if FileExist(imagePath) {
    try {
        ; Crear un control Picture centrado horizontalmente
        pic := calibrateGui.Add("Picture", "w300 h-1 Center", imagePath)
    } catch as err {
        calibrateGui.Add("Text", "cRed", "Error al cargar la imagen: " . err.Message)
    }
} else {
    calibrateGui.Add("Text", "cRed", "Error: No se pudo encontrar DopeSheetPos.bmp en la carpeta +resources")
}

; Añadir el botón centrado
calibrateGui.Add("Button", "w120 Center", "Comenzar").OnEvent("Click", (*) => StartCalibration())

calibrateGui.Show()

; Crear la GUI para mostrar la posición del cursor
cursorPosGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
cursorPosGui.SetFont("s12", "Arial")
cursorPosText := cursorPosGui.Add("Text", "w200 h30", "X: 0, Y: 0")

isCalibrating := false

StartCalibration() {
    global isCalibrating, cursorPosGui
    isCalibrating := true
    calibrateGui.Hide()
    cursorPosGui.Show("NoActivate")
    SetTimer UpdateCursorPos, 10
}

UpdateCursorPos() {
    global cursorPosText
    CoordMode "Mouse", "Screen"
    MouseGetPos(&x, &y)
    cursorPosText.Value := "X: " . x . ", Y: " . y
    cursorPosGui.Move(x + 20, y + 20)
}

WatchCursor() {
    global isCalibrating
    if (isCalibrating && GetKeyState("LButton", "P")) {
        SetTimer UpdateCursorPos, 0
        SetTimer(, 0)
        CoordMode "Mouse", "Screen"
        MouseGetPos(&x, &y)
        cursorPosGui.Hide()
        MsgBox("Posición capturada:`nX: " . x . "`nY: " . y . "`n`nUtiliza estos valores para TargetX y TargetY en LGA_Nuke_Shortcuts_Settings.ini", "Calibración Completada")
        ExitApp
    }
}

calibrateGui.OnEvent("Close", (*) => ExitApp())

SetTimer WatchCursor, 10
