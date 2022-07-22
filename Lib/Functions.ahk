#Include <Default Settings>

;========================================================================================================================
; Custom
;========================================================================================================================

GetFileExt(file_name)
{
	RegExMatch(file_name, "\.[^.]+$", file_ext)
	return file_ext
}

QueryToURL(query, engine)
{
	return engine . StrReplace(StrReplace(StrReplace(query, "&", "&26"), "+", "%2B"), A_Space, "+")
	; URL encoding is used to encode special characters in query strings.
}

SendOnPrefixKeyDownAndUp()
{
	Send {Ctrl Down}{Tab}
	SendOnPrefixKeyUp("{Ctrl Up}")
}

SendOnPrefixKeyUp(key)
{
	EndkeyTyped()
	
	KeyWait % HotkeyGetPrefixKey(A_ThisHotkey)
	Send %key%
}

StrDel(haystack, needle, limit := 1)
{
	return StrReplace(haystack, needle, , , limit)
}

ToolTipTimed(text, timeout_s := 10, x := "", y := "")
{
	ToolTip %text%, %x%, %y%
	
	timeout_ms := timeout_s * 1000
	SetTimer ToolTipDestroy, -%timeout_ms%
}

ToolTipDestroy(tool_tip_index := "")
{
	ToolTip, , , , %tool_tip_index%
}

;------------------------------------------------------------------------------------------------------------------------
; Hotkey
;------------------------------------------------------------------------------------------------------------------------

HotkeyDelModifierSymbols(hotkey)
{
	hotkey := StrReplace(RegExReplace(hotkey, " Up$"), A_Space)
	
	if % InStr(hotkey, "&")
	{
		return StrSplit(hotkey, "&")
	}
	
	return RegExReplace(hotkey, "[#!^+<>*~$]")
}

HotkeyEncloseInBraces(hotkey)
{
	if % InStr(hotkey, "&")
	{
		return "{" . RegExReplace(hotkey, " *& *", "}{") . "}"
	}
	
	if % RegExMatch(hotkey, " Up$")
	{
		return "{" . hotkey . "}"
	}
	
	return RegExReplace(hotkey, "([#!^+<>]*)([^*~$]*)", "$1{$2}")
}

HotkeyGetPrefixKey(hotkey)
{
	if % HotstringGetAbbrev(hotkey)
	{
		return
	}
	
	hotkey_keys := HotkeyDelModifierSymbols(hotkey)
	
	if % not IsObject(hotkey_keys)
	{
		return hotkey_keys
	}
	
	return hotkey_keys[1]
}

HotstringGetAbbrev(hotstring)
{
	RegExMatch(hotstring, "^:[^:]*:\K.+", abbrev)
	return abbrev
}

;------------------------------------------------------------------------------------------------------------------------
; Window
;------------------------------------------------------------------------------------------------------------------------

ActivateOrRun(to_run, working_dir := "", to_activate := "")
{
	if % to_activate = ""
	{
		to_activate := "ahk_exe " . to_run
	}
	
	if % not WinExist(to_activate)
	{
		Run %to_run%, %working_dir%
		return
	}
	if % InStr(to_activate, "ahk_group")
	{
		GroupActivate % LTrim(StrDel(to_activate, "ahk_group")), R
		return
	}
	
	WinActivate %to_activate%
}

CheckGroupExistsAndActivateRel(group_name)
{
	if % not WinExist("ahk_group " . group_name)
	{
		return
	}
	
	GroupActivate %group_name%, R
}

MouseControlFocus(control := "", win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	MouseGetPos, , , mouse_hwnd, mouse_class_nn
	WinActivate ahk_id %mouse_hwnd%
	ControlFocus %mouse_class_nn%
	
	hwnd := WinActive(win_title, win_text, excluded_title, excluded_text)
	
	if % not hwnd
	{
		return
	}
	
	if % control
	{
		focused_mouse_control_text := StrReplace(ControlGetText(mouse_class_nn), ",", ",,")
		
		if % control ~= "\A(" mouse_class_nn "|" focused_mouse_control_text ")\z"
		{
			return mouse_class_nn
		}
		return
	}
	
	if % win_title
	{
		focused_mouse_control_hwnd := "ahk_id " . ControlGetFocus()
		
		if % win_title != focused_mouse_control_hwnd
		{
			return mouse_class_nn
		}
		return
	}
	
	return hwnd
}

MouseWinActivate(win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	MouseGetPos, , , mouse_hwnd
	WinActivate ahk_id %mouse_hwnd%
	return WinActive(win_title, win_text, excluded_title, excluded_text)
}

SciTE_GetFileName(scite_win_title)
{
	if % scite_win_title = "A"
	{
		scite_win_title := WinGetTitle("A")
	}
	
	return RegExReplace(scite_win_title, " [-\*] SciTE4AutoHotkey.*$")
}

;------------------------------------------------------------------------------------------------------------------------
; Gui
;------------------------------------------------------------------------------------------------------------------------

Gui_AddOutlinedText(text, options := "", fill_color := "White", outline_color := "Black", outline_weight := 1)
{
	Gui Font, c%outline_color% %options%
	Gui Add, Text, , %text%
	Gui Add, Text, % "xs+" . outline_weight * 2 . " ys wp hp Center BackgroundTrans", %text%
	Gui Add, Text, % "xs+" . outline_weight * 2 . " ys+" . outline_weight * 2 . " wp hp Center BackgroundTrans", %text%
	Gui Add, Text, % "xs ys+" . outline_weight * 2 . " wp hp Center BackgroundTrans", %text%
	
	Gui Font, c%fill_color% %options%
	Gui Add, Text, % "xs+" . outline_weight . " ys+" . outline_weight . " wp hp Center BackgroundTrans", %text%
}

