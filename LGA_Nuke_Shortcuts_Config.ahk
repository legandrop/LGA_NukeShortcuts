#requires AutoHotkey v2.1-alpha.9
#SingleInstance Force
SetWorkingDir A_InitialWorkingDir

; Incluir los scripts necesarios
#Include %A_ScriptDir%\+resources\ColorButton.ahk

; Leer la configuración actual desde el archivo INI
configFile := A_ScriptDir "\+resources\LGA_Nuke_Shortcuts_Settings.ini"
if (FileExist(configFile)) {
    ; Cargar valores de configuración o usar valores predeterminados si no se encuentran
    addKeyframeHotkey := IniRead(configFile, "Shortcuts", "AddKeyframe", "^+d")
    clickDopeSheetHotkey := IniRead(configFile, "Shortcuts", "ClickDopeSheet", "^!+d")
    targetX := IniRead(configFile, "MousePosition", "TargetX", 900)
    targetY := IniRead(configFile, "MousePosition", "TargetY", 1230)
} else {
    ; Usar valores predeterminados si no se encuentra el archivo de configuración
    MsgBox "Configuration file not found in +resources folder. Using default values."
    addKeyframeHotkey := "^+d"
    clickDopeSheetHotkey := "^!+d"
    targetX := 900
    targetY := 1230
}

; Crear la interfaz gráfica principal
MyGui := Gui()
MyGui.BackColor := "0x202020"  ; Establecer color de fondo oscuro

; Aplicar tema oscuro a la barra de título de la ventana
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", MyGui.Hwnd, "Int", 20, "Int*", True, "Int", 4)

MyGui.SetFont("s10", "Segoe UI")

; Añadir controles para configurar los atajos de teclado
addKeyframeText := MyGui.Add("Text", "x10 y15 w200 cWhite", "Add Keyframe Shortcut:")
addKeyframeEdit := MyGui.Add("Edit", "x+0 yp w100 h20 vAddKeyframe -E0x200", addKeyframeHotkey)
saveButton1 := MyGui.Add("Button", "x+15 yp-3 w80 h26", "Save")
saveButton1.OnEvent("Click", SaveChanges)
saveButton1.SetColor("0x4e479a", "0xFFFFFF", 0, "0x4e479a", 15)

clickDopeSheetText := MyGui.Add("Text", "x10 y+10 w200 cWhite", "Click Dope Sheet Shortcut:")
clickDopeSheetEdit := MyGui.Add("Edit", "x+0 yp w100 h20 vClickDopeSheet -E0x200", clickDopeSheetHotkey)
saveButton2 := MyGui.Add("Button", "x+15 yp-3 w80 h26", "Save")
saveButton2.OnEvent("Click", SaveChanges)
saveButton2.SetColor("0x4e479a", "0xFFFFFF", 0, "0x4e479a", 15)

; Añadir controles para configurar la posición del Dope Sheet
MyGui.Add("Text", "x10 y+10 w200 cWhite", "Dope Sheet Position (x/y):")
targetXEdit := MyGui.Add("Edit", "x+0 yp w42 h20 vTargetX -E0x200", targetX)
targetYEdit := MyGui.Add("Edit", "x+15 yp w42 h20 vTargetY -E0x200", targetY)
calibrateButton := MyGui.Add("Button", "x+15 yp-3 w80 h26", "Calibrate")
calibrateButton.OnEvent("Click", OpenCalibrationWindow)
calibrateButton.SetColor("0x4e479a", "0xFFFFFF", 0, "0x4e479a", 15)

; Añadir checkbox personalizado para la opción de inicio automático
checkboxSize := 16
customCheckbox := MyGui.Add("Picture", "x10 y+15 w" checkboxSize " h" checkboxSize " vAutoStart", A_ScriptDir "\+resources\check_off.jpg")
customCheckboxLabel := MyGui.Add("Text", "x+5 yp-2 h" checkboxSize " cWhite", "Run at Windows startup")
customCheckbox.OnEvent("Click", ToggleCheckbox)
customCheckboxLabel.OnEvent("Click", (*) => ToggleCheckbox())

; Inicializar el estado del checkbox basado en la existencia del acceso directo de inicio
isAutoStartEnabled := FileExist(A_Startup "\LGA_Nuke_Shortcuts.lnk")
UpdateCheckboxImage(customCheckbox, isAutoStartEnabled)

; Aplicar tema oscuro a todos los controles de la GUI
ApplyDarkModeToControls(MyGui)

; Añadir texto de versión clickeable
versionText := MyGui.Add("Text", "x380 yp+20 cWhite", "v1.5")
versionText.OnEvent("Click", ShowAboutWindow)

