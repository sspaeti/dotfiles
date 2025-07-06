;=====================================================================o
;                   Feng Ruohang's AHK Script                         |
;                      CapsLock Enhancement                           |
;                      Updated Simon Späti                            |
;---------------------------------------------------------------------o
;Description:                                                         |
;    This Script is wrote by Feng Ruohang via AutoHotKey Script. It   |
; Provieds an enhancement towards the "Useless Key" CapsLock, and     |
; turns CapsLock into an useful function Key just like Ctrl and Alt   |
; by combining CapsLock with almost all other keys in the keyboard.   |
;                                                                     |
;Summary:                                                             |
;o----------------------o---------------------------------------------o
;|CapsLock;             | {ESC}  Especially Convient for vim user     |
;|CaspLock + `          | {CapsLock}CapsLock Switcher as a Substituent|
;|CapsLock + hjklwb     | Vim-Style Cursor Mover                      |
;|CaspLock + uiop       | Convient Home/End PageUp/PageDn             |
;|CaspLock + nm,.       | Convient Delete Controller                  |
;|CapsLock + zxcvay     | Windows-Style Editor                        |
;|CapsLock + Direction  | Mouse Move                                  |
;|CapsLock + Enter      | Mouse Click                                 |
;|CaspLock + {F1}~{F6}  | Media Volume Controller                     |
;|CapsLock + qs         | Windows & Tags Control                      |
;|CapsLock + ;'[]       | Convient Key Mapping                        |
;|CaspLock + dfert      | Frequently Used Programs (Self Defined)     |
;|CaspLock + 123456     | Dev-Hotkey for Visual Studio (Self Defined) |
;|CapsLock + 67890-=    | Shifter as Shift                            |
;-----------------------o---------------------------------------------o
;|Use it whatever and wherever you like. Hope it help                 |
;=====================================================================o


;=====================================================================o
;                       CapsLock Initializer                         ;|
;---------------------------------------------------------------------o
SetCapsLockState, AlwaysOff                                          ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                       CapsLock Switcher:                           ;|
;---------------------------------o-----------------------------------o
;                    CapsLock + ` | {CapsLock}                       ;|
;---------------------------------o-----------------------------------o
CapsLock & `::                                                       ;|
GetKeyState, CapsLockState, CapsLock, T                              ;|
if CapsLockState = D                                                 ;|
    SetCapsLockState, AlwaysOff                                      ;|
else                                                                 ;|
    SetCapsLockState, AlwaysOn                                       ;|
KeyWait, ``                                                          ;|
return                                                               ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                         CapsLock Escaper:                          ;|
;----------------------------------o----------------------------------o
;                        CapsLock  |  {ESC}                          ;|
;----------------------------------o----------------------------------o
CapsLock::Send, {ESC}                                                ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                    CapsLock Direction Navigator                    ;|
;-----------------------------------o---------------------------------o
;                      CapsLock + h |  Left                          ;|
;                      CapsLock + j |  Down                          ;|
;                      CapsLock + k |  Up                            ;|
;                      CapsLock + l |  Right                         ;|
;                      Ctrl, Alt Compatible                          ;|
;-----------------------------------o---------------------------------o
CapsLock & h::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, {Left}                                                 ;|
    else                                                             ;|
        Send, +{Left}                                                ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, ^{Left}                                                ;|
    else                                                             ;|
        Send, +^{Left}                                               ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & j::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, {Down}                                                 ;|
    else                                                             ;|
        Send, +{Down}                                                ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, ^{Down}                                                ;|
    else                                                             ;|
        Send, +^{Down}                                               ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & k::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, {Up}                                                   ;|
    else                                                             ;|
        Send, +{Up}                                                  ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, ^{Up}                                                  ;|
    else                                                             ;|
        Send, +^{Up}                                                 ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & l::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, {Right}                                                ;|
    else                                                             ;|
        Send, +{Right}                                               ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, ^{Right}                                               ;|
    else                                                             ;|
        Send, +^{Right}                                              ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                     CapsLock Home/End Navigator                    ;|
;-----------------------------------o---------------------------------o
;                      CapsLock + i |  Home                          ;|
;                      CapsLock + o |  End                           ;|
;                      Ctrl, Alt Compatible                          ;|
;-----------------------------------o---------------------------------o
CapsLock & i::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, {Home}                                                 ;|
    else                                                             ;|
        Send, +{Home}                                                ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, ^{Home}                                                ;|
    else                                                             ;|
        Send, +^{Home}                                               ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;-----------------------------------o                                ;|
;CapsLock & o::                                                       ;|
;if GetKeyState("control") = 0                                        ;|
;{                                                                    ;|
;    if GetKeyState("alt") = 0                                        ;|
;        Send, {End}                                                  ;|
;    else                                                             ;|
;        Send, +{End}                                                 ;|
;    return                                                           ;|
;}                                                                    ;|
;else {                                                               ;|
;    if GetKeyState("alt") = 0                                        ;|
;        Send, ^{End}                                                 ;|
;    else                                                             ;|
;        Send, +^{End}                                                ;|
;    return                                                           ;|
;}                                                                    ;|
;return                                                               ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                      CapsLock Page Navigator                       ;|
;-----------------------------------o---------------------------------o
;                      CapsLock + u |  PageUp                        ;|
;                      CapsLock + p |  PageDown                      ;|
;                      Ctrl, Alt Compatible                          ;|
;-----------------------------------o---------------------------------o
;CapsLock & u::                                                       ;|
;if GetKeyState("control") = 0                                        ;|
;{                                                                    ;|
;    if GetKeyState("alt") = 0                                        ;|
;        Send, {PgUp}                                                 ;|
;    else                                                             ;|
;        Send, +{PgUp}                                                ;|
;    return                                                           ;|
;}                                                                    ;|
;else {                                                               ;|
;    if GetKeyState("alt") = 0                                        ;|
;        Send, ^{PgUp}                                                ;|
;    else                                                             ;|
;        Send, +^{PgUp}                                               ;|
;    return                                                           ;|
;}                                                                    ;|
;return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & p::                                                       ;|
if GetKeyState("control") = 0                                        ;|
{                                                                    ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, {PgDn}                                                 ;|
    else                                                             ;|
        Send, +{PgDn}                                                ;|
    return                                                           ;|
}                                                                    ;|
else {                                                               ;|
    if GetKeyState("alt") = 0                                        ;|
        Send, ^{PgDn}                                                ;|
    else                                                             ;|
        Send, +^{PgDn}                                               ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                     CapsLock Mouse Controller                      ;|
;-----------------------------------o---------------------------------o
;                   CapsLock + Up   |  Mouse Up                      ;|
;                   CapsLock + Down |  Mouse Down                    ;|
;                   CapsLock + Left |  Mouse Left                    ;|
;                  CapsLock + Right |  Mouse Right                   ;|
;    CapsLock + Enter(Push Release) |  Mouse Left Push(Release)      ;|
;-----------------------------------o---------------------------------o
CapsLock & Up::    MouseMove, 0, -10, 0, R                           ;|
CapsLock & Down::  MouseMove, 0, 10, 0, R                            ;|
CapsLock & Left::  MouseMove, -10, 0, 0, R                           ;|
CapsLock & Right:: MouseMove, 10, 0, 0, R                            ;|
;-----------------------------------o                                ;|
CapsLock & Enter::                                                   ;|
SendEvent {Blind}{LButton down}                                      ;|
KeyWait Enter                                                        ;|
SendEvent {Blind}{LButton up}                                        ;|
return                                                               ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                           CapsLock Deletor                         ;|
;-----------------------------------o---------------------------------o
;                     CapsLock + n  |  Ctrl + Delete (Delete a Word) ;|
;                     CapsLock + m  |  Delete                        ;|
;                     CapsLock + ,  |  BackSpace                     ;|
;                     CapsLock + .  |  Ctrl + BackSpace              ;|
;-----------------------------------o---------------------------------o
CapsLock & ,:: Send, {Del}                                           ;|
CapsLock & .:: Send, ^{Del}                                          ;|
CapsLock & m:: Send, {BS}                                            ;|
CapsLock & n:: Send, ^{BS}                                           ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                            CapsLock Editor                         ;|
;-----------------------------------o---------------------------------o
;                     CapsLock + z  |  Ctrl + z (Cancel)             ;|
;                     CapsLock + x  |  Ctrl + x (Cut)                ;|
;                     CapsLock + c  |  Ctrl + c (Copy)               ;|
;                     CapsLock + v  |  Ctrl + z (Paste)              ;|
;                     CapsLock + a  |  Ctrl + a (Select All)         ;|
;                     CapsLock + y  |  Ctrl + z (Yeild)              ;|
;                     CapsLock + w  |  Ctrl + Right(Move as [vim: w]);|
;                     CapsLock + b  |  Ctrl + Left (Move as [vim: b]);|
;-----------------------------------o---------------------------------o
CapsLock & z:: Send, ^z                                              ;|
CapsLock & x:: Send, ^x                                              ;|
CapsLock & c:: Send, ^c                                              ;|
CapsLock & v:: Send, ^v                                              ;|
;CapsLock & a:: Send, ^a                                              ;|
CapsLock & y:: Send, ^y                                              ;|
CapsLock & w:: Send, ^{Right}                                        ;|
CapsLock & b:: Send, ^{Left}                                         ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                       CapsLock Media Controller                    ;|
;-----------------------------------o---------------------------------o
;                    CapsLock + F1  |  Volume_Mute                   ;|
;                    CapsLock + F2  |  Volume_Down                   ;|
;                    CapsLock + F3  |  Volume_Up                     ;|
;                    CapsLock + F3  |  Media_Play_Pause              ;|
;                    CapsLock + F5  |  Media_Next                    ;|
;                    CapsLock + F6  |  Media_Stop                    ;|
;-----------------------------------o---------------------------------o
CapsLock & F1:: Send, {Volume_Mute}                                  ;|
CapsLock & F2:: Send, {Volume_Down}                                  ;|
CapsLock & F3:: Send, {Volume_Up}                                    ;|
CapsLock & F4:: Send, {Media_Play_Pause}                             ;|
CapsLock & F5:: Send, {Media_Next}                                   ;|
CapsLock & F6:: Send, {Media_Stop}                                   ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                      CapsLock Window Controller                    ;|
;-----------------------------------o---------------------------------o
;                     CapsLock + s  |  Ctrl + Tab (Swith Tag)        ;|
;               Alt + CapsLock + q  |  Ctrl + Tab (Close Windows)    ;|
;                     CapsLock + g  |  AppsKey    (Menu Key)         ;|
;-----------------------------------o---------------------------------o
CapsLock & s::Send, ^{Tab}                                           ;|
;-----------------------------------o                                ;|
CapsLock & q::                                                       ;|
if GetKeyState("alt") = 0                                            ;|
{                                                                    ;|
    Send, ^w                                                         ;|
}                                                                    ;|
else {                                                               ;|
    Send, !{F4}                                                      ;|
    return                                                           ;|
}                                                                    ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & g:: Send, {AppsKey}                                       ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                        CapsLock Self Defined Area                  ;|
;-----------------------------------o---------------------------------o
;                     CapsLock + d  |  Alt + d(Dictionary)           ;|
;                     CapsLock + f  |  Alt + f(Search via Everything);|
;                     CapsLock + e  |  Open Search Engine            ;|
;                     CapsLock + r  |  Open Shell                    ;|
;                     CapsLock + t  |  Open Text Editor              ;|
;-----------------------------------o---------------------------------o
CapsLock & d:: Send, !d                                              ;|
CapsLock & f:: Send, !f                                              ;|
CapsLock & e:: Run http://cn.bing.com/                               ;|
CapsLock & r:: Run Powershell                                        ;|
CapsLock & t:: Run C:\Program Files (x86)\Notepad++\notepad++.exe    ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                        CapsLock Char Mapping                       ;|
;-----------------------------------o---------------------------------o
;                     CapsLock + ;  |  Enter (Cancel)                ;|
;                     CapsLock + '  |  =                             ;|
;                     CapsLock + [  |  Back         (Visual Studio)  ;|
;                     CapsLock + ]  |  Goto Define  (Visual Studio)  ;|
;                     CapsLock + /  |  Comment      (Visual Studio)  ;|
;                     CapsLock + \  |  Uncomment    (Visual Studio)  ;|
;                     CapsLock + 1  |  Build and Run(Visual Studio)  ;|
;                     CapsLock + 2  |  Debuging     (Visual Studio)  ;|
;                     CapsLock + 3  |  Step Over    (Visual Studio)  ;|
;                     CapsLock + 4  |  Step In      (Visual Studio)  ;|
;                     CapsLock + 5  |  Stop Debuging(Visual Studio)  ;|
;                     CapsLock + 6  |  Shift + 6     ^               ;|
;                     CapsLock + 7  |  Shift + 7     &               ;|
;                     CapsLock + 8  |  Shift + 8     *               ;|
;                     CapsLock + 9  |  Shift + 9     (               ;|
;                     CapsLock + 0  |  Shift + 0     )               ;|
;-----------------------------------o---------------------------------o
CapsLock & `;:: Send, {Enter}                                        ;|
CapsLock & ':: Send, =                                               ;|
CapsLock & [:: Send, ^-                                              ;|
CapsLock & ]:: Send, {F12}                                           ;|
;-----------------------------------o                                ;|
CapsLock & /::                                                       ;|
Send, ^e                                                             ;|
Send, c                                                              ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & \::                                                       ;|
Send, ^e                                                             ;|
Send, u                                                              ;|
return                                                               ;|
;-----------------------------------o                                ;|
CapsLock & 1:: Send,^{F5}                                            ;|
CapsLock & 2:: Send,{F5}                                             ;|
CapsLock & 3:: Send,{F10}                                            ;|
CapsLock & 4:: Send,{F11}                                            ;|
CapsLock & 5:: Send,+{F5}                                            ;|
;-----------------------------------o                                ;|
CapsLock & 6:: Send,+6                                               ;|
CapsLock & 7:: Send,+7                                               ;|
CapsLock & 8:: Send,+8                                               ;|
CapsLock & 9:: Send,+9                                               ;|
CapsLock & 0:: Send,+0                                               ;|
;---------------------------------------------------------------------o
;=====================================================================o
;                        Umlaut Char Mapping                       ;|
;-----------------------------------o---------------------------------o
;                     CapsLock + a  |  ä                             ;|
;                     CapsLock + a  |  ä                             ;|
;                     CapsLock + u  |  ü                             ;|
;                     LAlt + o      |  ö                             ;|
;                     LAlt + u      |  ü                             ;|
;                     LAlt + o      |  ö                             ;|
;                     z             |  y                             ;|
;                     y             |  z                             ;|
;-----------------------------------o---------------------------------o
CapsLock & a::
{
  GetKeyState, state, Lshift
  if state = D
    SendInput, {U+00C4}
  else
    SendInput, {U+00E4}
  return
}
CapsLock & u::
{
  GetKeyState, state, Lshift
  if state = D
    SendInput, {U+00DC}
  else
    SendInput, {U+00FC}
  return
}
CapsLock & o::
{
  GetKeyState, state, Lshift
  if state = D
    SendInput, {U+00D6}
  else
    SendInput, {U+00F6}
  return
}
;---------------------------------------------------------------------o
<!a::
{
  GetKeyState, state, Lshift
  if state = D
    SendInput, {U+00C4}
  else
    SendInput, {U+00E4}
  return
}
<!u::
{
  GetKeyState, state, Lshift
  if state = D
    SendInput, {U+00DC}
  else
    SendInput, {U+00FC}
  return
}
<!o::
{
  GetKeyState, state, Lshift
  if state = D
    SendInput, {U+00D6}
  else
    SendInput, {U+00F6}
  return
}
;---------------------------------------------------------------------o
; this is only used if keyboard has not switched it automatically     o
; default is switching it, as US layout has z and y not like QWERY as o
; I want                                                              o
;---------------------------------------------------------------------o
SC015::z                                                            ;|
SC02C::y                                                            ;|
;---------------------------------------------------------------------o


