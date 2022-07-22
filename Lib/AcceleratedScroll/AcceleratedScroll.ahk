; Originally by BoffinbraiN
; For full details, visit the forum thread:
; https://autohotkey.com/board/topic/48426-accelerated-scrolling-script

#Include <Default Settings>

#MaxHotkeysPerInterval 140  ; Default: 120

AcceleratedScroll()  ; To use effectively, make sure this function is the first line in a hotkey.
{
	; Length of a scrolling session
	; Keep scrolling within this time to accumulate boost.
	; Default: 500 | Recommended: 400 < x < 1000
	static TIMEOUT_MS := 500
	
	; If you scroll a long distance in one session, apply additional boost factor.
	; The higher the value, the longer it takes to activate, and the slower it accumulates.
	; Set to 0 to disable completely.
	; Default: 30
	, BOOST := 25
	
	; Spamming applications with hundreds of individual scroll events can slow them down,
	; so set a max number of scrolls sent per click.
	; Default: 60
	, MAX_SCROLLS := 70
	
	; Session variables
	, distance
	, max_speed
	
	time_between_hotkeys_ms := A_TimeSincePriorHotkey

	if % not (A_ThisHotkey = A_PriorHotkey && time_between_hotkeys_ms < TIMEOUT_MS)
	{
		; Combo broken, so reset session variables
		distance := 0
		max_speed := 1
		
		MouseClick %A_ThisHotkey%
		return
	}
	
	; Remember how many times the current direction has been scrolled in
	distance++
	
	; Calculate acceleration factor using a 1/x curve
	speed := time_between_hotkeys_ms < 100 ? 250.0/time_between_hotkeys_ms - 1 : 1
	
	; Apply boost
	if % BOOST > 1 && distance > BOOST
	{
		; Hold onto the highest speed achieved during this boost
		if % speed > max_speed
		{
			max_speed := speed
		}
		else
		{
			speed := max_speed
		}
		
		speed *= distance / BOOST
	}
	
	speed := speed > MAX_SCROLLS ? MAX_SCROLLS : Floor(speed)
	
	MouseClick %A_ThisHotkey%, , , speed
}
