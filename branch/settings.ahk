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
SetKeyDelay,0 
SetWinDelay,0 
SetWorkingDir, %A_ScriptDir%

FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
Goto, Settings

GetFileList:
FileList =
Loop, %A_WorkingDir%\replacements\*.txt
{
	FileList = %FileList%%A_LoopFileName%|
}
StringReplace, FileList, FileList, .txt,,All
return

;MsgBox, %FileList%

SETTINGS:
GoSub,GetFileList
StringReplace, FileList, FileList, .txt,,All
Gui,2: Destroy
Gui,2: font, s12, Arial  
;Gui, +Owner -SysMenu ;suppresses taskbar button, always on top, removes minimize/close
Gui,2: Add, Text,x15 y20, Hotstring:
Gui,2: Add, ListBox, x13 y40 r15 W100 vChoice gShowString Sort,%FileList%
Gui,2: Add, Text,x+20 y20, Text:
Gui,2: Add, Edit, xp y40 r12 W400 vFullText, Enter your replacement text here...
Gui,2: Add, Text,,Execute with:
Gui,2: Add, Checkbox, vEnterCbox yp xp+75, Enter
Gui,2: Add, Checkbox, vTabCbox yp xp+60, Tab
Gui,2: Add, Checkbox, vSpaceCbox yp xp+60, Space
Gui,2: Add,Button,w80 GPButtonSave yp xp+100,&Save
Gui,2: Add, Button,w80 GPButtonOK xp-50 yp+80,&OK
Gui,2: Add, Button,w80 xp+100 GPButtonCancel,&Cancel
Gui,2: Add, Button, w30 x50 y320 GAdd,+
Gui,2: Add, Button, w30 x90 y320 GDelete,-
Gui,2: Show, W600 H400, Texter Management
return

ADD:
GoSub,Newkey
IfWinExist,Add new hotstring...
	WinWaitClose,Add new hotstring...,,
GoSub,GetFileList
StringReplace, FileList, FileList,%RString%,%RString%|
GuiControl,,Choice,|%FileList%
GoSub,ShowString
return

