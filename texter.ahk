;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Adam Pash <adam@lifehacker.com>
;
; Script Function:
;	Creates easy auto-replacing hotstrings for repetitive text
;

#SingleInstance,Force 
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetKeyDelay,0 
SetWinDelay,0 
SetWorkingDir, %A_ScriptDir%
FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this section is dabbling with the hotkey replacement of RCtrl
Hotkey,$Tab,FIRE
Hotkey,$Enter,FIRE
Hotkey,$Space,FIRE
Hotkey,^+h,NEWKEY

Goto Start

FIRE:
;MsgBox,%A_ThisHotKey%
StringTrimLeft,hotkey,A_ThisHotkey,1
;If hotkeyl>1 
hotkey=`{%hotkey%`} 
;MsgBox, %hotkey%
;Something's weird here - RCtrl isn't triggering the input match below!
Send,{RCtrl}
;Send,{RCtrl}
return

NEWKEY:
Gui, Destroy
Gui, +AlwaysOnTop +Owner -SysMenu ;suppresses taskbar button, always on top, removes minimize/close
Gui, Add, Text,x15 y40, Hotstring:
Gui, Add, Edit, x13 y55 r1 W65 vRString,
Gui, Add, Text,x+20 y40, Text:
Gui, Add, Edit, xp y55 r6 W400 vFullText, Enter your replacement text here...
Gui, Add, Text,,Execute with:
Gui, Add, Checkbox, vEnterCbox yp xp+75, Enter
Gui, Add, Checkbox, vTabCbox yp xp+60, Tab
Gui, Add, Checkbox, vSpaceCbox yp xp+60, Space
Gui, Add, Button,w80 default,&OK
Gui, Add, Button,w80 xp+100 GButtonCancel,&Cancel
Gui, Show, W500 H200
return

ButtonCancel:
Gui,Destroy
return

ButtonOK:
Gui, Submit
If RString<>
{
	if FullText<>
	{
		IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
		{
			if EnterCbox = 1 
			{
				FileAppend,%Rstring%`,, %A_WorkingDir%\bank\enter.csv
				FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
				FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
			}
			if TabCbox = 1
			{
				FileAppend,%Rstring%`,, %A_WorkingDir%\bank\tab.csv
				FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
				IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
					FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
			}
			if SpaceCbox = 1
			{
				FileAppend,%Rstring%`,, %A_WorkingDir%\bank\space.csv
				FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
				IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
					FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
			}
		}
		else
		{
			MsgBox %Rstring% replacment already exists
		}
		;MsgBox You entered text in both
	}
	else
		MsgBox Only replacement
}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
;MsgBox Start
;hotkey = 
Input,input,V L99,{RCtrl}
;MsgBox match
if hotkey = `{Tab`}
{
	;MsgBox, Tab2
	if input in %TabKeys%
	{
		GoSub, Execute
		Goto,Start
	}
	else 
	{
		Send,%hotkey%
		Goto,Start
	}
}
else if hotkey = `{Enter`}
{
	if input in %EnterKeys%
	{
		GoSub, Execute
		Goto,Start
	}
	else 
	{
		Send,%hotkey%
		Goto,Start
	}
} 
else if hotkey = `{Space`}
{
	if input in %SpaceKeys%
	{
		GoSub, Execute
		Goto,Start
	}
	else 
	{
		Send,%hotkey%
		Goto,Start
	}
}
else
{
	Send,%hotkey%
	Goto, Start
}

if ErrorLevel = Max
{
    Goto, Start
    return
}

Goto, START
return

EXECUTE:
SoundPlay, %A_WinDir%\Media\Windows XP Restore.wav
FileRead, ReplacementText, %A_WorkingDir%\replacements\%input%.txt
;MsgBox, %ReplacementText%
;Send {BS}
oldClip = %Clipboard%
Clipboard = %ReplacementText%
StringReplace, Clipboard, ReplacementText, `%c, %oldClip%, All
StringGetPos,CursorPoint,Clipboard,`%|
if ErrorLevel = 0
{
	StringReplace, Clipboard, Clipboard, `%|,, All
	StringLen,ClipLength,Clipboard
	ReturnTo := ClipLength - CursorPoint
}
else
{
	ReturnTo := 0
}
StringLen,BSlength,input
Send {BS %BSlength%}
Send, ^v
if ReturnTo > 0
	Send {Left %ReturnTo%}
Clipboard = %oldClip%
return

Parse(text)
{

}