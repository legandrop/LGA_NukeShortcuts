#requires AutoHotkey v2.1-alpha.9
#SingleInstance Force
SetWorkingDir A_InitialWorkingDir

; Incluir los scripts necesarios
#Include %A_ScriptDir%\+resources\DarkMode.scriptlet
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
MyGui.SetFont("s10", "Segoe UI")

; Aplicar tema oscuro
SetWindowAttribute(MyGui)
SetWindowTheme(MyGui)

; Añadir controles en una disposición horizontal
addKeyframeText := MyGui.Add("Text", "x10 y10 w200 cWhite", "Add Keyframe Shortcut:")
addKeyframeEdit := MyGui.Add("Edit", "x+10 yp w100 vAddKeyframe -E0x200", addKeyframeHotkey)  ; -E0x200 elimina el borde

clickDopeSheetText := MyGui.Add("Text", "x10 y+10 w200 cWhite", "Click Dope Sheet Shortcut:")
clickDopeSheetEdit := MyGui.Add("Edit", "x+10 yp w100 vClickDopeSheet -E0x200", clickDopeSheetHotkey)  ; -E0x200 elimina el borde

; Añadir checkbox original para inicio automático
autoStartCheckbox := MyGui.Add("Checkbox", "x10 y+20 w200 vAutoStart cWhite", "Run at Windows startup")
autoStartCheckbox.Value := FileExist(A_Startup "\LGA_Nuke_Shortcuts.lnk") ? 1 : 0
autoStartCheckbox.OnEvent("Click", ToggleAutoStart)

; Añadir fake checkbox
SGW := SysGet(71)  ; SM_CXMENUCHECK
SGH := SysGet(72)  ; SM_CYMENUCHECK
fakeCheckbox := MyGui.Add("Text", "x10 y+10 w" SGW " h" SGH " 0x201000 vFakeAutoStart", "")  ; SS_NOTIFY | SS_SUNKEN
fakeCheckboxLabel := MyGui.Add("Text", "x+5 yp h" SGH " cWhite 0x200", "Fake Checkbox (Example)")
fakeCheckbox.Value := FileExist(A_Startup "\LGA_Nuke_Shortcuts.lnk") ? "✓" : ""
fakeCheckbox.OnEvent("Click", ToggleFakeAutoStart)
fakeCheckboxLabel.OnEvent("Click", (*) => ToggleFakeAutoStart())

; Crear un botón personalizado usando _BtnColor
saveButton := MyGui.Add("Button", "x10 y+20 w120", "Save Changes")
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
                if (ctrl.ClassNN = fakeCheckbox.ClassNN) {
                    ctrl.SetFont("s12 c4e479a", "Segoe UI Symbol")
                }
        }
    }
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

; Función para activar/desactivar el inicio automático (checkbox original)
ToggleAutoStart(*) {
    exePath := A_ScriptDir "\LGA_Nuke_Shortcuts.exe"
    shortcutPath := A_Startup "\LGA_Nuke_Shortcuts.lnk"

    if (autoStartCheckbox.Value) {
        FileCreateShortcut(exePath, shortcutPath)
        fakeCheckbox.Value := "✓"  ; Actualizar también el fake checkbox
    } else {
        if (FileExist(shortcutPath)) {
            FileDelete(shortcutPath)
        }
        fakeCheckbox.Value := ""  ; Actualizar también el fake checkbox
    }
}

; Función para toggle del fake checkbox
ToggleFakeAutoStart(*) {
    if (fakeCheckbox.Value = "") {
        fakeCheckbox.Value := "✓"
        autoStartCheckbox.Value := 1  ; Actualizar también el checkbox original
    } else {
        fakeCheckbox.Value := ""
        autoStartCheckbox.Value := 0  ; Actualizar también el checkbox original
    }
    ToggleAutoStart()  ; Llamar a la función original para manejar el acceso directo
}