;=====================================================================o
;                  Delta Phoenix's AHK Script                         |
;                      Virtual Desktop Enhancement                    |
;---------------------------------------------------------------------o
;from: https://superuser.com/a/1050690
;IMPORTANT:
;
;In order for it to work you must ONLY use hotkeys for opening, closing, and changing desktops because the script listens for these hotkeys to know the current and total number of desktops.
;
;If you do create, close, or change desktops via the WIN+TAB menu with the mouse the script will stop working. In order to get it working again you will need to edit the first two lines to reflect the current state of your desktops. (desktopcount/currentdesktop)
;
;This doesn't mean you can't use the WIN+TAB screen as an overview of your current desktops. You can actually use it in combination of the hotkeys to organize your desktops. Yes, the hotkeys still work when the windows task viewer is open! (WIN+TAB) Just DO NOT use the mouse!!!
;
;Also, wait for the script to load after Windows startup before creating new desktops or it will not work. This could take a moment depending on how many startup programs you have.
;
;Ok, I added one more thing to make it easier to re-sync the script with your desktop state. There is now a hotkey that will display the state the script believes the desktops to be in so all you have to do is adjust your desktops with the mouse to fit the script and it will be all synced up again! For me with a Swiss keyboard it worked out nicely having the '? key next to 0 and it makes sense with a ? on it, but on other keyboards you may wish to change this which can be done easily by changing the line right after the hotkey for 0/10 (starting with #') to whatever you like.
;
;Actually, I just realized.... as long as the Desktop Count is correct than creating a new desktop will automatically re-sync the Current Desktop value.
;
#NoTrayIcon
;If the script stops working:
;Change the following values to reflect your current desktop state and reload the script.
;Remember to change them back to 1 after reloading the script if you have it set to start with Windows

