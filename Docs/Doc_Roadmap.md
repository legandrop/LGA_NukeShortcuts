# Roadmap

Lo que falta, ordenado por importancia. Lo hecho se borra de acá; la historia queda en
[`Changelog.md`](Changelog.md). Las decisiones abiertas están en [`Doc_Decisiones.md`](Doc_Decisiones.md).

## 1. Port a Qt 6 / C++ (Windows y macOS)

Una sola app de bandeja con su ventana de Settings, en lugar de los dos exe de AutoHotkey.

1. **Decisiones D-01 a D-06.**
2. **Esqueleto.** Proyecto CMake derivado de LGA_Base_QT_C_Py. Tema, tarjetas, barra de título propia,
   menú del tray, inicio con Windows, settings en AppData, capturas sin escritorio y scripts de
   compilación tomados de LGA_FolderSwitch.
3. **Capa de plataforma** detrás de interfaces, una implementación por sistema:
   - Atajos globales: `RegisterHotKey` en Windows, `RegisterEventHotKey` en mac.
   - App al frente: `SetWinEventHook` en Windows, `NSWorkspace` en mac. Nuke se reconoce por el proceso,
     no por la clase de ventana (`Qt5QWindowIcon` no existe en Nuke 16).
   - Clicks y teclas: `SendInput` en Windows, `CGEvent` en mac. Soltar los modificadores del atajo antes
     de mandar teclas, como hace el script actual.
   - Ventana principal de Nuke: posición y tamaño, para el punto relativo (D-02).
4. **Acciones.** Add keyframe y Frame Dope Sheet, con un modo que solo loguea la secuencia para
   probarla sin mover el mouse.
5. **Calibrador.** Diálogo con la captura `DopeSheetPos.bmp` y los tres pasos, y después el click sobre
   Nuke con la burbuja que sigue al puntero. Esc cancela.
6. **Grabar atajos** desde Settings, con rechazo de combinaciones que ya usa otra app.
7. **macOS:** bundle sin ícono en el Dock (`LSUIElement`), ícono de barra de menú en modo template,
   permiso de Accesibilidad (estado en la tarjeta y botón para abrir Ajustes), `Cmd` en lugar de `Ctrl`
   en las teclas que se mandan a Nuke, inicio con la sesión (D-05).
8. **Íconos:** app, tray de Windows y barra de menú de mac, con el sistema de íconos de las apps LGA.
9. **Distribución:** instalador y updater en Windows (D-06), DMG y build de CI en mac.
10. **Migración** desde la versión AHK: los atajos del `.ini` viejo se importan; el punto calibrado no
    (era absoluto a la pantalla) y se pide recalibrar. El acceso directo de la carpeta Startup se borra
    solo si apunta a esta instalación.
11. **README en inglés** para la versión Qt, y retiro de los `.ahk` y sus `.exe` al llegar a paridad.

## 2. Investigar

- Encontrar el Dope Sheet por el árbol de accesibilidad de Nuke (UI Automation / AX) para no tener que
  calibrar (D-02, opción C).
- Si hay forma de poner el key en el knob bajo el puntero sin simular el menú contextual.