; Configurar evento de cierre de la GUI
MyGui.OnEvent("Close", (*) => ExitApp())

; Mostrar la GUI principal
MyGui.Show()

; Función para abrir la ventana de calibración del Dope Sheet
OpenCalibrationWindow(*) {
    calibrateGui := Gui("+AlwaysOnTop")
    calibrateGui.BackColor := "0x202020"
    calibrateGui.SetFont("s10 cWhite", "Segoe UI")
    
    ; Aplicar tema oscuro a la barra de título de la ventana de calibración
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", calibrateGui.Hwnd, "Int", 20, "Int*", True, "Int", 4)
    
    ; Añadir instrucciones para la calibración
    calibrateGui.Add("Text", "w400", "Instructions:")
    calibrateGui.Add("Text", "w400", "1. Make sure Nuke is open and visible.")
    calibrateGui.Add("Text", "w400", "2. Click 'Start' and then click on the Dope Sheet area in Nuke.")
    calibrateGui.Add("Text", "w400", "3. The captured position will be stored.")
    
    ; Cargar y mostrar la imagen de ejemplo del Dope Sheet
    imagePath := A_ScriptDir "\+resources\DopeSheetPos.bmp"
    if FileExist(imagePath) {
        try {
            pic := calibrateGui.Add("Picture", "y+15 w400 h-1 Center", imagePath)
        } catch as err {
            calibrateGui.Add("Text", "cRed", "Error loading image: " . err.Message)
        }
    } else {
        calibrateGui.Add("Text", "cRed", "Error: Could not find DopeSheetPos.bmp")
    }
    
    ; Añadir botones de control
    cancelButton := calibrateGui.Add("Button", "x125 y+15 w80 h22", "Cancel")
    cancelButton.OnEvent("Click", (*) => calibrateGui.Destroy())
    cancelButton.SetColor("0x4e479a", "0xFFFFFF", 0, "0x4e479a", 15)

    startButton := calibrateGui.Add("Button", "x+10 yp w80 h22", "Start")
    startButton.OnEvent("Click", StartCalibration)
    startButton.SetColor("0x4e479a", "0xFFFFFF", 0, "0x4e479a", 15)

    ; Añadir un margen inferior
    bottomMargin := calibrateGui.Add("Text", "x0 y+10 w400 h0")

    ; Mostrar la GUI de calibración
    calibrateGui.Show()
    
    ; Crear la GUI para mostrar la posición del cursor en tiempo real
    cursorPosGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    cursorPosGui.BackColor := "0x202020"
    cursorPosGui.SetFont("s12 cWhite", "Arial")
    cursorPosText := cursorPosGui.Add("Text", "w200 h30", "X: 0, Y: 0")
    
    ; Función para iniciar el proceso de calibración
    StartCalibration(*) {
        calibrateGui.Hide()
        cursorPosGui.Show("NoActivate")
        SetTimer UpdateCursorPos, 10
    }
    
    ; Función para actualizar y mostrar la posición del cursor en tiempo real
    UpdateCursorPos() {
        CoordMode "Mouse", "Screen"
        MouseGetPos(&x, &y)
        cursorPosText.Value := "X: " . x . ", Y: " . y
        cursorPosGui.Move(x + 20, y + 20)
        
        ; Detectar clic del ratón para guardar la posición
        if (GetKeyState("LButton", "P")) {
            SetTimer UpdateCursorPos, 0
            cursorPosGui.Hide()
            ; Guardar la nueva posición en el archivo de configuración
            IniWrite(x, configFile, "MousePosition", "TargetX")
            IniWrite(y, configFile, "MousePosition", "TargetY")
            targetXEdit.Value := x
            targetYEdit.Value := y
            calibrateGui.Destroy()
            cursorPosGui.Destroy()
            
            ; Recargar el script principal para aplicar los cambios
            ReloadMainScript()
        }
    }
}

; Función para aplicar el tema oscuro a todos los controles de una GUI
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

; Función para actualizar la imagen del checkbox personalizado
UpdateCheckboxImage(ctrl, isChecked) {
    if (isChecked) {
        ctrl.Value := A_ScriptDir "\+resources\check_on.jpg"
    } else {
        ctrl.Value := A_ScriptDir "\+resources\check_off.jpg"
    }
}

; Función para alternar el estado del checkbox de inicio automático
ToggleCheckbox(*) {
    global isAutoStartEnabled
    isAutoStartEnabled := !isAutoStartEnabled
    UpdateCheckboxImage(customCheckbox, isAutoStartEnabled)
    ToggleAutoStart()
}