desktopcount := 1
currentdesktop := 1

;You can change the hotkeys for creating, closing, and switching desktops bellow.
;The current hotkeys are CTRL+WIN+D for new desktop, CTRL+WIN+F4 to close desktop
;and ALT+NUMBER for switching desktops.
;For example, to change the hotkey for new desktop replace !^#D bellow with the desired hotkey.
;Refer to the autohotkey documentation for a full list of symbols refering to modifier keys,
;as you can see ! is ALT (^ would be CTRL) and # is WIN key.
;If you wanted to change the switch desktop from WIN key to CTRL for example you would have

!^D::NewDesktop()
!^w::CloseDesktop()
!1::SwitchDesktop(1)
!2::SwitchDesktop(2)
!3::SwitchDesktop(3)
!4::SwitchDesktop(4)
!5::SwitchDesktop(5)
!6::SwitchDesktop(6)
!7::SwitchDesktop(7)
!8::SwitchDesktop(8)
!9::SwitchDesktop(9)
!0::SwitchDesktop(10)
!'::MsgBox Desktop Count = %desktopcount%`nCurrent Desktop = %currentdesktop%

;Do not change anything after this line, unless you know what you are doing ;)
;-----------------------------------------------------------------------------------------------
SwitchDesktop(desktop)
{

    global desktopcount
    global currentdesktop
    desktopdiff := desktop - currentdesktop
    if (desktop > desktopcount)
    {
        return
    }
    if (desktopdiff < 0)
    {
        desktopdiff *= -1
        Loop %desktopdiff%
        {
        Send ^#{Left}
        }
    }
    else if (desktopdiff > 0)
    {
        Loop %desktopdiff%
        {
        Send ^#{Right}
        }
    }
    currentdesktop := desktop
}

