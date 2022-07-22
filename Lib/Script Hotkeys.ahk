#Include <Default Settings>
#Include <Globals>
#Include <Functions>
#Include <Classes>
#Include <_Lib>
#Include <Auto-Close Braces>

#h:: Run https://www.autohotkey.com/docs/AutoHotkey.htm

#+h::
	GotoInDocs()
	{
		selection := GetSelection()
		
		if % not selection
		{
			return
		}
		
		Run % "https://www.autohotkey.com/docs/commands/" . StrReplace(selection, "#", "_", , 1) . ".htm"
	}

#^t::
	EditTesting()
	{
		num := GetKeyState("CapsLock", "T") ? " 2" : ""
		Run edit Testing%num%.ahk, % _UserScripts.folder
	}

#^v:: ListVars
#^h:: ListHotkeys
#^l:: ListLines
#^k:: KeyHistory

#^w::
	WindowSpy()
	{
		switch WinGetMinMax("Window Spy ahk_class AutoHotkeyGUI")
		{
			case "":
				Run WindowSpy.ahk, C:\Program Files\AutoHotkey
				return
			case -1:
				WinActivate Window Spy ahk_class AutoHotkeyGUI
				Send !{Tab}
				return
			default:
				WinClose Window Spy ahk_class AutoHotkeyGUI
				return
		}
	}

#^x:: ExitApp
#^r:: Reload
#^p:: Pause

#^s::
	SuspendRemapsOrHotkeys()
	{
		Suspend Permit
		
		if % not GetKeyState("CapsLock", "T")
		{
			Suspend Toggle
			
			; Safely release Win keys because they get stuck
			; if this hotkey is pressed and released too quickly and then other keys are pressed.
			Send % "{Blind}" . KEYS["MENU_MASK"] . "{LWin Up}{RWin Up}"
			return
		}
		
		for i, key in _Hotkey.Remap.list
		{
			_Hotkey.Remap[key] := not _Hotkey.Remap[key]
		}
		
		ToolTipTimed("Remaps " . (_Hotkey.Remap[_Hotkey.Remap.list[1]] ? "en" : "dis") . "abled", 1)
	}
