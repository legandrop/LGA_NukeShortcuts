# LGA Nuke Shortcuts

Esta herramienta, creada con AutoHotkey v2, proporciona dos atajos de teclado útiles para mejorar el flujo de trabajo en Nuke/NukeX, junto con una interfaz gráfica para configurar estos atajos y otras opciones.

## Instalación

LGA Nuke Shortcuts es una aplicación portable, lo que significa que no requiere una instalación tradicional:

1. Descarga el archivo ZIP del proyecto.
2. Extrae el contenido en cualquier ubicación de tu elección en tu computadora.
3. Ejecuta el archivo `LGA_Nuke_Shortcuts.exe` para iniciar la aplicación.

## Atajos de teclado predeterminados

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

LGA Nuke Shortcuts incluye una interfaz gráfica de usuario (GUI) para configurar fácilmente los atajos de teclado y otras opciones:

1. Ejecuta `LGA_Nuke_Shortcuts_Config.exe` para abrir la ventana de configuración.
2. En esta ventana puedes:
   - Cambiar los atajos de teclado para ambas funciones.
   - Ajustar la posición del clic para el Dope Sheet.
   - Calibrar la posición del Dope Sheet automáticamente.
   - Activar o desactivar el inicio automático con Windows.

### Calibración del Dope Sheet

1. Haz clic en el botón "Calibrate" en la ventana de configuración.
2. Sigue las instrucciones en pantalla para hacer clic en el área del Dope Sheet en Nuke.
3. La posición se guardará automáticamente.

### Inicio automático

Puedes activar o desactivar el inicio automático con Windows directamente desde la interfaz de configuración:

- Marca o desmarca la casilla "Run at Windows startup" en la ventana de configuración.

## Archivos necesarios

Para que LGA Nuke Shortcuts funcione correctamente, asegúrate de tener los siguientes archivos en la carpeta `+resources`:

- `LGA_Nuke_Shortcuts_Settings.ini`: Archivo de configuración que almacena los atajos de teclado y la posición del Dope Sheet.
- `check_on.jpg` y `check_off.jpg`: Imágenes utilizadas para el checkbox personalizado en la interfaz de configuración.
- `DopeSheetPos.bmp`: Imagen de ejemplo utilizada en la ventana de calibración.
- `ColorButton.ahk`: Script auxiliar para personalizar los botones en la interfaz de configuración.


v1.7 | Lega | 2024



### Para el desarrollador:
1. Está hecho con AutoHotkey v2.1 alpha 9, por lo que es compatible con Windows 10 y superior.
2. Para compilar a .exe, se utiliza el compilador de AutoHotkey ahk2exe con estos settings:
   - Elegir destination
   - Elegir icon
   - Elegir Autohotkey 2.1 alpha 14 U64