NewDesktop()
{
    global desktopcount
    global currentdesktop
    if (desktopcount > 9)
    {
        return
    }
    desktopcount ++
    currentdesktop := desktopcount
    Send ^#d
}

CloseDesktop()
{
    global desktopcount
    global currentdesktop
    desktopcount --
    if (currentdesktop != 1)
    {
        currentdesktop --
    }
    Send ^#{f4}
}
;=====================================================================o
;                  Jump to App                                        |
;---------------------------------------------------------------------o
;start apps with hotkey
;from: https://gist.github.com/datmt/5b7d17e8886d14bb0024f8e6c45dabcd
;
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;
;
SetTitleMatchMode, 2
!b::

if WinExist("ahk_exe brave.exe")
{
    WinActivate
} else
{
	Run "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
}

Return


!n::

if WinExist("ahk_exe Obsidian.exe")
{
    WinActivate
} else
{
	Run "C:\Users\rah9\AppData\Local\Obsidian\Obsidian.exe"
}

Return


!w::

if WinExist("ahk_exe wt.exe")
{
    WinActivate
} else
{
	Run "C:\Users\rah9\AppData\Local\Microsoft\WindowsApps\wt.exe"
}

Return

!t::

if WinExist("ahk_exe wt.exe")
{
    WinActivate
} else
{
	Run "C:\Users\rah9\AppData\Local\Microsoft\WindowsApps\wt.exe"
}

