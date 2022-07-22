;========================================================================================================================
; Non-Script
;========================================================================================================================

global CLASSES := {DIALOG_BOX: "ahk_class #32770"}

, CHARS := {LEFT_TO_RIGHT_MARK: Chr(0x200E)}

, CONTROL_CODES := {}

, GUI_OPTIONS := {LBS_NOINTEGRALHEIGHT: 0x100, DEFAULT_BACKGROUND: -E0x200}

, KEYS := {MENU_MASK: "{vkE8}"} ; An unassigned key used to mask the menu

, SHORTEST_NORM_DELAY := 15.6

, WIN32_CONSTS := {EM_SETSEL: 0x00B1, EM_LINESCROLL: 0x00B6, WM_COMMAND: 0x0111}

;------------------------------------------------------------------------------------------------------------------------
; Subarrays
;------------------------------------------------------------------------------------------------------------------------

CLASSES["ZOOM"] := {HOME:        "ZPPTMainFrmWndClassEx",   HIDDEN_TOOLBAR: "ZPFloatToolbarClass",  MEETING:   "ZPContentViewWndClass"
				  , MIN_CONTROL: "ZPActiveSpeakerWndClass", MIN_VID:        "ZPFloatVideoWndClass", TOOLBAR:   "ZPToolBarParentWndClass"
				  , REACTION:    "ZPReactionWndClass",      VID_PREVIEW:    "VideoPreviewWndClass", WAIT_HOST: "zWaitHostWndClass"}

; Standard AHK tray menu control codes for the WM_COMMAND
CONTROL_CODES["TRAY"] := {OPEN: 65300, HELP:    65301, SPY:   65302, RELOAD: 65303
		                , EDIT: 65304, SUSPEND: 65305, PAUSE: 65306, EXIT:   65307}

;========================================================================================================================
; Script
;========================================================================================================================

global MODIFIERS := "[LR](Shift|Control|Alt|Win)"

, CHAPTER_HEADER_END := "========================================================================================================================"
, SECTION_HEADER_END := "------------------------------------------------------------------------------------------------------------------------"

;------------------------------------------------------------------------------------------------------------------------
; Subarrays
;------------------------------------------------------------------------------------------------------------------------

;========================================================================================================================
; Auto-Execute
;========================================================================================================================

AutoExecuteGlobals()

AutoExecuteGlobals()
{
	for abbrev, full_form in CLASSES["ZOOM"]
	{
		CLASSES["ZOOM", abbrev] := "ahk_class " full_form
	}
}
