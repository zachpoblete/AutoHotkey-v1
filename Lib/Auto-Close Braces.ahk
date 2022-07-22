; Inspired by herc:
; https://www.autohotkey.com/board/topic/44574-intelligent-auto-close-bracketbraceparen

#Include <Default Settings>
#Include <Globals>
#Include <Functions>
#Include <Classes>

OnClipboardChange("ClipboardChanged")

global _BraceNames := []
, _BraceLens := []

;========================================================================================================================
; Endkeys
;========================================================================================================================

Loop Parse, % "F1|F2|F3|F4|F6|F7|F8|Space|Tab|Enter|Del|Esc|LButton", |
{
	Hotkey ~%A_LoopField%, EndkeyTyped
}

Loop Parse, % "qwertyupasdfgzxcvbnm1234567890-=,./\"
{
	Hotkey ~%A_LoopField%, EndkeyTyped
}

Hotkey if, WinActive("ahk_class SciTEWindow")

Hotkey ~``, EndkeyTyped

Hotkey if, WinActive("ahk_exe Discord.exe")

Loop Parse, % "[]"
{
	Hotkey ~%A_LoopField%, EndkeyTyped
}

Hotkey if

;========================================================================================================================
; Special Endkeys
;========================================================================================================================

Hotkey if, WinActive("ahk_class SciTEWindow") && _BraceNames[1]

Loop Parse, % "Left|Right|Home|End", |
{
	Hotkey %A_LoopField%, SpecialEndkeyTyped
	Hotkey ^%A_LoopField%, SpecialEndkeyTyped
	Hotkey +%A_LoopField%, SpecialEndkeyTyped
	Hotkey ^+%A_LoopField%, SpecialEndkeyTyped
}

Loop Parse, % "Up|Down|PgUp|PgDn", |
{
	Hotkey %A_LoopField%, SpecialEndkeyTyped
	Hotkey +%A_LoopField%, SpecialEndkeyTyped
}

Hotkey +Tab, SpecialEndkeyTyped

SpecialEndkeyTyped()
{
	Send % "{Blind}{Ctrl Up}{Del}" . HotkeyEncloseInBraces(A_ThisHotkey)
	EndkeyTyped()
}

Hotkey if

#If WinActive("ahk_class SciTEWindow") && _BraceNames[1]
#If

;========================================================================================================================
; Endmodifiers
;========================================================================================================================

; Endmodifiers in Keyboard.ahk: ~Alt, LWin|RWin

~Shift::
	KeyWait Shift
	
	if % WinActive("ahk_class SciTEWindow")
	{
		if % not A_PriorKey ~= "\A(" . MODIFIERS . "|,|5|9|'|\[)\z"
		{
			EndKeyTyped()
		}
		return
	}
	if % WinActive("ahk_exe Discord.exe")
	{
		if % not A_PriorKey ~= "\A(" . MODIFIERS . "|8|-|\\|``)\z"
		{
			EndKeyTyped()
		}
		return
	}
	
	EndkeyTyped()
	return

~Ctrl::
	KeyWait Ctrl
	
	ModifierTyped()
	return

ModifierTyped()
{
	if % not A_PriorKey ~= "\A(" . MODIFIERS . ")\z"
	{
		EndkeyTyped()
	}
}

;========================================================================================================================
; Endhotkeys
;========================================================================================================================

; Endhotkeys in Mouse.ahk:
	; R | R&W
	; M | M&R
	; X1&W
	; X2&W | X2&R
; Endhotkeys in Keyboard.ahk: JOHI | +BS | ^+BS

#If WinActive("ahk_class SciTEWindow") && _BraceNames[1] && (_BraceNames[1] != """")

~Space::
	Send {Del}
	
	EndkeyTyped()
	return

#If (WinActive("ahk_class SciTEWindow") || WinActive("ahk_exe Discord.exe")) && _BraceNames[1]

BS:: BracesDeleteAndRemove()

^BS::
	while _BraceNames[1]
	{
		BracesDeleteAndRemove()
	}
	return

BracesDeleteAndRemove()
{
	global
	
	Send % "{BS " . _BraceLens[1] . "}{Del " . _BraceLens[1] . "}"
	BracesRemove()
}

#If

;========================================================================================================================
; SciTE
;========================================================================================================================

;------------------------------------------------------------------------------------------------------------------------
; Close Braces
;------------------------------------------------------------------------------------------------------------------------

; Some of the braces are uni-brace, meaning they use the same character for both the open and close braces, e.g. " and %.
; This means the same hotstring appears in every #If section (hotkey variants), so the more specific #If sections need to come first.
; Hence the Close Braces section coming before the Open Braces section.
; I recommend reading the Open Braces section first.

#If WinActive("ahk_class SciTEWindow") && _BraceNames[1] = HotstringGetAbbrev(A_ThisHotkey)

