# Changelog

Cada entrada es una versión: se agrega arriba con el número siguiente (de a centésimos: 2.01, 2.02,
2.03...) y después se corre `sync_version`, que lo lleva a `CMakeLists.txt` y a `VERSION`.

v2.04:

El icono de la bandeja se veía débil: era el de la app reducido, y a 16 px sus planchas quedaban
corridas menos de medio píxel, un halo finito y borroso alrededor del cuerpo oscuro. Ahora es un PNG
por tamaño (16 a 48 px) con el desregistro ajustado al píxel, la misma fórmula del tray de
FolderSwitch: amarillo un paso a la izquierda, magenta uno arriba, cian medio paso abajo a la
derecha, cuerpo #262626 en barra clara y oscura, centrado en píxeles enteros. En pausa sigue al 40 %.
Los genera `tools/icono/armar_tray.ps1`, en PowerShell y sin Python.
[ Icono - Bandeja con el desregistro ajustado al pixel ]

v2.03:

El icono era el mismo glifo de radiación de Nuke que usa OpenInNukeX, y además anterior a la marca
(seis anillos de color en vez de tres planchas CMY). Se eligió uno propio entre seis propuestas: dos
keys de animación en fila, el rombo con el que Nuke marca cada key. Va con el tratamiento de la marca
(planchas CMY en multiply, cuerpo #262626, tintas levantadas a negro 38; cuerpo 65 %, separación
~24 px) en el `.ico` del exe y en el PNG de la ventana y la bandeja. `tools/icono/armar_icono.py`
regenera todo, y las seis siluetas quedan en `resources/icons/Alta/propuestas/`.
[ Icono - Dos keys propios en lugar del glifo de OpenInNukeX ]

v2.02:

Con la ventana abierta la tarjeta de estado decía siempre "Waiting for Nuke": la que está al frente es
la ventana misma, así que Nuke nunca podía estarlo. Ahora, con los atajos activos, dice que están
activos y aclara que fuera de Nuke las teclas pasan a las otras apps. Además la versión pasa a moverse
sola con el changelog, como en las otras apps LGA de versión continua: cada entrada es una versión de a
centésimos y `sync_version` (en PowerShell y en sh, sin Python) la lleva a `CMakeLists.txt` y `VERSION`.
[ App - Estado siempre activo y version continua ]

v2.01:

Los atajos ya se registraban solo con Nuke al frente, pero el aviso de "cambió la ventana del frente"
llega encolado: si el usuario apretaba el atajo justo al salir de Nuke, la combinación se perdía en
la otra app. Ahora el atajo pregunta en el momento qué ventana está al frente y, si no es Nuke,
suelta los atajos y le devuelve la combinación a esa app, como si Nuke Shortcuts no existiera.
[ Atajos - Fuera de Nuke la combinacion pasa a la app del frente ]

v2.00:

Faltaba la versión Qt/C++ multiplataforma. Se arma con la estructura de las otras apps LGA: tray, tema,
inicio con Windows, updater e instalador Inno de LGA_FolderSwitch, y todo lo que antes venía de otro
repo copiado adentro (`tools/`). Una capa de plataforma separa Windows (RegisterHotKey, SendInput) de
macOS (Carbon, CGEvent, permiso de Accesibilidad), y la segunda todavía no se compiló. Corrige los dos
problemas de la versión AutoHotkey: el punto del Dope Sheet se guarda relativo a la ventana de Nuke y
Nuke se detecta por el proceso. Los atajos solo se registran con Nuke al frente, y se pueden cambiar
desde Settings. `--self-test` y `--simulate-action` prueban la lógica sin mover el mouse.
[ App - Version Qt multiplataforma con instalador ]

La raíz del repo tiene que quedar libre para la estructura de la versión Qt. Los scripts AutoHotkey,
sus `.exe`, `+resources/`, el README de esa versión y el generador del zip pasan a `Legacy_AHK/`, donde
siguen funcionando igual porque leen todo relativo a su propia carpeta; el generador ahora busca el
`.git` un nivel arriba. Se deja de versionar un archivo de notas de trabajo que no era parte de la app.
[ Repo - La version AutoHotkey pasa a Legacy_AHK ]

La herramienta es un par de scripts AutoHotkey solo para Windows, con dos problemas de fondo: el punto
calibrado del Dope Sheet se guarda en coordenadas absolutas escaladas contra un ancho fijo de 3440 px,
así que el click cae en otro lado en cualquier otro monitor, y Nuke se detecta por una clase de ventana
de Qt 5 que no existe en Nuke 16. Se planifica el port a Qt 6 / C++ para Windows y macOS, como una sola
app de bandeja: `Docs/Doc_Roadmap.md` con los pasos y `Docs/Doc_Decisiones.md` con seis decisiones
abiertas (repo, unidades del punto calibrado, atajos solo con Nuke al frente, atajos en mac, inicio con
la sesión en mac, instalador). `Docs/` no entra en el zip del release.
[ Docs - Plan del port a Qt para Windows y macOS ]

