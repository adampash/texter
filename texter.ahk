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
SetWorkingDir, %A_ScriptDir%
ArrayCount = 0
One = 1
Hotkeys%One% = "Hi"
TabKeys = ""
FileRead, EnterKeys, %A_WorkingDir%\replacements\enter.csv
MsgBox, %EnterKeys%
FileRead, TabKeys, %A_WorkingDir%\replacements\tab.csv
START:
hotkey = 
Input,input,V L10, {Enter}{Tab}{Space}
if ErrorLevel = Max
{
    ;MsgBox, You entered "%UserInput%", which is the maximum length of text.
    return
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

GoSub, START

EXECUTE:
StringLen,BSlength,input
Send {BS %BSlength%}
Send %ReplacementText%
;MsgBox, You need to backspace %Backspace% times.
return