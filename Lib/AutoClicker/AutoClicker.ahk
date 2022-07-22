#NoEnv
#SingleInstance Force

SetMouseDelay 0
SetWorkingDir %A_ScriptDir%

#Include Create_UncannyClicker_ico.ahk
#Include Create_Clicktastic_ico.ahk

uncannyclicker := Create_UncannyClicker_ico()
clicktastic := Create_Clicktastic_ico()

Menu Tray, NoStandard
Menu Tray, Add, E&xit
Menu Tray, Icon, HBITMAP:*%clicktastic%, , 1

Pause On

F1::
	if A_IsPaused
		Menu Tray, Icon, HBITMAP:*%uncannyclicker%
	else
		Menu Tray, Icon, HBITMAP:*%clicktastic%
	Pause, , 1
	SetTimer AutoClicker, 0
	return

E&xit:
	ExitApp
	return

AutoClicker:
	Click
	return
