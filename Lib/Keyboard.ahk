#Include <Default Settings>
#Include <Globals>
#Include <Functions>
#Include <Classes>
#Include <Auto-Close Braces>
#Include <Script Hotkeys>

;========================================================================================================================
; In-App
;========================================================================================================================

#If WinActive("ahk_class CabinetWClass")

^8::
	; Display all subfolders under selected folder.
	Send {NumpadMult}
	return

^=::
	; Display contents of selected folder.
	Send {NumpadAdd}
	return

^-::
	; Collapse selected folder.
	Send {NumpadSub}
	return

#If WinActive("ahk_exe msedge.exe")

^e::
	; Toggle vertical tabs.
	Send ^+`,
	return

#If WinActive("ahk_exe Notion.exe")

^+f::
	; Apply last text or highlight color used.
	Send ^+h
	return

#If WinActive("ahk_exe Spotify.exe")

; I switched the keyboard shortcuts for varying the navigation bar and friend activity widths
; because when you increase the navigation bar width, the cover art grows taller
; hence assigning Down and Up to it
; and when you increase the friend activity width, the bar grows fatter
; hence assigning Left and Right to it

!+Down::
	; Decrease navigation bar width.
	Send !+{Left}
	return

!+Up::
	; Increase navigation bar width.
	Send !+{Right}
	return

!+Left::
	; Increase friend activity width.
	Send !+{Down}
	return

!+Right::
	; Decrease friend activity width.
	Send !+{Up}
	return

; Spicetify

/*

keyboardShortcut-Quarter.js:
	!+l:: Toggle Lyrics
	!+q:: Toggle Queue
	!+m:: Open Spicetify Marketplace

*/

; !+2 goes to Your Podcasts, but because of the Hide Podcasts extension,
; Your Podcasts isn't listed in Your Library, so !+2 should redirect to Your Artists instead.
; The same logic applies to !+3 and !+4.

!+2::
	; Go to your artists.
	Send !+3
	return

!+3::
	; Go to your albums.
	Send !+4
	return

!+4::return

#If

;------------------------------------------------------------------------------------------------------------------------
; SciTE
;------------------------------------------------------------------------------------------------------------------------

#If WinActive("ahk_exe InternalAHK.exe")

Esc:: Send !{F4}

#If ControlGetFocus("ahk_class SciTEWindow") = "Scintilla1" && ClipboardChanged() = "Line"

^v::
	LinePaste()
	{
		text := GetSelection()
		
		if % text != ""
		{
			Send % "{Left}!{Home}+{Down " . GetLineCount(text) . "}"
			tabs := GetIndents(GetSelection())
		}
		else
		{
			this_line_tabs := LineGetIndents()
			
			Send {Up}{End}^+{Left}
			above_line_last_word := GetSelection()
			
			Send {Right}
			above_line_tabs := LineGetIndents()
			
			tabs := above_line_last_word = "{" ? above_line_tabs . A_Tab
				: above_line_last_word = "return" ? this_line_tabs
				: above_line_tabs > this_line_tabs ? above_line_tabs
				: this_line_tabs
			
			Send {Down}!{Home}
		}
		
		LinePasteMatchIndents(tabs)
	}

#If ControlGetFocus("ahk_class SciTEWindow") = "Scintilla1"

^+v::
	CutAndReplace()
	{
		if % ClipboardChanged() != "Line"
		{
			selection := GetSelection()
			
			if % selection = ""
			{
				; Copy the current line without the indents.
				Send {End}+{Home}
				selection := GetSelection()
			}
			
			Send ^v
			Sleep 30
			Clipboard := selection
			return
		}
		
		OnClipboardChange("ClipboardChanged", 0)
		
		LineGetText()
		Send +{Right}
		
		selection := GetSelection()
		Send ^v
		Sleep 30
		
		Clipboard := selection
		Sleep 30
		ClipboardChanged("Line")
		
		OnClipboardChange("ClipboardChanged", 1)
	}

LinePasteMatchIndents(tabs)
{
	text := RegExReplace(Clipboard, "m)^" GetIndents(Clipboard), tabs)
	SendInstantRaw(text)
	Send {End}
}

^c::
^x::
	LineCopyLTrim()
	return

LineCopyLTrim()
{
	if % GetSelection() != ""
	{
		Send %A_ThisLabel%
		return
	}
	
	; Copy the current line without the indents.
	Send {End}+{Home}%A_ThisLabel%{End}
}

^+c::
	; Copy line(s).
	LineCopy("^+t")
	return

^+x::
	; Cut line(s).
	LineCopy("^l{End}")
	return

LineCopy(keys)
{
	OnClipboardChange("ClipboardChanged", 0)

	Send %keys%
	Sleep 30
	
	ClipboardChanged("Line")
	OnClipboardChange("ClipboardChanged", 1)
}

^l::
	; Duplicate line.
	Send ^d
	return

^d::
	LineDelLTrim()
	{
		selection := GetSelection()
		
		if % selection = ""
		{
			; Delete everything in the current line except the indents.
			Send {Ctrl Up}{End}+{Home}{Del}
			return
		}
		
		lf_count := GetLineCount(selection) - 1
		
		; Delete everything in the selected lines except the indents of the first line.
		Send {Left}!{Home}{Home}{Shift Down}{Down %lf_count%}{End}{Shift Up}{Del}
	}

^+d::
	LineDel()
	{
		clip_saved := ClipboardAll
		
		; Cut line.
		Send ^l{End}
		
		Clipboard := ""
		Sleep 30
		Clipboard := clip_saved
		Sleep 30
	}

^`:: Run % GetSelectionOrExit()