:*?x:)::
:*?x:]::
:*?x:>::
:*?x:}::
:*?x:`"::
:*?x:%::
	Send {Right}
	
	EndkeyTyped()
	return

#If ControlGetFocus("ahk_class SciTEWindow") = "Scintilla1"

:*?x:}::
	CloseCurlyBracket()
	{
		selection := GetSelection()
		line_count := GetLineCount(selection)
		
		if % selection = ""
		{
			Send {}}
			return
		}
		
		if % line_count = 1
		{
			CloseBiBraceWrap("{", selection)
			return
		}
		
		WrapBlock(line_count)
		
		; Go to last statement in block.
		Send {Up}{End}
	}

#If WinActive("ahk_class SciTEWindow")

:*?x:)::
	if % _BraceNames[1] = """"
	{
		Send {Del}{)}
		return
	}
	
	CloseBiBrace("(")
	return

:*?x:]:: CloseBiBrace("[")
:*?x:>:: CloseBiBrace("<")
:*?x:}:: CloseBiBrace("{")

CloseBiBrace(open_brace)
{
	selection := GetSelection()
	
	if % selection = ""
	{
		Send % "{" . HotstringGetAbbrev(A_ThisHotkey) . "}"
		return
	}
	
	CloseBiBraceWrap(open_brace, selection)
}

CloseBiBraceWrap(open_brace, selection)
{
	SendInstantRaw(open_brace . selection . HotstringGetAbbrev(A_ThisHotkey))
	Send {Left}
}

#If

;------------------------------------------------------------------------------------------------------------------------
; Open Braces
;------------------------------------------------------------------------------------------------------------------------

#If WinActive("ahk_class SciTEWindow") && _BraceNames[1] = """"

:*?x:(::
:*?x:[::
:*?x:<::
:*?x:{::
:*?x:%::
	Send % "{" HotstringGetAbbrev(A_ThisHotkey) "}"
	BracesRemove()
	return

#If ControlGetFocus("ahk_class SciTEWindow") = "Scintilla1"
:*?x:{::
	OpenCurlyBracket()
	{
		selection := GetSelection()
		line_count := GetLineCount(selection)
		
		if % selection != ""
		{
			if % line_count = 1
			{
				OpenBiBraceWrap("}", selection)
				return
			}
			
			WrapBlock(line_count)
			
			; Go to first statement in block.
			Send {Ctrl Down}e{Ctrl Up}{Down}{End}
			return
		}
		
		; Get any non-whitespace characters before the caret.
		Send +{Home}
		selection := GetSelection()
		
		if % selection != ""
		{
			; Get out of selection.
			Send {Right}
		}
		
		if % StrReplace(selection, A_Tab) != ""
		{
			BiBracesAutoClose("}")
			return
		}
		
		; Get indents of statement above prior selection.
		Send {Up}
		tabs := LineGetIndents()
		
		; Get any text in front of the prior caret.
		Send {Down}{End}+{Home}
		
		selection := RegExReplace(GetSelection(), "^\t+")
		
		; Select line.
		Send !{Home}+{End}
		
		SendInstantRaw(`"
		(
		" tabs "{
		" tabs . A_Tab . selection "
		" tabs "}
		)`")
		
		; Go to block.
		Send {Up}{End}
	}

:*?x:(::
	OpenParen()
	{
		selection := GetSelection()
		
		if % selection != ""
		{
			OpenBiBraceWrap(")", selection)
		}
		else
		{
			BiBracesAutoClose(")")
			
			; Show calltip if available.
			Send ^+{Space}
		}
	}

#If WinActive("ahk_class SciTEWindow")

:*?x:(:: OpenBiBrace(")")
:*?x:[:: OpenBiBrace("]")
:*?x:<:: OpenBiBrace(">")
:*?x:{:: OpenBiBrace("}")

OpenBiBrace(close_brace)
{
	selection := GetSelection()
	
	if % selection = ""
	{
		BiBracesAutoClose(close_brace)
		return
	}
	
	OpenBiBraceWrap(close_brace, selection)
}

OpenBiBraceWrap(close_brace, selection)
{
	SendInstantRaw(HotstringGetAbbrev(A_ThisHotkey) . selection . close_brace)
	
	; Select close brace with caret on the outside and attempt to go to matching open brace.
	Send {Left}+{Right}^e
	
	if % GetSelection() = ""
	{
		; Matching to open brace succeeded so go inside braces.
		Send {Right}
		return
	}
	
	; Matching to open brace failed so deselect close brace and go inside braces.
	Send {Left}
}

BiBracesAutoClose(close_brace)
{
	global
	
	Send % "{" HotstringGetAbbrev(A_ThisHotkey) "}{" close_brace "}{Left}"
	
	_BraceNames.InsertAt(1, close_brace)
	_BraceLens.InsertAt(1, 1)
}

:*?x:`"::
:*?x:%::
	OpenUniBrace(HotstringGetAbbrev(A_ThisHotkey))
	return