DELETE:
GuiControlGet,ActiveChoice,,Choice
MsgBox,1,Confirm Delete,You wanna delete this: %ActiveChoice%?
IfMsgBox, OK
{
	FileDelete,%A_WorkingDir%\replacements\%ActiveChoice%.txt
	if ActiveChoice in %EnterKeys%
	{
		StringReplace, EnterKeys, EnterKeys, %ActiveChoice%`,,,All
		FileDelete, %A_WorkingDir%\bank\enter.csv
		FileAppend,%EnterKeys%, %A_WorkingDir%\bank\enter.csv
		FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
	}
	if ActiveChoice in %TabKeys%
	{
		StringReplace, TabKeys, TabKeys, %ActiveChoice%`,,,All
		FileDelete, %A_WorkingDir%\bank\tab.csv
		FileAppend,%TabKeys%, %A_WorkingDir%\bank\tab.csv
		FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
	}
	if ActiveChoice in %SpaceKeys%
	{
		StringReplace, SpaceKeys, SpaceKeys, %ActiveChoice%`,,,All
		FileDelete, %A_WorkingDir%\bank\space.csv
		FileAppend,%SpaceKeys%, %A_WorkingDir%\bank\space.csv
		FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
	}
	GoSub,GetFileList
	GuiControl,,Choice,|%FileList%
	GuiControl,,FullText,
	GuiControl,,EnterCbox,0
	GuiControl,,TabCbox,0
	GuiControl,,SpaceCbox,0
}
else
	return
return

ShowString:
GuiControlGet,ActiveChoice,,Choice
if ActiveChoice in %EnterKeys%
{
	;MsgBox,Yep
	GuiControl,,EnterCbox,1
}
else
	GuiControl,,EnterCbox,0
if ActiveChoice in %TabKeys%
{
	;MsgBox,Yep
	GuiControl,,TabCbox,1
}
else
	GuiControl,,TabCbox,0
if ActiveChoice in %SpaceKeys%
{
	;MsgBox,Yep
	GuiControl,,SpaceCbox,1
}
else
	GuiControl,,SpaceCbox,0

;MsgBox, Hi
FileRead, Text, %A_WorkingDir%\replacements\%ActiveChoice%.txt
;MsgBox,%ActiveChoice%
GuiControl,,FullText,%Text%
return

PButtonSave:
GuiControlGet,ActiveChoice,,Choice
GuiControlGet,SaveText,,FullText
;MsgBox, %SaveText%
FileDelete, %A_WorkingDir%\replacements\%ActiveChoice%.txt
FileAppend,%SaveText%,%A_WorkingDir%\replacements\%ActiveChoice%.txt
GuiControlGet,ActiveChoice,,Choice
GuiControlGet,EnterCbox,,EnterCbox
GuiControlGet,TabCbox,,TabCbox
GuiControlGet,SpaceCbox,,SpaceCbox
Gosub,SAVE
;;
return

PButtonCancel:
Gui, Destroy
return

PButtonOK:
Gui, Submit
GuiControlGet,ActiveChoice,,Choice
GuiControlGet,SaveText,,FullText
;MsgBox, %SaveText%
FileDelete, %A_WorkingDir%\replacements\%ActiveChoice%.txt
FileAppend,%SaveText%,%A_WorkingDir%\replacements\%ActiveChoice%.txt
GuiControlGet,ActiveChoice,,Choice
GuiControlGet,EnterCbox,,EnterCbox
GuiControlGet,TabCbox,,TabCbox
GuiControlGet,SpaceCbox,,SpaceCbox
Gosub,SAVE

return

SAVE:
if EnterCbox = 1
{
	if ActiveChoice in %EnterKeys%
	{
	}
	else
	{
		FileAppend,%ActiveChoice%`,, %A_WorkingDir%\bank\enter.csv
		FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
	}
}
else
{
	if ActiveChoice in %EnterKeys%
	{
		StringReplace, EnterKeys, EnterKeys, %ActiveChoice%`,,,All
		FileDelete, %A_WorkingDir%\bank\enter.csv
		FileAppend,%EnterKeys%, %A_WorkingDir%\bank\enter.csv
		FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
	}
}
if TabCbox = 1
{
	if ActiveChoice in %TabKeys%
	{
	}
	else
	{
		FileAppend,%ActiveChoice%`,, %A_WorkingDir%\bank\tab.csv
		FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
	}
}
else
{
	if ActiveChoice in %TabKeys%
	{
		StringReplace, TabKeys, TabKeys, %ActiveChoice%`,,,All
		FileDelete, %A_WorkingDir%\bank\tab.csv
		FileAppend,%TabKeys%, %A_WorkingDir%\bank\tab.csv
		FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
	}

}
if SpaceCbox = 1
{
	if ActiveChoice in %SpaceKeys%
	{
	}
	else
	{
		FileAppend,%ActiveChoice%`,, %A_WorkingDir%\bank\space.csv
		FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
	}
}
else
{
	if ActiveChoice in %SpaceKeys%
	{
		StringReplace, SpaceKeys, SpaceKeys, %ActiveChoice%`,,,All
		FileDelete, %A_WorkingDir%\bank\space.csv
		FileAppend,%SpaceKeys%, %A_WorkingDir%\bank\space.csv
		FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
	}

}
return

;;;;;;;;;;;;;;;;;;;;;;;;;; DELETE THIS WHEN MERGING WITH TEXTER PROPER :::::::::::::::::::::::::;;;;;
ButtonOK:
GuiControlGet,RString,,RString
IfExist, %A_WorkingDir%\replacements\%RString%.txt
{
	MsgBox A replacement with the text %Rstring% already exists.  Would you like to try again?
	return
}
Gui, Submit
If RString<>
{
	if FullText<>
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
}
return

ButtonCancel:
Gui,1: Destroy
Hotkey,Esc,Off
return

NEWKEY:
Gui,1: Destroy
Gui,1: +AlwaysOnTop +Owner -SysMenu ;suppresses taskbar button, always on top, removes minimize/close
Gui,1: Add, Text,x15 y40, Hotstring:
Gui,1: Add, Edit, x13 y55 r1 W65 vRString,
Gui,1: Add, Text,x+20 y40, Text:
Gui,1: Add, Edit, xp y55 r6 W400 vFullText, Enter your replacement text here...
Gui,1: Add, Text,,Trigger with:
Gui,1: Add, Checkbox, vEnterCbox yp xp+75, Enter
Gui,1: Add, Checkbox, vTabCbox yp xp+60, Tab
Gui,1: Add, Checkbox, vSpaceCbox yp xp+60, Space
Gui,1: Add, Button,w80 default,&OK
Gui,1: Add, Button,w80 xp+100 GButtonCancel,&Cancel
Gui,1: Show, W500 H200,Add new hotstring...
Hotkey,Esc,ButtonCancel,On
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END DELETION OF REDUNDANT CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


EXIT: 
ExitApp 