Gui_Fade(show_or_hide, time_ms, trans_color)
{
	count := Floor(time_ms / SHORTEST_NORM_DELAY)
	
	Loop %count%
	{
		if % GetKeyState("NumLock", "T")
		{
			WinSet TransColor, Gray 255
			break
		}
		
		WinSet TransColor, % trans_color . A_Space . Floor((show_or_hide ? "+" : "-") . A_Index * 255/count)
		Sleep %SHORTEST_NORM_DELAY%
	}
}

;------------------------------------------------------------------------------------------------------------------------
; Clipboard
;------------------------------------------------------------------------------------------------------------------------

ClipboardChanged(type := "")
{
	static prior_type := 0
	
	if % type != ""
	{
		prior_type := type
	}
	return prior_type
}

ClipboardReplace(replacement)
{
	Clipboard := ""
	Sleep 30
	Clipboard := replacement
	Sleep 30
}

EmptyClipboard()
{
	Clipboard := ""
	Sleep 50
}

GetSelection()
{
	OnClipboardChange("ClipboardChanged", 0)
	saved_clipboard := ClipboardAll
	EmptyClipboard()
	
	Send {Ctrl Down}c{Ctrl Up}
	Sleep 30
	selection := Clipboard
	
	ClipboardReplace(saved_clipboard)
	OnClipboardChange("ClipboardChanged", 1)
	
	return selection
}

GetSelectionOrExit()
{
	selection := GetSelection()
	
	if % not selection
	{
		exit
	}
	
	return selection
}

SendInstantRaw(keys)
{
	OnClipboardChange("ClipboardChanged", 0)
	clip_saved := ClipboardAll
	EmptyClipboard()
	
	Clipboard := keys
	Sleep 30
	Send ^v
	Sleep 30
	
	ClipboardReplace(clip_saved)
	OnClipboardChange("ClipboardChanged", 1)
}

;------------------------------------------------------------------------------------------------------------------------
; Text Manipulation
;------------------------------------------------------------------------------------------------------------------------

GetLineCount(text)
{
	RegExReplace(text, "m)^", , count)
	return count
}

GetIndents(text)
{
	RegExMatch(text, "\A\t+", tabs)
	return tabs
}

LineGetIndents()
{
	Send {Home}+{Home}
	return GetSelection()
}

LineGetText()
{
	text := GetSelection()
	Send % "{Left 2}{Right}{End}{Home 2}{Shift Down}{Down " . GetLineCount(text) . "}{Left}{Shift Up}"
		; Uses {End}{Home 2} instead of !{Home} to work on more apps.
	return GetSelection()
}

;========================================================================================================================
; Built-in
;========================================================================================================================

ControlGetFocus(win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	ControlGetFocus focused_class_nn, %win_title%, %win_text%, %excluded_title%, %excluded_text%
	return focused_class_nn
}

ControlGetHwnd(control, win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	return ControlGet control_hwnd, %win_title%, %win_text%, %excluded_title%, %excluded_text%
}

ControlGetText(control, win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	return ControlGet control_text, %win_title%, %win_text%, %excluded_title%, %excluded_text%
}

ControlGetVisible(control := "", win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	ControlGet visibility, Visible, , %control%, %win_title%, %win_text%, %excluded_title%, %excluded_text%
	return visibility
}

GroupActivate(group_name, mode)
{
	GroupActivate %group_name%, %mode%
}

Run(target, working_dir, options, ByRef pid_ref)
{
	Run %target%, %working_dir%, %options%, %pid_ref%
}

Send(keys)
{
	Send %keys%
}

WinGetClass(win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	WinGetClass win_class, %win_title%, %win_text%, %excluded_title%, %excluded_text%
	return win_class
}

WinGetMinMax(win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	WinGet win_min_max, MinMax, %win_title%, %win_text%, %excluded_title%, %excluded_text%
	return win_min_max
}

WinGetProcessName(win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	WinGet win_process_name, ProcessName, %win_title%, %win_text%, %excluded_title%, %excluded_text%
	return win_process_name
}

WinGetPID(win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	WinGet win_pid, PID, %win_title%, %win_text%, %excluded_title%, %excluded_text%
	return win_pid
}

WinGetText(win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	WinGetText win_text, %win_title%, %win_text%, %excluded_title%, %excluded_text%
	return win_text
}

WinGetTitle(win_title := "", win_text := "", excluded_title := "", excluded_text := "")
{
	WinGetTitle retrieved_win_title, %win_title%, %win_text%, %excluded_title%, %excluded_text%
	return retrieved_win_title
}

WinWait(win_title := "", win_text := "", timeout_s := "", excluded_title := "", excluded_text := "")
{
	WinWait %win_title%, %win_text%, %timeout_s%, %excluded_title%, %excluded_text%
	return not ErrorLevel
}

WinWaitActive(win_title := "", win_text := "", timeout_s := "", excluded_title := "", excluded_text := "")
{
	WinWaitActive %win_title%, %win_text%, %timeout_s%, %excluded_title%, %excluded_text%
	return not ErrorLevel
}

WinWaitNotActive(win_title := "", win_text := "", timeout_s := "", excluded_title := "", excluded_text := "")
{
	WinWaitNotActive %win_title%, %win_text%, %timeout_s%, %excluded_title%, %excluded_text%
	return not ErrorLevel
}

WinWaitClose(win_title := "", win_text := "", timeout_s := "", excluded_title := "", excluded_text := "")
{
	WinWaitClose %win_title%, %win_text%, %timeout_s%, %excluded_title%, %excluded_text%
	return not ErrorLevel
}
