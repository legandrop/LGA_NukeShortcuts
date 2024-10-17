#requires AutoHotkey v2.1-alpha.9
#SingleInstance Force
SetWorkingDir A_InitialWorkingDir

; Incluir los scripts necesarios
#Include %A_ScriptDir%\+resources\ColorButton.ahk

; Leer la configuración actual
configFile := A_ScriptDir "\+resources\LGA_Nuke_Shortcuts_Settings.ini"
if (FileExist(configFile)) {
    addKeyframeHotkey := IniRead(configFile, "Shortcuts", "AddKeyframe", "^+d")
    clickDopeSheetHotkey := IniRead(configFile, "Shortcuts", "ClickDopeSheet", "^!+d")
} else {
    MsgBox "Configuration file not found in +resources folder. Using default values."
    addKeyframeHotkey := "^+d"
    clickDopeSheetHotkey := "^!+d"
}

; Crear la GUI
MyGui := Gui()
MyGui.BackColor := "0x202020"  ; Color de fondo

; Aplicar tema oscuro a la barra de título
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", MyGui.Hwnd, "Int", 20, "Int*", True, "Int", 4)

MyGui.SetFont("s10", "Segoe UI")

; Añadir controles en una disposición horizontal
addKeyframeText := MyGui.Add("Text", "x10 y10 w200 cWhite", "Add Keyframe Shortcut:")
addKeyframeEdit := MyGui.Add("Edit", "x+10 yp w100 vAddKeyframe -E0x200", addKeyframeHotkey)  ; -E0x200 elimina el borde

clickDopeSheetText := MyGui.Add("Text", "x10 y+10 w200 cWhite", "Click Dope Sheet Shortcut:")
clickDopeSheetEdit := MyGui.Add("Edit", "x+10 yp w100 vClickDopeSheet -E0x200", clickDopeSheetHotkey)  ; -E0x200 elimina el borde

; Añadir checkbox personalizado
checkboxSize := 16
customCheckbox := MyGui.Add("Picture", "x10 y+20 w" checkboxSize " h" checkboxSize " vAutoStart", A_ScriptDir "\+resources\check_off.jpg")
customCheckboxLabel := MyGui.Add("Text", "x+5 yp h" checkboxSize " cWhite", "Run at Windows startup")
customCheckbox.OnEvent("Click", ToggleCheckbox)
customCheckboxLabel.OnEvent("Click", (*) => ToggleCheckbox())

; Inicializar el estado del checkbox
isAutoStartEnabled := FileExist(A_Startup "\LGA_Nuke_Shortcuts.lnk")
UpdateCheckboxImage(customCheckbox, isAutoStartEnabled)

; Crear un botón personalizado usando _BtnColor
saveButton := MyGui.Add("Button", "x220 y+20 w120", "Save Changes")
saveButton.OnEvent("Click", SaveChanges)
saveButton.SetColor("0x4e479a", "0xFFFFFF", 0, "0x4e479a", 15)  ; Texto blanco

; Aplicar tema oscuro a los controles
ApplyDarkModeToControls(MyGui)

MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.Show()

; Función para aplicar el tema oscuro a los controles
ApplyDarkModeToControls(GuiObj) {
    for ctrl in GuiObj {
        switch ctrl.Type {
            case "Edit":
                ctrl.Opt("+Background333333 cWhite")
            case "Text":
                ctrl.Opt("cWhite")
        }
    }
}

; Función para actualizar la imagen del checkbox
UpdateCheckboxImage(ctrl, isChecked) {
    if (isChecked) {
        ctrl.Value := A_ScriptDir "\+resources\check_on.jpg"
    } else {
        ctrl.Value := A_ScriptDir "\+resources\check_off.jpg"
    }
}

; Función para alternar el estado del checkbox
ToggleCheckbox(*) {
    global isAutoStartEnabled
    isAutoStartEnabled := !isAutoStartEnabled
    UpdateCheckboxImage(customCheckbox, isAutoStartEnabled)
    ToggleAutoStart()
}

; Función para guardar los cambios
SaveChanges(*) {
    newAddKeyframeHotkey := addKeyframeEdit.Value
    newClickDopeSheetHotkey := clickDopeSheetEdit.Value

    ; Validar los atajos de teclado (puedes agregar más validaciones si es necesario)
    if (newAddKeyframeHotkey = "" or newClickDopeSheetHotkey = "") {
        MsgBox("Shortcuts cannot be empty. Please enter valid shortcuts.", "Error", 48)
        return
    }

    ; Guardar los nuevos atajos en el archivo de configuración
    IniWrite(newAddKeyframeHotkey, configFile, "Shortcuts", "AddKeyframe")
    IniWrite(newClickDopeSheetHotkey, configFile, "Shortcuts", "ClickDopeSheet")
    MsgBox("Changes saved successfully.", "Success", 64)
}

; Función para activar/desactivar el inicio automático
ToggleAutoStart(*) {
    exePath := A_ScriptDir "\LGA_Nuke_Shortcuts.exe"
    shortcutPath := A_Startup "\LGA_Nuke_Shortcuts.lnk"

    if (isAutoStartEnabled) {
        FileCreateShortcut(exePath, shortcutPath)
    } else {
        if (FileExist(shortcutPath)) {
            FileDelete(shortcutPath)
        }
    }
}
