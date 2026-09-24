# Roadmap

Lo que falta, ordenado por importancia. Lo hecho se borra de acá; la historia queda en
[`Changelog.md`](Changelog.md). Las decisiones abiertas están en [`Doc_Decisiones.md`](Doc_Decisiones.md).

## 1. Windows: lo que falta probar

Add keyframe, el calibrador, Frame Dope Sheet y el inicio con Windows ya andan con Nuke 15.1 y
NukeX 17.0. Falta grabar un atajo nuevo y ver el rechazo de uno tomado.

## 2. macOS

El código de mac está escrito pero nunca se compiló.

1. Compilar con `./compilar.sh --no-run` en la Mac, o con el workflow manual `Build macOS` de GitHub
   Actions, y corregir lo que salga.
2. Probar el permiso de Accesibilidad, los atajos (`⌘` en lugar de Ctrl), los clicks y el calibrador.
   En mac la burbuja del calibrador solo reconoce a Nuke cuando ya está al frente: revisar si alcanza.
3. Decisiones D-02 a D-05.
4. Empaquetado: `deploy.sh` y `create_dmg.sh` como LGA_VideoDownloader, firma ad-hoc antes de
   empaquetar y `.zip` con `ditto`.

## 3. Íconos

- El ícono nuevo (dos keys, `resources/icons/Alta/`) ya está en Windows. Falta en la Mac: medirlo con
  `make_planchas.py medir` de LGA_IconLab para confirmar las dos métricas, armar el `.icon` de Icon
  Composer y compilar `Assets.car` + `AppIcon.icns`, y la versión monocroma en modo template para la
  barra de menú.
- Una captura nueva del layout de Nuke para el calibrador a doble resolución: la actual mide 400 px de
  ancho y se ve borrosa en pantallas HiDPI.

## 4. Primer release

- Recorrer la checklist de app nueva de LGA_Base_QT_C_Py.
- Agregar la app al manifiesto de LGA_Updates, que es lo que lee el updater.
- En el sitio (LGA_SiteLega) la ficha ya está como «coming soon»: con el release, pasarla a
  `publicado` con su `assetDescarga`, y ponerle el ícono nuevo en lugar de la sigla «NS».
- Retirar `Legacy_AHK/` en un commit propio cuando la versión Qt llegue a paridad.

## 5. Investigar

- Encontrar el Dope Sheet por el árbol de accesibilidad de Nuke (UI Automation / AX) para no tener que
  calibrar (D-02, opción C).
- Si hay forma de poner el key en el knob bajo el puntero sin simular el menú contextual.
- Mostrar el contorno de la ventana de Nuke mientras se calibra, como el diseño.
