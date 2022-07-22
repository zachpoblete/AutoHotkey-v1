#Include <Default Settings>
#Include <Globals>
#Include <Functions>
#Include <Classes>
#Include %A_MyDocuments%\AutoHotkey\Lib\AcceleratedScroll\AcceleratedScroll.ahk
#Include <Auto-Close Braces>

;========================================================================================================================
; Wheel + Native Modifiers
;========================================================================================================================

WheelUp::
WheelDown::
	AcceleratedScroll()
	return

#If MouseControlFocus("Scintilla1", "ahk_class SciTEWindow")

+WheelUp::
	; Scroll left.
	SendMessage % WIN32_CONSTS["EM_LINESCROLL"], -16, , Scintilla1, A
	return

+WheelDown::
	; Scroll right.
	SendMessage % WIN32_CONSTS["EM_LINESCROLL"], 16, , Scintilla1, A
	return

#If

~^WheelUp::
~^WheelDown::
	MouseWinActivate()
	return

;========================================================================================================================
; RButton
;========================================================================================================================

RButton & WheelDown:: AltTab
RButton & WheelUp::   ShiftAltTab

#If GetKeyState("Shift", "P")

RButton & LButton::
	Send +{Del}
	return

#If

RButton & LButton::
	if % WinActive("Task Switching ahk_class XamlExplorerHostIslandWindow")
	{
		Click
		return
	}
	
	Send {Del}
	return

RButton & MButton::
	if % WinActive("Task Switching ahk_class XamlExplorerHostIslandWindow")
	{
		Click M
	}
	return

RButton::
	Click R
	EndkeyTyped()
	return

;========================================================================================================================
; MButton
;========================================================================================================================

MButton & WheelUp::
	MouseWinActivate()
	WinMaximize A
	return

MButton & WheelDown::
	if % MouseWinActivate(CLASSES["ZOOM", "WAIT_HOST"]) || WinActive(CLASSES["ZOOM", "VID_PREVIEW"])
	{
		WinMinimize
		return
	}
	
	Send #{Down}
	return

MButton & RButton::
	Send {Ctrl Down}+{Click}{Ctrl Up}
	EndkeyTyped()
	return

MButton::
	if % MouseWinActivate(CLASSES["ZOOM", "MEETING"])
	{
		Send #!{PrintScreen}
	}
	else if % _WinActive.match2("AutoHotkey Community ahk_exe msedge.exe")
		; Check if an Office app is active:
		|| _WinActive.matchRegEx("ahk_exe .EXE$")
	{
		Send ^{Click}
	}
	else
	{
		Click M
	}
	
	EndkeyTyped()
	return

;========================================================================================================================
; XButton1
;========================================================================================================================

#If MouseWinActivate("ahk_exe msedge.exe")

XButton1 & WheelDown::
	if % GetKeyState("Ctrl")
	{
		Send {Ctrl Up}
	}
	
	Send {Ctrl Down}+a{Ctrl Up}
	return

XButton1 & WheelUp::
	Send {Esc}
	return

#If WinActive("ahk_exe AcroRd32.exe")

XButton1 & WheelDown::
	Send {Ctrl Down}{PgDn}{Ctrl Up}
	return

XButton1 & WheelUp::
	Send {Ctrl Down}{PgUp}{Ctrl Up}
	return

#If

XButton1 & LButton::
	if % MouseWinActivate("ahk_exe Notion.exe")
	{
		Send {Ctrl Down}[{Ctrl Up}
		return
	}
	
	Click X1
	return

XButton1 & RButton::
	if % MouseWinActivate("ahk_exe Notion.exe")
	{
		Send {Ctrl Down}]{Ctrl Up}
		return
	}
	
	Click X2
	return

XButton1 & MButton::
	MouseWinActivate()
	Send {F5}
	return

;========================================================================================================================
; XButton2
;========================================================================================================================

XButton2 & WheelDown::
	if % MouseWinActivate("ahk_exe Discord.exe") || WinActive("ahk_exe Messenger.exe")
	{
		Send !{Down}
	}
	else if % WinActive("ahk_exe POWERPNT.EXE")
	{
		Send {PgDn}
	}
	else if % WinActive("ahk_exe AcroRd32.exe")
	{
		Send {Ctrl Down}{Tab}{Ctrl Up}
	}
	else
	{
		Send {Ctrl Down}{PgDn}{Ctrl Up}
	}
	
	EndkeyTyped()
	return