#If

;------------------------------------------------------------------------------------------------------------------------
; Templates
;------------------------------------------------------------------------------------------------------------------------

#If WinActive("Vimium C Options ahk_exe msedge.exe")

^!h::
	TemplateVimiumCHeader()
	{
		SendInstantRaw(`"
		(
		#=================================================================================
		#" . A_Space . "
		#=================================================================================
		)`")
		
		; Go to header middle.
		Send {Up}
	}

#If ControlGetFocus("ahk_class SciTEWindow") = "Scintilla1"

^+q:: BoxText("/*", "*/")

^!h::  TemplateAHKHeader("SECTION")
^!+h:: TemplateAHKHeader("CHAPTER")

TemplateAHKHeader(header_type)
{
	switch GetFileExt(SciTE_GetFileName(WinGetTitle("A")))
	{
		case ".ahk":        comment_flag := ";"
		case ".properties": comment_flag := "#"
		case ".lua":        comment_flag := "-- "
	}
	
	header_end := comment_flag . %header_type%_HEADER_END
	header_mid := comment_flag
	
	if % not InStr(comment_flag, A_Space)
	{
		header_mid .= A_Space
	}
	
	LineGetText()
	Sleep 1000
	SendInstantRaw(`"
	(
	" . header_end . "
	" . header_mid . "
	" . header_end . "
	)`")
	
	; Go to header middle.
	Send {Up}
}

^!+i::
	SendInstantRaw(`"
	(
	#If" . A_Space . "
	
	
	
	#If
	
	)`")
	Send {Up 5}{End}
	return

^!i::  TemplateStatement("if % ")
^!e::  TemplateStatement("else", true)
^!+e:: TemplateStatement("else if % ")
^!s::  TemplateStatement("switch ")

^!l::  TemplateStatement("Loop")
^!f::  TemplateStatement("for ")
^!w::  TemplateStatement("while ")

^!c::  TemplateStatement("class ")
^!+f:: TemplateStatement("()", true)
^!b::  TemplateStatement("[]")

TemplateStatement(statement, can_go_inside := false)
{
	tabs := LineGetIndents()
	
	Send {End}
	
	SendInstantRaw(`"
	(
	" . statement . "
	" . tabs . "{
	" . tabs . A_Tab . "
	" . tabs . "}
	)`")
	
	Send % "{Up " . (can_go_inside ? 1 : 3) . "}{End}"
}

^!+c::
	TemplateContinuationSection()
	{
		; Base number of indents to use off those in current line.
		Send +{Home 2}
		tabs := GetIndents(GetSelection())
		Send {Right}
		
		SendInstantRaw(`"
		(
		``""
		" . tabs . "(
		" . tabs . "
		" . tabs . "`)``""
		)`")
		
		; Go in between parentheses.
		Send {Up}{End}
	}

#If

;========================================================================================================================
; Discord
;========================================================================================================================

#If WinActive("ahk_exe Discord.exe")

:*?x:*::  OpenUniBrace("*")
:*?x:__:: OpenUniBrace("__")
:*?x:~~:: OpenUniBrace("~~")
:*?x:||:: OpenUniBrace("||")
:*?x:``:: OpenUniBrace("``")

!c:: BoxText("``````")

#If

;========================================================================================================================
; Functions
;========================================================================================================================

BracesRemove()
{
	_BraceNames.RemoveAt(1)
	_BraceLens.RemoveAt(1)
}

BoxText(open_brace, close_brace := "")
{
	if % not close_brace
	{
		close_brace := open_brace
	}
	
	SendInstantRaw(`"
	(
	" . open_brace . "
	" . LineGetText() . "
	" . close_brace . "
	)`")
	
	; Go to last statement in block.
	Send {Up}{End}
}

EndkeyTyped()
{
	global
	
	_BraceNames := []
	_BraceLens := []
}

OpenUniBrace(matching_brace)
{
	global
	
	_BraceLens.InsertAt(1, StrLen(matching_brace))
	local selection := GetSelection()
	
	if % selection = ""
	{
		Send % matching_brace . matching_brace . "{Left " . _BraceLens[1] . "}"
		_BraceNames.InsertAt(1, matching_brace)
		return
	}
	
	SendInstantRaw(matching_brace . selection . matching_brace)
	Send % "{Left " . _BraceLens[1] . "}"
	
	EndkeyTyped()
}

WrapBlock(line_count)
{
	block := LineGetText()
	
	; Get indents of statement above prior selection.
	Send {Left}{Up}
	tabs := LineGetIndents()
	
	; Select prior text again.
	Send {Down}{Shift Down}{Down %line_count%}{Left}
	Sleep 200
	Send {Shift Up}
	
	block := RegExReplace(block, "m)^" GetIndents(block), tabs . A_Tab)
	
	SendInstantRaw(`"
	(
	" . tabs . "{
	" . block . "
	" . tabs . "}
	)`")
}