; Move previous line into current line and vice versa.
~^t::
	; Move to original line.
	Send {Up}
	return

^+t::
	; Move line down.
	Send {Down}^t{Up}{Down}
	return

!Up::
	; Scroll up 2 lines.
	SendMessage 0x00B6, , -2, Scintilla1, A ; EM_LINESCROLL
	
	Send {Up 2}
	return

!Down::
	; Scroll down 2 lines.
	SendMessage 0x00B6, , 2, Scintilla1, A ; EM_LINESCROLL
	
	Send {Down 2}
	return

^7::
	; Restore text size to normal.
	Send ^{NumpadDiv}
	return

^8::
	; Expand or contract a fold point.
	Send ^{NumpadMult}
	return

^-::
	; Reduce text size.
	Send ^{NumpadSub}
	return

^=::
	; Magnify text size.
	Send ^{NumpadAdd}
	return

^Enter::
	Send {Enter}{Up}{End}
	return

:*?b0x::`n::
	Send {Tab}
	return

; Check if the find or the replace control is focused.
#If ControlGetFocus("ahk_class SciTEWindow") ~= "\A(Edit2|Edit3)\z"

!n::
	ControlFocus Scintilla1, A
	return

; Check if the find or the replace control is visible.
#If ControlGetVisible("Edit2", "ahk_class SciTEWindow") || ControlGetVisible("Edit3", "ahk_class SciTEWindow")

!r::
	; Toggle wrap around.
	Send !o
	return

; Check if the find control is visible.
#If ControlGetVisible("Edit2", "ahk_class SciTEWindow")

!p::
	; Toggle between searching the next or previous result.
	ControlClick &Up, A
	return

; Check if the find control isn't visible.
#If WinActive("ahk_class SciTEWindow") && not ControlGetVisible("Edit2", "ahk_class SciTEWindow")

!u::
	; Unmark all bookmarks.
	Send ^f!u{Esc}
	return

#If WinActive("ahk_class SciTEWindow")
	
F5::
	SciTE_RunScript()
	{
		if % _WinExist.matchHidden2(SciTE_GetFileName(WinGetTitle("A")) . " - AutoHotkey ahk_exe AutoHotkey.exe")
		{
			SendMessage % WIN32_CONSTS["WM_COMMAND"], % CONTROL_CODES["TRAY", "RELOAD"]
			return
		}
		
		Send {F5}
	}

#If

;------------------------------------------------------------------------------------------------------------------------
; Zoom
;------------------------------------------------------------------------------------------------------------------------

#If WinActive(CLASSES["ZOOM", "MEETING"])

~#Down::
	if % WinWaitActive(CLASSES["ZOOM", "TOOLBAR"], , 0.1)
	{
		; Activate minimized video/control.
		WinActivate % "Zoom ahk_pid " . WinGetPID()
	}
	return

#If WinActive(CLASSES["ZOOM", "WAIT_HOST"]) || WinActive(CLASSES["ZOOM", "VID_PREVIEW"])

#Down::
	WinMinimize
	return

#If WinActive(CLASSES["ZOOM", "MIN_VID"]) || WinActive(CLASSES["ZOOM", "MIN_CONTROL"])

#Up::
	Zoom_ExitMinimizedVideo()
	{
		WinGetPos, , , , win_h
		
		; Exit minimized video.
		ControlClick % "x200 y" . win_h - 30
	}

#If	WinActive(CLASSES["ZOOM", "HOME"])
	; Check if a visible meeting window exists.
	&& not WinExist("Zoom ahk_pid " . WinGetPID(CLASSES["ZOOM", "TOOLBAR"]))

!F4::
	Process Close, Zoom.exe ; Can't use WinClose because that minimizes here.
	return

; Check if a meeting window is active.
#If WinActive("ahk_pid " . WinGetPID(CLASSES["ZOOM", "TOOLBAR"]))

!e::
	Zoom_OpenReactions()
	{
		if % WinExist(CLASSES["ZOOM", "REACTION"])
		{
			WinActivate
			return
		}
		if % not WinExist(CLASSES["ZOOM", "MEETING"])
		{
			return
		}
		
		WinActivate
		WinGetPos, , , win_w, win_h
		
		; Search meeting controls region.
		ImageSearch image_x, image_y, 0, win_h - 60, win_w, win_h, *60 reactions.png
		
		if % ErrorLevel != 1
		{
			ControlClick x%image_x% y%image_y%, % CLASSES["ZOOM", "MEETING"]
			return
		}
		
		ImageSearch image_x, image_y, 0, win_h - 60, win_w, win_h, *60 more.png
		ControlClick x%image_x% y%image_y%, % CLASSES["ZOOM", "MEETING"]
		Sleep 150
		
		; Open Reactions.
		
		ImageSearch, , , 0, win_h - 60, win_w, win_h, *60 apps.png
		
		if % ErrorLevel = 1
		{
			Send {Up}
		}
		
		Send {Up}
		Sleep %SHORTEST_NORM_DELAY%
		Send {Space}
	}

!=::
	Zoom_GiveThumbsUp()
	{
		Zoom_OpenReactions()
		Sleep 30
		
		WinGetPos, , , win_w, win_h, % CLASSES["ZOOM", "REACTION"]
		ImageSearch image_x, image_y, 0, 0, win_w, win_h, *60 thumbs up.png
		ControlClick x%image_x% y%image_y%, % CLASSES["ZOOM", "REACTION"]
	}

#If

;========================================================================================================================
; Activate
;========================================================================================================================

;------------------------------------------------------------------------------------------------------------------------
; ActivateOrRun
;------------------------------------------------------------------------------------------------------------------------

#!c:: ActivateOrRun("C:\Users\Zach Poblete\Pictures\Camera Roll")
#+g:: ActivateOrRun("GitHubDesktop.exe", "C:\Users\Zach Poblete\AppData\Local\GitHubDesktop")
#!l:: ActivateOrRun("RAKK Lam-Ang Pro Mechanical Keyboard.exe", "C:\Program Files\RAKK\Lamg-Ang(Pro)")
#!p:: ActivateOrRun("PowerToys", "C:\Program Files\PowerToys", "ahk_exe PowerToys.Settings.exe")
#!q:: ActivateOrRun("qbittorrent.exe", "C:\Program Files\qBittorrent")
#!s:: ActivateOrRun("Spotify.exe", "C:\Users\Zach Poblete\AppData\Roaming\Spotify")

#!v:: Run App volume and device preferences, C:\Windows

;------------------------------------------------------------------------------------------------------------------------
; Groups
;------------------------------------------------------------------------------------------------------------------------

#!a::
	Adobe_Activate()
	{
		input := InputHook()
		input.KeyOpt("{All}", "E")
		input.Start()
		input.Wait()
		
		if % input.EndKey = "r"
		{
			CheckGroupExistsAndActivateRel("AdobeReaderWins")
			return
		}
	}

#+i::  CheckGroupExistsAndActivateRel("InternalAHKWins")
#+p::  _CheckGroupExistsAndActivateRel.matchRegEx("PhotoWins")

#+e:: ActivateOrRun("explorer.exe", , "ahk_group ExplorerWins")

#+w::
	MSWord_ActivateOrRun()
	{
		if % not WinExist("ahk_group WordWins")
		{
			Run WINWORD.EXE
		}
		
		GroupActivate WordWins, R
			; This line isn't under an else statement because MS Word sometimes doesn't activate when ran.
	}

#+z::
	Zoom_ActivateOrRun()
	{
		if % not WinExist("ahk_exe Zoom.exe")
		{
			Run Zoom.exe, C:\Users\Zach Poblete\AppData\Roaming\Zoom\bin
			return
		}
		
		; Check if a visible Zoom meeting window exists.
		if % WinExist(CLASSES["ZOOM", "HIDDEN_TOOLBAR"]) || WinExist("Zoom ahk_pid " . WinGetPID(CLASSES["ZOOM", "TOOLBAR"]))
		{
			WinActivate
			return
		}
		
		; Activate visible Zoom windows.
		_GroupActivate.matchRegEx("ZoomWins", "R")
	}

;========================================================================================================================
; Multimedia
;========================================================================================================================

#If GetKeyState("CapsLock", "T")
$Volume_Up::   SetVolume(1)
$Volume_Down:: SetVolume(-1)

SetVolume(variation)
{
	SoundGet volume
	
	; Vary volume by 2, and, importantly, display volume slider (and media overlay).
	Send % HotkeyEncloseInBraces(A_ThisLabel)
	
	; Override that normal variation of 2.
	SoundSet volume + variation
}

#If

#PgUp:: _BrightnessSetter.setBrightness(2)
#PgDn:: _BrightnessSetter.setBrightness(-2)

Pause:: Media_Play_Pause
F9::    Media_Prev
F10::   Media_Next

PrintScreen::
	Send #!{PrintScreen}
	return

#+a::
	ToggleMute()
	{
		if % not GetKeyState("CapsLock", "T")
		{
			; Toggle mute in Zoom.
			Send {F13} ; I've set it to F13 because Zoom doesn't accept the Win key in its keyboard shortcuts.
			return
		}
		
		WinActivate ahk_exe Discord.exe
		
		; Toggle mute.
		Send ^+m
	}

;========================================================================================================================
; Remap
;========================================================================================================================

/*

(In order of decreasing input level)

RAKK Lam-Ang Pro FineTuner:
	Fn::       CapsLock
	Capslock:: BS
	BS::       `
	`::        NumLock
	
	Ins::      Home
	Home::     PgUp
	PgUp::     Ins

KeyTweak:
	AppsKey::  RWin

PowerToys:
	ScrollLock:: AppsKey

AHK:

*/

;------------------------------------------------------------------------------------------------------------------------
; JOHI
;------------------------------------------------------------------------------------------------------------------------

~^NumLock::return

~*NumLock::
	FadeJOHIIndicator()
	{
		Gui JOHI:+LastFound
		
		if % GetKeyState("NumLock", "T")
		{
			WinSet TransColor, Gray 255
			return
		}
		
		Gui_Fade(false, 750, "Gray")
	}

;========================================================================================================================
; Special Chars.
;========================================================================================================================
; For each Unicode character sent, the hostring abbreviation is the HTML entity (or something intuitive).

#InputLevel 1

+Space:: Send _

#InputLevel

:?cx:&tab;::        SendInstantRaw("	")

:?cx:&deg;::        Send {U+00B0}

:?cx:&leftarrow;::  Send {U+2190}
:?cx:&rightarrow;:: Send {U+2192}

:?cx:&ndash;::      Send {U+2013}
:?cx:&mdash;::      Send {U+2014}

:?cx:&Ntilde;::     Send {U+00D1}
:?cx:&ntilde;::     Send {U+00F1}

:?cx:&peso;::       Send {U+20B1}

;------------------------------------------------------------------------------------------------------------------------
; Math
;------------------------------------------------------------------------------------------------------------------------

:?cx:&xbar;::   Send {U+0078}{U+0305}

:?cx:&times;::  Send {U+00D7}

:?cx:&ne;::     Send {U+2260}
:?cx:&pm;::     Send {U+00B1}
:?cx:&le;::     Send {U+2264}
:?cx:&ge;::     Send {U+2265}

:?cx:&bullet;:: Send {U+2219}

:?cx:&radic3;:: Send {U+221B}
:?cx:&radic4;:: Send {U+221C}

:?cx:&infin;::  Send {U+221E}

#InputLevel 1

+-::
	if % WinActive("Desmos ahk_exe msedge.exe") || WinActive("ahk_exe EXCEL.EXE")
	{
		Send sqrt
		return
	}
	
	; Send square root symbol.
	Send {U+221A}
	return

#InputLevel

;------------------------------------------------------------------------------------------------------------------------
; Chemistry
;------------------------------------------------------------------------------------------------------------------------

:?cx:&scriptM;:: Send {U+2133}

;------------------------------------------------------------------------------------------------------------------------
; Greek Alphabet
;------------------------------------------------------------------------------------------------------------------------

:?cx:&Alpha;::    Send {U+0391}
:?cx:&alpha;::    Send {U+03B1}
:?cx:&Beta;::     Send {U+0392}
:?cx:&beta;::     Send {U+03B2}
:?cx:&Gamma;::    Send {U+0393}
:?cx:&gamma;::    Send {U+03B3}
:?cx:&Delta;::    Send {U+0394}
:?cx:&delta;::    Send {U+03B4}
:?cx:&Epsilon;::  Send {U+0395}
:?cx:&epsilon;::  Send {U+03B5}
:?cx:&Zeta;::     Send {U+0396}
:?cx:&zeta;::     Send {U+03B6}
:?cx:&Eta;::      Send {U+0397}
:?cx:&eta;::      Send {U+03B7}
:?cx:&Theta;::    Send {U+0398}
:?cx:&theta;::    Send {U+03B8}
:?cx:&Iota;::     Send {U+0399}
:?cx:&iota;::     Send {U+03B9}
:?cx:&Kappa;::    Send {U+039A}
:?cx:&kappa;::    Send {U+03BA}
:?cx:&Lambda;::   Send {U+039B}
:?cx:&lambda;::   Send {U+03BB}
:?cx:&Mu;::       Send {U+039C}
:?cx:&mu;::       Send {U+03BC}
:?cx:&Nu;::       Send {U+039D}
:?cx:&nu;::       Send {U+03BD}
:?cx:&Xi;::       Send {U+039E}
:?cx:&xi;::       Send {U+03BE}
:?cx:&Omicron;::  Send {U+039F}
:?cx:&omicron;::  Send {U+03BF}
:?cx:&Pi;::       Send {U+03A0}
:?cx:&pi;::       Send {U+03C0}
:?cx:&Rho;::      Send {U+03A1}
:?cx:&rho;::      Send {U+03C1}
:?cx:&Sigma;::    Send {U+03A3}
:?cx:&sigma;::    Send {U+03C3}
:?cx:&varsigma;:: Send {U+03C2}
:?cx:&Tau;::      Send {U+03A4}
:?cx:&tau;::      Send {U+03C4}
:?cx:&Upsilon;::  Send {U+03A5}
:?cx:&upsilon;::  Send {U+03C5}
:?cx:&Phi;::      Send {U+03A6}
:?cx:&phi;::      Send {U+03C6}
:?cx:&Chi;::      Send {U+03A7}
:?cx:&chi;::      Send {U+03C7}
:?cx:&Psi;::      Send {U+03A8}
:?cx:&psi;::      Send {U+03C8}
:?cx:&Omega;::    Send {U+03A9}
:?cx:&omega;::    Send {U+03C9}

;========================================================================================================================
; BackSpace
;========================================================================================================================

#If RegExMatch(ControlGetFocus("A"), "^Edit\d+$") && ControlGetFocus("ahk_class Notepad") != "Edit1"

^BS::
	; This hotkey doesn't natively work, so workaround that.
	
	if % GetSelection() = ""
	{
		; Delete last word typed.
		Send ^+{Left}{Del}
		return
	}
	
	Send {Del}
	return

#If

+BS::
	Send {Del}
	EndkeyTyped()
	return

^+BS::
	Send ^{Del}
	EndkeyTyped()
	return

;========================================================================================================================
; Misc.
;========================================================================================================================

~*Alt::
	; Check if an Office app isn't active.
	if % not _WinActive.matchRegEx("ahk_exe .EXE$")
	{
		Send % "{Blind}" . KEYS["MENU_MASK"]
	}
	
	KeyWait Alt
	ModifierTyped()
	return

LWin::
RWin::
	Send {%A_ThisLabel% Down}
	KeyWait %A_ThisLabel%
	
	if % A_PriorKey = A_ThisLabel && A_TimeSinceThisHotkey > 500
	{
		Send % "{Blind}" . KEYS["MENU_MASK"]
	}
	else
	{
		EndkeyTyped()
	}
	
	Send {%A_ThisLabel% Up}
	return
