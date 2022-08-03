#SingleInstance Force

SetWorkingDir %A_ScriptDir%
SetKeyDelay -1
SendMode Input

SetTimer WatchPOV, 10

Joy2::  Send {Up 3}
Joy3::  Up
Joy10:: Esc

WatchPOV()
{
	static pov := -1, keys := ""
	
	if % (pov > 0) and (GetKeyState("Joy2") or GetKeyState("Joy3"))
	{
		Send % StrReplace(keys, "}", " Down}")
	}
	else
	{
		pov := GetKeyState("JoyPOV")  ; Get position of the POV control.
	}
	
	prior_keys := keys
	
	switch pov
	{
		case -1:    keys := "", return
		case 0:     keys := "{Space}"
		case 4500:  keys := "{Space} {Right}"
		case 9000:  keys := "{Right}"
		case 13500: keys := "{Down} {Right}"
		case 18000: keys := "{Down}"
		case 22500: keys := "{Down} {Left}"
		case 27000: keys := "{Left}"
		case 31500: keys := "{Space} {Left}"
	}
	
	if (keys = prior_keys)
	{
	    return
	}
	
	if % prior_keys
	{
		Send % StrReplace(prior_keys, "}", " Up}")
	}
	if % keys
	{
		Send % StrReplace(keys, "}", " Down}")
	}
}
