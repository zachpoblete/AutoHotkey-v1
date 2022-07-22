#Include <Default Settings>
#Include <Functions>

_TitleMatchFunc.__New("CheckGroupExistsAndActivateRel")
_TitleMatchFunc.__New("GroupActivate")
_TitleMatchFunc.__New("WinActive")
_TitleMatchFunc.__New("WinExist")
_TitleMatchFunc.__New("MouseControlFocus")
_TitleMatchFunc.__New("MouseWinActivate")

class _File
{
	open(file_name, flags, encoding := "")
	{
		this.file_name := file_name
		this.flags := flags
		this.encoding := encoding
		return this, this.base := FileOpen(file_name, flags, encoding)
	}
	
	onSave(func, should_shift := true)
	{
		funcIfSave := ObjBindMethod(this, "FuncIfSave", func)
		period := should_shift ? 1000 : "Off"
		
		SetTimer %funcIfSave%, %period%
	}
	
	funcIfSave(func)
	{
		FileGetAttrib attribs, % this.file_name
		
		if % not InStr(attribs, "A")
		{
			return
		}
		
		FileSetAttrib -A, % this.file_name
		%func%()
	}
}

class _KeyWait extends _KeyWait
{
	static list := {}
	
	__Get(key, options)
	{
		return this.list[key, options]
	}
	
	__Set(key, options, is_waiting)
	{
		this.list[key, options] := is_waiting
		
		if % not is_waiting
		{
			return
		}
		
		KeyWait %key%, %options%
		this.list[key, options] := false
		return
	}
}

class _Hotkey
{
	ctrlTab(hotkey, should_shift)
	{
		Hotkey if, GetKeyState("Ctrl")
		
		send_tab := Func("Send").Bind("{Tab}")
		Hotkey %hotkey%, %send_tab%
		
		Hotkey if
		
		send_ctrl_tab := Func("SendOnPrefixKeyDownAndUp").Bind("{Ctrl Down}" . (should_shift ? "+" : "") . "{Tab}", "{Ctrl Up}")
		Hotkey %hotkey%, %send_ctrl_tab%
		
		#If GetKeyState("Ctrl")
		#If
	}
	
	class MSEdge
	{
		searchSelectionAsURL(hotkey, engine := "", hotif_ex := "")
		{
			search_selection_as_url_in_new_tab  := ObjBindMethod(this, "SearchSelectionAsURLInNewTab", engine)
			search_selection_as_url_in_this_tab := ObjBindMethod(this, "SearchSelectionAsURLInThisTab", engine)
			
			Hotkey if, WinActive("ahk_exe msedge.exe") && %hotif_ex%
			
			Hotkey %hotkey%, %search_selection_as_url_in_new_tab%
			Hotkey +%hotkey%, %search_selection_as_url_in_this_tab%
			
			Hotkey if
		}
		
		searchSelectionAsURLInNewTab(engine := "")
		{
			Run % engine ? QueryToURL(GetSelectionOrExit(), engine) : GetSelectionOrExit()
		}
		
		searchSelectionAsURLInThisTab(engine := "")
		{
			query := GetSelectionOrExit()
			
			Send ^l
			SendInstantRaw(engine ? QueryToURL(query, engine) : query)
			Send {Enter}
		}
	}
	
	class Remap
	{
		static list := []
		
		create(origin_key, destination_key, hotif_ex := "")
		{
			this[origin_key] := true
			this.list.InsertAt(1, origin_key)
			
			this_on_press   := ObjBindMethod(this, "onPress", destination_key)
			this_on_release := ObjBindMethod(this, "onRelease", destination_key)
			
			Hotkey if, not _Hotkey.Remap[HotkeyDelModifierSymbols(A_ThisHotkey)] || not %hotif_ex%
			
			Hotkey ~%origin_key%, EndkeyTyped
	
			Hotkey if, _Hotkey.Remap[HotkeyDelModifierSymbols(A_ThisHotkey)] && %hotif_ex%
			
			Hotkey *%origin_key%, %this_on_press%
			Hotkey *%origin_key% Up, %this_on_release%
			
			Hotkey if
		}
		
		onPress(destination_key)
		{
			SendLevel 1
			Send {Blind}{%destination_key% DownR}
		}
		
		onRelease(destination_key)
		{
			SendLevel 1
			Send {Blind}{%destination_key% Up}
		}
	}
}

class _Timer
{
	static timer_labels := []
	
	__Get(timer_index := 1)
	{
		return this.timer_labels[timer_index]
	}
	
	__Set(label, period := "", priority := "", timer_index := 1)
	{
		SetTimer %label%, %period%, %priority%
		
		if % period ~= "\A(Off|Delete)\z"
		{
			this.timer_labels.RemoveAt(timer_index)
			return
		}
		if % period < 0
		{
			Sleep %period%
			this.timer_labels.RemoveAt(timer_index)
			return
		}
		
		this.timer_labels.InsertAt(timer_index, label)
	}
}

class _TitleMatchFunc
{
	__New(associated_func)
	{
		global
		
		if % not IsFunc(associated_func)
		{
			MsgBox Error: %associated_func% does not exist in the script.
			return
		}
		
		local this_class := this.__Class
		
		_%associated_func% := {}
		_%associated_func%.base := %this_class%
		_%associated_func%.associated_func := associated_func
	}
	
	__Call(match_mode, params*)
	{
		if % RegExMatch(match_mode, "i)(1|2|3|RegEx)", mode)
		{
			SetTitleMatchMode %mode%
		}
		if % RegExMatch(match_mode, "i)(Fast|Slow)", speed)
		{
			SetTitleMatchMode %speed%
		}
		
		if % InStr(match_mode, "Hidden")
		{
			DetectHiddenWindows On
		}
		else if % InStr(match_mode, "Visible")
		{
			DetectHiddenWindows Off
		}
		
		return this.associated_func(params*)
	}
}
