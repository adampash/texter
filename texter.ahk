;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;
#SingleInstance,Force 
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir%
ArrayCount = 0
One = 1
Hotkeys%One% = "Hi"

Loop, %A_WorkingDir%\replacements\*.txt
{
    ;MsgBox, 4, , Filename = %A_LoopFileFullPath%`n`nContinue?
    ArrayCount += 1
	Hotkeys%ArrayCount% = %A_LoopFileName%
	IfMsgBox, No
        break
}

Loop %ArrayCount%
{
	element := Hotkeys%A_Index%
	;MsgBox % "Element number " . A_Index . " is " . Hotkeys%A_Index%
}
START:
Input,input,V L10, {Enter}{Tab}
if ErrorLevel = Max
{
    ;MsgBox, You entered "%UserInput%", which is the maximum length of text.
    return
}
if ErrorLevel = EndKey:Enter
{
	MsgBox, You hit Enter
	GoSub, Start
}

GoSub, START