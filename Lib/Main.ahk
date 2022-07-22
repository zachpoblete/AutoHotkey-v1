#Include <Default Settings>  ; Link to the lib goes here.
#Include <Globals>

;========================================================================================================================
; Auto-Execute
;========================================================================================================================

;------------------------------------------------------------------------------------------------------------------------
; _Lib
;------------------------------------------------------------------------------------------------------------------------

AutoExecute_Lib:
	global _UserLib := new _Lib("_UserLib", A_MyDocuments . "\AutoHotkey\Lib", "User Libraries")
	, _UserScripts  := new _Lib("_UserScripts", A_MyDocuments . "\AutoHotkey\Scripts", "User Scripts")

AutoExecute_Lib()

AutoExecute_Lib()
{
	activate_or_show_user_lib := ObjBindMethod(_UserLib, "activateOrShow")
	
	Menu Tray, Add, &Libraries, %activate_or_show_user_lib%
	Menu Tray, Add
	Menu Tray, NoStandard
	Menu Tray, Standard
}

;------------------------------------------------------------------------------------------------------------------------
; Keyboard
;------------------------------------------------------------------------------------------------------------------------

AutoExecuteKeyboard()

AutoExecuteKeyboard()
{
	HOTIF_EX := GetKeyState("NumLock", "T")
	HOTIF_EX_STR := "GetKeyState(""NumLock"", ""T"")"
	; The 2nd condition in the following #If statements must match HOTIF_EX.
	
	#If WinActive("ahk_exe msedge.exe") && GetKeyState("NumLock", "T")
	#If
	
	#If not _Hotkey.Remap[HotkeyDelModifierSymbols(A_ThisHotkey)] || not GetKeyState("NumLock", "T")
	#If _Hotkey.Remap[HotkeyDelModifierSymbols(A_ThisHotkey)] && GetKeyState("NumLock", "T")
	#If
	
	OnClipboardChange("ClipboardChanged")
	
	; Activate\Groups
	
	GroupAdd AdobeReaderWins, ahk_exe AcroRd32.exe
	GroupAdd ExplorerWins, ahk_class CabinetWClass
	GroupAdd InternalAHKWins, ahk_exe InternalAHK.exe
	GroupAdd PhotoWins, % A_Space . CHARS["LEFT_TO_RIGHT_MARK"] . "- Photos$ ahk_exe ApplicationFrameHost.exe"
	GroupAdd WordWins, ahk_class OpusApp ahk_exe WINWORD.EXE
	GroupAdd ZoomWins, ahk_class Z ahk_exe Zoom.exe, , , ZPToolBarParentWnd
	
	; JOHI
	
	_Hotkey.Remap.create("j", "Down", HOTIF_EX_STR)
	_Hotkey.Remap.create("o", "Up", HOTIF_EX_STR)
	_Hotkey.Remap.create("h", "Left", HOTIF_EX_STR)
	_Hotkey.Remap.create("i", "Right", HOTIF_EX_STR)
	_Hotkey.Remap.create(";", "Home", HOTIF_EX_STR)
	_Hotkey.Remap.create("'", "End", HOTIF_EX_STR)
	_Hotkey.Remap.create("k", "PgDn", HOTIF_EX_STR)
	_Hotkey.Remap.create("l", "PgUp", HOTIF_EX_STR)
	
	Gui JOHI:New
	Gui +LastFound +AlwaysOnTop -Caption +ToolWindow +Border
	Gui Color, Gray
	Gui_AddOutlinedText("JOHI", "s16 w700")
	
	trans_level := HOTIF_EX ? 255 : 0
	WinSet TransColor, Gray %trans_level%
	
	Gui Show, y616 NA
	
	; MSEdge
	
	_Hotkey.MSEdge.searchSelectionAsURL("u", , HOTIF_EX_STR)
	_Hotkey.MSEdge.searchSelectionAsURL("g", "https://www.google.com/search?q=", HOTIF_EX_STR)
	_Hotkey.MSEdge.searchSelectionAsURL("y", "https://www.youtube.com/results?search_query=", HOTIF_EX_STR)
}

;------------------------------------------------------------------------------------------------------------------------
; Mouse
;------------------------------------------------------------------------------------------------------------------------

AutoExecuteMouse()

AutoExecuteMouse()
{
	_Hotkey.ctrlTab("XButton1 & WheelDown", false)
	_Hotkey.ctrlTab("XButton1 & WheelUp", true)
}

;========================================================================================================================
; Timers
;========================================================================================================================

SetTimer ClosePopUps

ClosePopUps()
{
	; When selecting a different profile in RAKK Lam-Ang Pro FineTuner,
	; close the pop-up error:
	WinClose % "RAKK Lam-Ang Pro FineTuner " . CLASSES["DIALOGBOX"] . " ahk_exe RAKK Lam-Ang Pro Mechanical Keyboard.exe"
		, Failed to activate profile!
	
	; When opening qBittorent,
	; close the pop-up update:
	WinClose qBittorrent Update Available ahk_class Qt5152QWindowIcon
		; The website it brings you to to download the new version just looks sus.
	
	; When plugging in ANDIE USB,
	; close the pop-up errors:
	WinClose % "Microsoft Windows " . CLASSES["DIALOGBOX"] . " ahk_exe explorer.exe, Format disk"
	WinClose % "Location is not available " . CLASSES["DIALOGBOX"] . " ahk_exe explorer.exe, OK"
}

;========================================================================================================================
; Include
;========================================================================================================================

#Include <Functions>
#Include %A_MyDocuments%\AutoHotkey\Lib\AcceleratedScroll\AcceleratedScroll.ahk

#Include <Classes>
#Include <_BrightnessSetter>
#Include <_Lib>

#Include <Auto-Close Braces>
#Include <Script Hotkeys>
#Include <Keyboard>
#Include <Mouse>

;========================================================================================================================
; Hotkeys
;========================================================================================================================

;------------------------------------------------------------------------------------------------------------------------
; _Lib
;------------------------------------------------------------------------------------------------------------------------

#^c::
	if % not WinActive("ahk_class SciTEWindow") && WinExist("ahk_class SciTEWindow") && not GetKeyState("CapsLock", "T")
	{
		WinActivate
		return
	}
	
	_UserLib.showORCreateFileTOC()
	return

#^e:: _UserScripts.showORCreateFileTOC(A_ScriptName)

#If WinActive("ahk_class AutoHotkeyGUI", "_Lib")

=:: _Lib.toggleItem(true)
-:: _Lib.toggleItem(false)

#If
