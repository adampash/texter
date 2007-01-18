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
MsgBox, %EnterKeys%
FileRead, TabKeys, %A_WorkingDir%\replacements\tab.csv

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this section is dabbling with the hotkey replacement of RCtrl
Hotkey,$Tab,FIRE
Hotkey,$Enter,FIRE
Goto, Start

FIRE:
StringTrimLeft,hotkey,A_ThisHotkey,1
;StringLen,hotkeyl,hotkey 
;MsgBox %A_ThisHotkey%
;If hotkeyl>1 
hotkey=`{%hotkey%`} 
Send,{RCtrl} 
;Send, {%A_ThisHotkey%}
;MsgBox %hotkey%!
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


START:
;hotkey = 
Input,input,V L10,{RCtrl}

if hotkey = `{Tab`}
{
	;MsgBox Tab!
	if input in %TabKeys%
	{
		FileRead, ReplacementText, %A_WorkingDir%\replacements\%input%.txt
		;MsgBox, %ReplacementText%
		GoSub, Execute
	}
	else 
	{
		Send,%hotkey%
	}
}

if hotkey = `{Enter`}
{
	;MsgBox Enter!
	if input in %EnterKeys%
	{
		FileRead, ReplacementText, %A_WorkingDir%\replacements\%input%.txt
		;MsgBox, %ReplacementText%
		GoSub, Execute
	}
	else 
	{
		Send,%hotkey%
	}
}

if ErrorLevel = Max
{
    Goto, Start
    return
}
if ErrorLevel = EndKey:RCtrl
{
	MsgBox, You hit Ctrl
}

if ErrorLevel = EndKey:Enter
{
	;MsgBox, You hit Enter after %input%
	if input in %EnterKeys%
	{
		FileRead, ReplacementText, %A_WorkingDir%\replacements\%input%.txt
		;MsgBox, %ReplacementText%
		Send {BS}
		GoSub, Execute
	}
	GoSub, Start
}

if ErrorLevel = EndKey:Tab
{
	;MsgBox, You hit Enter after %input%
	if input in %TabKeys%
	{
		FileRead, ReplacementText, %A_WorkingDir%\replacements\%input%.txt
		;MsgBox, %ReplacementText%
		Send {BS}
		GoSub, Execute
	}
	GoSub, Start
}
if ErrorLevel = EndKey:Space
{
	GoSub, Start
}

Goto, START

EXECUTE:
StringLen,BSlength,input
Send {BS %BSlength%}
Send %ReplacementText%
;MsgBox, You need to backspace %Backspace% times.
return