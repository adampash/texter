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
FileRead, EnterKeys, %A_WorkingDir%\replacements\enter.csv
FileRead, TabKeys, %A_WorkingDir%\replacements\tab.csv

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this section is dabbling with the hotkey replacement of RCtrl
Hotkey,$Tab,FIRE
Hotkey,$Enter,FIRE
Hotkey,$Space,FIRE
Hotkey,^+h,NEWKEY
Hotkey,^+y,TESTY

Goto, Start

FIRE:
StringTrimLeft,hotkey,A_ThisHotkey,1
;If hotkeyl>1 
hotkey=`{%hotkey%`} 
Send,{RCtrl} 
Return

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
Gui, Add, Button,w80 xp+100 default,&Cancel
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
			FileAppend,%FullText%, %A_WorkingDir%\replacements\%RString%.txt
			if EnterCbox<> 
			{
				FileAppend,%Rstring%`,, %A_WorkingDir%\replacements\enter.csv
				FileRead, EnterKeys, %A_WorkingDir%\replacements\enter.csv
			}
			if TabCbox<>
			{
			FileAppend,%Rstring%`,, %A_WorkingDir%\replacements\tab.csv
			FileRead, TabKeys, %A_WorkingDir%\replacements\tab.csv
			}
			if SpaceCbox<>
			{
			FileAppend,%Rstring%`,, %A_WorkingDir%\replacements\space.csv
			FileRead, SpaceKeys, %A_WorkingDir%\replacements\space.csv
			}
		}
		;MsgBox You entered text in both
	}
	else
		MsgBox Only replacement
}
return

TESTY:
Gui, +AlwaysOnTop +Disabled -SysMenu +Owner  ; +Owner avoids a taskbar button.
Gui, Add, Text,, Some text to display.
Gui, Show, NoActivate, Title of Window  
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
;hotkey = 
Input,input,V L99,{RCtrl}

if hotkey = `{Tab`}
{
	if input in %TabKeys%
	{
		GoSub, Execute
	}
	else 
	{
		Send,%hotkey%
	}
}
else if hotkey = `{Enter`}
{
	if input in %EnterKeys%
	{
		GoSub, Execute
	}
	else 
	{
		Send,%hotkey%
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

EXECUTE:
FileRead, ReplacementText, %A_WorkingDir%\replacements\%input%.txt
;MsgBox, %ReplacementText%
;Send {BS}
StringLen,BSlength,input
Send {BS %BSlength%}
Send %ReplacementText%
return