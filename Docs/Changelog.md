# Changelog

## 2026-09-24 (2)

La raíz del repo tiene que quedar libre para la estructura de la versión Qt. Los scripts AutoHotkey,
sus `.exe`, `+resources/`, el README de esa versión y el generador del zip pasan a `Legacy_AHK/`, donde
siguen funcionando igual porque leen todo relativo a su propia carpeta; el generador ahora busca el
`.git` un nivel arriba. Se deja de versionar un archivo de notas de trabajo que no era parte de la app.
[ Repo - La version AutoHotkey pasa a Legacy_AHK ]

## 2026-09-24 (1)

La herramienta es un par de scripts AutoHotkey solo para Windows, con dos problemas de fondo: el punto
calibrado del Dope Sheet se guarda en coordenadas absolutas escaladas contra un ancho fijo de 3440 px,
así que el click cae en otro lado en cualquier otro monitor, y Nuke se detecta por una clase de ventana
de Qt 5 que no existe en Nuke 16. Se planifica el port a Qt 6 / C++ para Windows y macOS, como una sola
app de bandeja: `Docs/Doc_Roadmap.md` con los pasos y `Docs/Doc_Decisiones.md` con seis decisiones
abiertas (repo, unidades del punto calibrado, atajos solo con Nuke al frente, atajos en mac, inicio con
la sesión en mac, instalador). `Docs/` no entra en el zip del release.
[ Docs - Plan del port a Qt para Windows y macOS ]

