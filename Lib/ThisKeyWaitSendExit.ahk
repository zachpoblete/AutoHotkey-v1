; Get a new mouse to make the XButton2 + RButton hotkey consistent

#Include <Default Settings>
#Include <Functions>

global TIMEOUT := 500 ; Maximum time between a this key's down and up press for it to perform its native function

;========================================================================================================================
; RButton
;========================================================================================================================

#If GetKeyState("RButton", "P")

WheelDown::
	if WinActive("ahk_class Shell_TrayWnd")
	{
		Send ^!{Tab}
	}
	
	Send ^!{Tab}
	return

WheelUp::
	if WinActive("ahk_class Shell_TrayWnd")
	{
		Send ^!+{Tab}
	}
	
	Send ^!+{Tab}
	return

~LButton::
~Esc::
	return

#If

RButton::
	ThisKeyWaitSendExit()
	if InStr(A_ThisHotkey, "Wheel")
	{
		Send {Space}
	}
	return

;========================================================================================================================
; XButton2
;========================================================================================================================

#If GetKeyState("XButton2", "P")

RButton::Send {Ctrl Down}w{Ctrl Up} ; ^ doesn't work when using the K-Snake BM-600 (my current mouse).

#If

XButton2::
	WinMouseActivate()
	ThisKeyWaitSendExit()
	return

;========================================================================================================================
; Functions
;========================================================================================================================

ThisKeyWaitSendExit()
{
	KeyWait %A_ThisLabel%
	
	if (A_ThisHotkey = A_ThisLabel && A_TimeSinceThisHotkey <= TIMEOUT)
	{
		Send {%A_ThisLabel%}
		exit
	}
}