XButton2 & WheelUp::
	if % MouseWinActivate("ahk_exe Discord.exe") || WinActive("ahk_exe Messenger.exe")
	{
		Send !{Up}
	}
	else if % WinActive("ahk_exe POWERPNT.EXE")
	{
		Send {PgUp}
	}
	else if % WinActive("ahk_exe AcroRd32.exe")
	{
		Send {Ctrl Down}+{Tab}{Ctrl Up}
	}
	else
	{
		Send {Ctrl Down}{PgUp}{Ctrl Up}
	}
	
	EndkeyTyped()
	return

XButton2 & LButton::
	MouseWinActivate()
	Send {Ctrl Down}+t{Ctrl Up}
	return

XButton2 & RButton::
	MouseWinActivate()
	Send {Ctrl Down}w{Ctrl Up}
	
	EndkeyTyped()
	return

XButton2 & MButton::
	if % MouseWinActivate(CLASSES["ZOOM", "MEETING"])
	{
		; Show "End Meeting or Leave Meeting?" prompt in the middle of the screen instead of the corner of the window.
		Send !q
		return
	}
	if % WinActive(CLASSES["ZOOM", "HOME"])
	{
		; Check if a visible Zoom meeting window exists.
		if % WinExist("Zoom ahk_pid " . WinGetPID(CLASSES["ZOOM", "TOOLBAR"]))
		{
			ControlSend ahk_parent, !q, % CLASSES["ZOOM", "MEETING"]
			return
		}
		
		Process Close, Zoom.exe
		return
	}
	if % WinActive("ahk_exe PowerToys.Settings.exe")
	{
		WinClose
		return
	}
	
	Send !{F4}
	return

;========================================================================================================================
; Timers
;========================================================================================================================

#+r::
	SetMouseTimers()
	{
		timer := _Timer.__Get()
		
		if % not timer
		{
			if % GetKeyState("CapsLock", "T")
			{
				_Timer.__Set("CaretGetPos", 10)
				return
			}
			
			_Timer.__Set("MouseGetPosOpposite", 10)
			return
		}
		
		switch timer
		{
			case "CaretGetPos":
				_Timer.__Set("CaretGetPos", "Off")
				ToolTip
				
				if % GetKeyState("CapsLock", "T")
				{
					return
				}
				
				_Timer.__Set("MouseGetPosOpposite", 10)
				return
			case "MouseGetPosOpposite":
				_Timer.__Set("MouseGetPosOpposite", "Off")
				ToolTip
				
				if % not GetKeyState("CapsLock", "T")
				{
					return
				}
				
				_Timer.__Set("CaretGetPos", 10)
				return
		}
	}

MouseGetPosOpposite()
{
	MouseGetPos mouse_x, mouse_y
	WinGetPos, , , win_w, win_h, A
	ToolTip % "Relative to right and bottom: " . win_w - mouse_x . " and " . win_h - mouse_y
}

CaretGetPos()
{
	ToolTip x%A_CaretX% y%A_CaretY%, A_CaretX, A_CaretY - 20
}

#LButton::
	WinDrag()
	{
		if % MouseWinActivate("ahk_class WorkerW ahk_exe Explorer.EXE") || WinGetMinMax("A") != 0
		{
			return
		}
		
		CoordMode Mouse, Screen
		MouseGetPos mouse_start_x, mouse_start_y
		WinGetPos win_original_x, win_original_y, , , A
		
		while GetKeyState("LButton", "P")
		{
			if % GetKeyState("Esc", "P")
			{
				WinMove A, , win_original_x, win_original_y
				break
			}
			
			MouseGetPos mouse_x, mouse_y
			WinGetPos win_x, win_y, , , A
			WinMove A, , win_x + (mouse_x - mouse_start_x), win_y + (mouse_y - mouse_start_y)
			
			mouse_start_x := mouse_x
			mouse_start_y := mouse_y
			
			Sleep %SHORTEST_NORM_DELAY%
		}
	}
