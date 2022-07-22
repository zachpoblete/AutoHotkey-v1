; TOC stands for Table of Contents

#Include <Default Settings>
#Include <Globals>
#Include <Functions>

class _Lib
{
	__New(instance, lib_folder, lib_title)
	{
		this.instance := instance
		this.folder := lib_folder
		this.title := lib_title
		
		this.File := new this.File
		this.File.lib := instance
		this.lib_title := lib_title
	}
	
	activateOrShow()
	{
		if % WinExist(this.title . " ahk_class AutoHotkeyGUI")
		{
			WinActivate
			return
		}
		
		this.create()
		Gui Show
	}
	
	create()
	{
		Gui % this.instance ":New", , % this.title
		this_class := this.__Class
		Gui +AlwaysOnTop +Label%this_class%.on
		Gui Font, s12, Verdana
		
		Gui Add, TreeView, AltSubmit w310 r26 hwndtree_view
		Gui Add, Button, Default w0 h0 hwndbutton, % this.__Class . "`r`n" . this.instance
		on_notif := ObjBindMethod(this, "onNotif")
		GuiControl +g, %tree_view%, %on_notif%
		GuiControl +g, %button%, %on_notif%
		
		this.file_tv_ids := {}
		
		Loop Files, % this.folder "\*.ahk", R
		{
			this.file_tv_ids[A_LoopFileName] := TV_Add(A_LoopFileName, , "+Expand Sort")
		}
	}
	
	toggleItem(toggle)
	{
		RegExMatch(WinGetText("A"), "mO)\A" . this.__Class . "`r`n(?P<this_instance>.+)`r`n\z", match)
		Gui % match.Value["this_instance"] . ":Default"
		
		TV_Modify(TV_GetSelection(), (toggle ? "+" : "-") "Expand")
	}
	
	showORCreateFileTOC(file_name := "")
	{
		if % GetKeyState("CapsLock", "T")
		{
			this.activateOrShow()
			return
		}
		if % WinActive("ahk_class SciTEWindow")
		{
			this.File.createTOC(SciTE_GetFileName("A"))
			return
		}
		if % file_name
		{
			this.File.createTOC(file_name)
			return
		}
		
		this.activateOrShow()
	}
	
	onEscape()
	{
		Gui Destroy
	}
	
	onNotif()
	{
		item_tv_id := TV_GetSelection()
		
		if % not (StrDel(A_GuiControl, this.__Class . "`r`n") = this.instance || (A_GuiEvent = "DoubleClick" && A_EventInfo = item_tv_id))
		{
			return
		}
		
		TV_GetText(item_text, item_tv_id)
		parent_item_tv_id := TV_GetParent(item_tv_id)
		
		if % parent_item_tv_id
		{
			if % item_text = "Top"
			{
				this.File.gotoTop()
				return
			}
			
			this.File.gotoHeader(parent_item_tv_id, item_text)
			return
		}
		if % TV_GetChild(item_tv_id)
		{
			this.File.gotoTop()
			return
		}
		
		this.File.createTOC(item_text)
	}
	
	class File
	{
		createTOC(file_name)
		{
			this.name := file_name
			this_lib := this.lib
			
			Loop Files, % %this_lib%.folder . "\*.ahk", R
			{
				if % A_LoopFileName != file_name
				{
					continue
				}
				
				if % not WinExist(%this_lib%.title . " ahk_class AutoHotkeyGUI")
				{
					%this_lib%.create()
				}
				
				file_tv_id := %this_lib%.file_tv_ids[file_name]
				TV_Modify(file_tv_id, "Select")
				
				this.full_path := A_LoopFileFullPath
				FileRead file_text, %A_LoopFileFullPath%
				this.text := file_text
				
				header_title_line_num := 0
				header_title := ""
				chapter_tv_id := ""
				
				Loop Parse, file_text, `n, `r
				{
					if % A_Index = header_title_line_num + 1
					{
						switch A_LoopField
						{
							case ";" CHAPTER_HEADER_END:
								chapter_tv_id := TV_Add(header_title, file_tv_id, "+Expand")
								continue
							case ";" SECTION_HEADER_END:
								TV_Add(header_title, chapter_tv_id)
								continue
						}
					}
					
					if % SubStr(A_LoopField, 1, 1) != ";"
					{
						continue
					}
					
					header_title := Trim(StrDel(A_LoopField, ";"))
					header_title_line_num := A_Index
				}
				
				if % not chapter_tv_id
				{
					this.gotoTop()
					return
				}
				
				Gui Show
				return
			}
			
			MsgBox % "Error: " . file_name . " not found at """ . %this_lib%.folder . """."
		}
		
		gotoTop()
		{
			this.open()
			
			Gui Destroy
			
			Send {Esc}
			
			; Safely release Winkeys if a hotkey called this method because the Start Menu would be shown otherwise.
			Send % "{Blind}" . KEYS["MENU_MASK"] . "{LWin Up}{RWin Up}^{Home}"
		}
		
		gotoHeader(parent_item_tv_id, header_title)
		{
			this.open()
			
			TV_GetText(parent_item_text, parent_item_tv_id)
			
			header_end := (parent_item_text = this.name)
				? CHAPTER_HEADER_END
				: SECTION_HEADER_END
			
			header := `"
			(
			
			;" . header_end . "
			; " . header_title . "
			;" . header_end . "
			
			)`"
			
			if % InStr(this.text, "`r")
			{
				header := StrReplace(header, "`n", "`r`n")
			}
			
			header_pos := InStr(this.text, header)
			
			Gui Destroy
			
			; Go to the header.
			SendMessage % WIN32_CONSTS["EM_SETSEL"], %header_pos%, %header_pos%, Scintilla1, A
			
			; Scroll the caret into view at the top.
			SendMessage % WIN32_CONSTS["EM_LINESCROLL"], , 40, Scintilla1, A
			
			; Exit out of any control that isn't Scintilla1, and go to the first line of the chapter/section.
			Send {Esc}{Down 5}{Home}
		}
		
		open()
		{
			Run % "edit " . this.full_path
			WinWaitActive % this.name . " ahk_class SciTEWindow"
		}
	}
}
