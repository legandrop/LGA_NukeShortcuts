# Changelog

## 2026-09-24 (1)

La herramienta es un par de scripts AutoHotkey solo para Windows, con dos problemas de fondo: el punto
calibrado del Dope Sheet se guarda en coordenadas absolutas escaladas contra un ancho fijo de 3440 px,
así que el click cae en otro lado en cualquier otro monitor, y Nuke se detecta por una clase de ventana
de Qt 5 que no existe en Nuke 16. Se planifica el port a Qt 6 / C++ para Windows y macOS, como una sola
app de bandeja: `Docs/Doc_Roadmap.md` con los pasos y `Docs/Doc_Decisiones.md` con seis decisiones
abiertas (repo, unidades del punto calibrado, atajos solo con Nuke al frente, atajos en mac, inicio con
la sesión en mac, instalador). `Docs/` no entra en el zip del release.
[ Docs - Plan del port a Qt para Windows y macOS ]

