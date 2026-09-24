# Decisiones

Decisiones que solo Lega puede tomar. Una abierta no se resuelve por cuenta propia: mientras tanto se
sigue con la opción reversible que se indica. Al decidirse, pasa a "Decididas" con fecha y opción.
El trabajo pendiente está en [`Doc_Roadmap.md`](Doc_Roadmap.md).

## Abiertas

### D-01 · Dónde vive la versión Qt (abierta el 2026-09-24)

- **Qué se decide:** si el port a Qt/C++ reemplaza a la versión AutoHotkey en este mismo repo o arranca
  en uno nuevo.
- **Opciones:**
  - A. Este repo. La versión AHK convive hasta la paridad y después se retira en un commit propio. Se
    conservan la historia, las estrellas y el link que ya circula.
  - B. Repo nuevo. Historia limpia, pero el link viejo queda apuntando a una app que ya no se mantiene.
- **Bloquea:** el primer commit de código.
- **Recomendación:** A.

### D-02 · Cómo se guarda el punto del Dope Sheet (abierta el 2026-09-24)

- **Qué se decide:** en qué unidades se guarda el punto calibrado. Hoy son coordenadas absolutas de
  pantalla escaladas contra un ancho fijo de 3440 px, y en cualquier otro monitor el click cae en otro
  lado.
- **Opciones:**
  - A. Porcentaje de la ventana principal de Nuke (89 % × 72 %). Sigue a la ventana si se mueve, se
    maximiza o cambia de monitor; falla si el Dope Sheet cambia de tamaño sin que cambie la ventana.
  - B. Píxeles desde la esquina inferior izquierda de la ventana de Nuke. Sobrevive a un ancho distinto
    si el panel está anclado abajo a la izquierda, pero no a un cambio de DPI.
  - C. Encontrar el Dope Sheet solo, por el árbol de accesibilidad (UI Automation en Windows, AX en
    mac), sin calibrar. Sin investigar todavía: no se sabe si Nuke expone sus paneles ahí.
- **Mientras tanto:** A, que es lo que muestra el diseño. C va al roadmap como investigación.
- **Recomendación:** A ahora; C si la investigación da positiva.

### D-03 · Los atajos solo con Nuke al frente (abierta el 2026-09-24)

- **Qué se decide:** si los atajos se registran solo mientras Nuke está en primer plano.
- **Evidencia:** la versión AHK los registra siempre y chequea Nuke adentro. Un atajo global registrado
  se come la combinación en todas las apps: `Ctrl+Shift+D` no llega a ningún otro programa mientras la
  app corre.
- **Opciones:**
  - A. Registrar al entrar Nuke al frente y soltar al salir. La tarjeta de estado muestra "Waiting for
    Nuke".
  - B. Registrar siempre, como hoy.
- **Recomendación:** A.

### D-04 · Atajos por defecto en macOS (abierta el 2026-09-24)

- **Qué se decide:** qué combinación trae la app en mac.
- **Opciones:**
  - A. `⌘⇧D` y `⌘⌥⇧D`: la traducción que hace Nuke de `Ctrl` a `Cmd`. Falta confirmar que Nuke no
    use ya esas combinaciones.
  - B. `⌃⇧D` y `⌃⌥⇧D`: las mismas teclas físicas que en Windows.
- **Mientras tanto:** A en el diseño. Se cambian desde Settings en cualquier caso.

### D-05 · Inicio con la sesión en macOS (abierta el 2026-09-24)

- **Qué se decide:** el mecanismo de "Open at login".
- **Opciones:**
  - A. `SMAppService.mainApp` (macOS 13 o posterior). Aparece en Ajustes > General > Ítems de inicio
    con el nombre de la app, y el usuario lo puede apagar ahí.
  - B. Un LaunchAgent (`~/Library/LaunchAgents/*.plist`). Anda en versiones viejas, pero en macOS 13+
    aparece como "ítem en segundo plano" de un desarrollador sin identificar.
- **Recomendación:** A, si no hace falta soportar macOS 12.

### D-06 · Cómo se distribuye en Windows (abierta el 2026-09-24)

- **Qué se decide:** si la versión Qt sigue siendo un `.zip` portable o pasa a instalador con updater.
- **Opciones:**
  - A. Instalador Inno + updater, como FolderSwitch. Inicio con Windows, desinstalación limpia y
    updates con verificación SHA-256.
  - B. `.zip` portable, como hoy. Sin updater: cada versión se baja a mano.
- **Recomendación:** A. En mac, DMG en cualquier caso.

## Decididas

(ninguna todavía)
