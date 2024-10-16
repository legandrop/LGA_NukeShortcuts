# LGA Nuke Shortcuts

Esta herramienta, creada con AutoHotkey v2, proporciona dos atajos de teclado útiles para mejorar el flujo de trabajo en Nuke/NukeX.

## Atajos de teclado

1. **Ctrl+Shift+D**: 
   - Función: Agrega un keyframe en la posición actual del cursor o del puntero del mouse.
   - Uso: Coloca el cursor donde desees agregar el keyframe y presiona Ctrl+Shift+D. Si no hay un cursor visible, utilizará la posición actual del mouse.

2. **Ctrl+Alt+Shift+D**: 
   - Función: Selecciona todos los keyframes en el Dope Sheet o Curve Editor y ajusta la vista para mostrarlos todos.
   - Uso: Presiona Ctrl+Alt+Shift+D cuando estés en la ventana de Nuke. El script realizará las siguientes acciones:
     1. Moverá el mouse a la posición configurada del Dope Sheet o Curve Editor.
     2. Seleccionará todos los keyframes (equivalente a presionar Ctrl+A).
     3. Ajustará la vista para mostrar todos los keyframes seleccionados (equivalente a presionar F).
     4. Volverá a la posición original del mouse.
   - Resultado: Verás todos los keyframes seleccionados y la vista se ajustará para mostrarlos de manera óptima, facilitando la visualización y edición de la animación completa.

## Configuración

Para ajustar la posición del clic para el segundo atajo, edita el archivo `LGA_Nuke_Shortcuts_Settings.ini`:

1. Abre el archivo `LGA_Nuke_Shortcuts_Settings.ini` con un editor de texto.
2. Modifica los valores de `TargetX` y `TargetY` bajo la sección `[MousePosition]`.
3. Estos valores representan la posición del panel Dope Sheet o Curve Editor en tu interfaz de NukeX.
4. Ajusta estos valores según la resolución de tu pantalla y la configuración de tu interfaz.

## Inicio automático

Se incluye un script llamado `LGA_AutoStart_Manager.bat` que te permite gestionar el inicio automático de LGA Nuke Shortcuts con Windows:

- Función: Crea o elimina un acceso directo en la carpeta de inicio de Windows.
- Uso: Ejecuta `LGA_AutoStart_Manager.bat`:
  - Si no existe un acceso directo, lo creará y LGA Nuke Shortcuts se iniciará automáticamente con Windows.
  - Si ya existe un acceso directo, lo eliminará y LGA Nuke Shortcuts ya no se iniciará automáticamente con Windows.
- Esto te permite alternar fácilmente entre tener LGA Nuke Shortcuts iniciándose automáticamente o no.
