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
Goto, Start

FIRE:
StringTrimLeft,hotkey,A_ThisHotkey,1
;If hotkeyl>1 
hotkey=`{%hotkey%`} 
Send,{RCtrl} 
Return
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