; Función para guardar los cambios en la configuración
SaveChanges(*) {
    newAddKeyframeHotkey := addKeyframeEdit.Value
    newClickDopeSheetHotkey := clickDopeSheetEdit.Value
    newTargetX := targetXEdit.Value
    newTargetY := targetYEdit.Value

    ; Validar los atajos de teclado y las coordenadas
    if (newAddKeyframeHotkey = "" or newClickDopeSheetHotkey = "" or newTargetX = "" or newTargetY = "") {
        MsgBox("All fields must be filled. Please enter valid values.", "Error", 48)
        return
    }

    ; Guardar los nuevos valores en el archivo de configuración
    IniWrite(newAddKeyframeHotkey, configFile, "Shortcuts", "AddKeyframe")
    IniWrite(newClickDopeSheetHotkey, configFile, "Shortcuts", "ClickDopeSheet")
    IniWrite(newTargetX, configFile, "MousePosition", "TargetX")
    IniWrite(newTargetY, configFile, "MousePosition", "TargetY")
    MsgBox("Changes saved successfully.", "Success", 64)
}

; Función para activar/desactivar el inicio automático del script
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

; Función para recargar el script principal
ReloadMainScript() {
    scriptPath := A_ScriptDir "\LGA_Nuke_Shortcuts.exe"
    Run scriptPath
}

; Función para mostrar la ventana "Acerca de"
ShowAboutWindow(*) {
    ; Crear la ventana "Acerca de" sin barra de título y siempre encima
    aboutGui := Gui("-Caption +AlwaysOnTop +ToolWindow")
    aboutGui.BackColor := "0x202020"
    aboutGui.SetFont("s12 cFFFFFF", "Segoe UI")  ; Fuente predeterminada

    ; Establecer el tamaño deseado de la ventana
    desiredWidth := 110    ; Ancho en píxeles
    desiredHeight := 70    ; Alto en píxeles aumentado para acomodar el subrayado

    ; Calcular la altura del texto (aproximadamente)
    textHeight := 24  ; Altura aproximada para fuente de tamaño 12

    ; Calcular el margen superior para centrar verticalmente
    totalTextHeight := 2 * textHeight + 5  ; Añadimos 5 para el espacio del subrayado
    topMargin := (desiredHeight - totalTextHeight) / 2

    ; Añadir el primer texto centrado
    aboutGui.Add("Text", "x0 y" . topMargin . " w" . desiredWidth . " Center", "Lega | 2024")

    ; Crear texto clickeable para Github
    githubText := aboutGui.Add("Text", "x0 y" . (topMargin + textHeight + 5) . " w" . desiredWidth . " Center c5e55b9", "Github")
    
    ; Aplicar la fuente subrayada al control de texto "Github"
    githubText.SetFont("s12 Underline", "Segoe UI")  ; 'Underline' para subrayado

    ; Asignar el evento de clic al control "Github"
    githubText.OnEvent("Click", OpenGithub)

    ; Configurar y mostrar la GUI con esquinas redondeadas
    aboutGui.Show("Hide w" . desiredWidth . " h" . desiredHeight)

    ; Obtener el manejador de la ventana
    hwnd := aboutGui.Hwnd

    ; Definir el radio de las esquinas redondeadas
    radius := 20  ; Puedes ajustar este valor según tus preferencias

    ; Crear una región con esquinas redondeadas
    hRgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", desiredWidth, "Int", desiredHeight, "Int", radius, "Int", radius, "Ptr")

    ; Aplicar la región a la ventana para que tenga esquinas redondeadas
    DllCall("SetWindowRgn", "Ptr", hwnd, "Ptr", hRgn, "Int", True)

    ; Obtener la posición y tamaño de la ventana principal (MyGui)
    MyGui.GetPos(&mainX, &mainY, &mainW, &mainH)

    ; Calcular la posición para que aparezca debajo de la ventana principal, alineada a la derecha
    xPos := mainX + mainW - desiredWidth - 4
    yPos := mainY + mainH - 6

    ; Mostrar la ventana "Acerca de" en la posición calculada sin activarla
    aboutGui.Show("x" . Round(xPos) . " y" . Round(yPos) . " NoActivate")

    ; Configurar un temporizador para cerrar la ventana después de 2 segundos
    SetTimer(() => aboutGui.Destroy(), -2000)
}

; Función para abrir el enlace de Github
OpenGithub(*) {
    Run("https://github.com/legandrop/LGA_NukeShortcuts")
}
