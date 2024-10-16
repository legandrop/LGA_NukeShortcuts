#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.



;---------Nuke--------


^+d:: ; Ctrl+Shift+D Para agregar un keyframe en donde está el cursor parpadeando o sino en donde esta el puntero del mouse
{
    CoordMode, Mouse, Screen
    MouseMove, %A_CaretX%, %A_CaretY%, 0
    Click, Right
    Sleep, 50 ; Espera breve para que se abra el menú contextual
    Send, {Down}
    Sleep, 30 ; Espera breve antes de enviar Enter
    Send, {Enter}
    return
}



^!F7::  ; Click en la parte de abajo del viewer para que anden los shortcuts para saltar de key a key
ControlSend, Qt5QWindowOwnDCIcon1, {Ctrl Down}{Ctrl Up}{Alt Down}{Alt Up}
MouseGetPos CurX, CurY
MouseMove 900, 1230, 0
Click
;Sleep 1000
Send ^a
Sleep 10
Send {f}
MouseMove %CurX%, %CurY%, 0
return