Return


!v::

if WinExist("ahk_exe Code.exe")
{
    WinActivate
} else
{
	Run "C:\Users\rah9\AppData\Local\Programs\Microsoft VS Code\Code.exe"
}

Return

; DOES NOT WORK YET - therefore commented out
;;=====================================================================o
;;                  VD.akh: Virtual Desktop AHK Script                   |
;;                      Move apps to Virtual Desktops                    |
;;---------------------------------------------------------------------o
;;from: https://github.com/FuPeiJiang/VD.ahk
;;
;;#SETUP START
;#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
;#SingleInstance force
;ListLines Off
;SetBatchLines -1
;SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
;#KeyHistory 0
;#WinActivateForce
;
;Process, Priority,, H
;
;SetWinDelay -1
;SetControlDelay -1
;
;;START of gui stuff
;Gui,Font, s12, Segoe UI
;explanation=
;(
;Numpad0 to pin this Window on all desktops
;you can spam (Numpad2,Numpad1,Numpad2,Numpad1) for fun
;
;here's a challenge (you might lose this window):
;Unpin this using Numpad0
;go to Desktop 3 (Numpad3)
;this time, use Win + * on Numpad to come back to this window wherever you are
;(and wherever this window is)
;so you can move this window to desktop 2 (Numpad5), you go to desktop 1, and use Win + * on Numpad
;(if you want to search in this script, the hotkey is #NumpadMult)
;
;Numpad9 to throw a window to Desktop 3 (and not follow it)
;
;getters:
;f1 to see which desktop you currently are in
;f6 to see which desktop this window is in
;f2 to see the total number of virtual desktops
;
;(You might want to pin this window for this part):
;!NumpadAdd (Alt + Numpad+) to createDesktop and go to it
;f1 to see which desktop you currently are in
;
;but at this point, just use Win + Tab..
;these functions are mostly for script only,
;for example: I used VD.createUntil(3)
;at the start of this tutorial, to make sure we have at least 3 VD
;
;^+NumpadAdd (Ctrl Alt + Numpad+) to create until you have 3 desktops
;!NumpadSub (Alt + Numpad-) to remove the current desktop
;^+NumpadSub (Ctrl ALt + Numpad-) to delete the 3rd desktop
;
;more below, look at the hotkeys in code.
;)
;gui, add, Edit, -vscroll -E0x200 +hwndHWndExplanation_Edit, % explanation ; https://www.autohotkey.com/boards/viewtopic.php?t=3956#p21359
;;deselect edit text BY moving caret to start
;Postmessage,0xB1,0,0,, % "ahk_id " HWndExplanation_Edit
;gui, show,, VD.ahk examples WinTitle
;;END of gui stuff
;
;;include the library
;#Include %A_LineFile%\..\VD.ahk
;; or
;; #Include %A_LineFile%\..\_VD.ahk
;; ...{startup code}
;; VD.init()
;
;; VD.ahk : calls `VD.init()` on #Include
;; _VD.ahk : `VD.init()` when you want, like after a GUI has rendered, for startup performance reasons
;
;
;;you should WinHide invisible programs that have a window.
;WinHide, % "Malwarebytes Tray Application"
;;#SETUP END
;
;VD.createUntil(3) ;create until we have at least 3 VD
;
;return
;;
;;
;!^1::VD.MoveWindowToDesktopNum("A",1), VD.goToDesktopNum(1)
;!^2::VD.MoveWindowToDesktopNum("A",2), VD.goToDesktopNum(2)
;!^3::VD.MoveWindowToDesktopNum("A",3), VD.goToDesktopNum(3)
;!^4::VD.MoveWindowToDesktopNum("A",4), VD.goToDesktopNum(4)
;!^5::VD.MoveWindowToDesktopNum("A",5), VD.goToDesktopNum(5)
;!^6::VD.MoveWindowToDesktopNum("A",6), VD.goToDesktopNum(6)
;!^7::VD.MoveWindowToDesktopNum("A",7), VD.goToDesktopNum(7)
;!^8::VD.MoveWindowToDesktopNum("A",8), VD.goToDesktopNum(8)
;!^9::VD.MoveWindowToDesktopNum("A",9), VD.goToDesktopNum(9)
;; move window to left and follow it
;!^left::VD.goToDesktopNum(VD.MoveWindowToRelativeDesktopNum("A", -1))
;; move window to right and follow it
;!^right::VD.goToDesktopNum(VD.MoveWindowToRelativeDesktopNum("A", 1))