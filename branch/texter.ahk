; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Adam Pash <adam@lifehacker.com>
; Gratefully adapted several ideas from AutoClip by Skrommel:
;		http://www.donationcoder.com/Software/Skrommel/index.html#AutoClip
; Script Function:
;	Designed to implement simple, on-the-fly creation and managment 
;	of auto-replacing hotstrings for repetitive text

#SingleInstance,Force 
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
;SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetKeyDelay,0 
SetWinDelay,0 
SetWorkingDir, "%A_ScriptDir%"

Gosub,READINI
MsgBox, %Ignore%
Gosub,TRAYMENU

FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv

Hotkey,^+h,NEWKEY

Goto Start

START:
hotkey = 
Input,input,V L99,{RCtrl}
if hotkey in %Ignore%
{
	if hotkey = `{Tab`}
		if input in %TabKeys%
			GoSub, Execute
		else
			Send,%hotkey%
	else if hotkey = `{Enter`}
		if input in %EnterKeys%
			GoSub, Execute
		else
			Send,%hotkey%
	else if hotkey = `{Space`}
		if input in %SpaceKeys%
			GoSub, Execute
		else
			Send,%hotkey%
	else
		Send,%hotkey%
		Goto,Start
}
else
{
	Send,%hotkey%
	Goto,Start
}
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

HOTKEYS: 
StringTrimLeft,hotkey,A_ThisHotkey,1 
StringLen,hotkeyl,hotkey 
If hotkeyl>1 
  hotkey=`{%hotkey%`} 
Send,{RCtrl} 
Return 

READINI: 
IfNotExist bank
	FileCreateDir, bank
IfNotExist replacements
	FileCreateDir, replacements
IfNotExist,AutoClip.ini 
  FileAppend,;Keys that start completion - must include Ignore and Cancel keys`n[Autocomplete]`nKeys={Escape}`,{Tab}`,{Enter}`,{Space}`,{`,}`,{;}`,{.}`,{:}`,{!}`,{Left}`,{Right}`n;Keys not to send after completion`n[Ignore]`nKeys={Tab}`,{Enter}`,{Space}`n;Keys that cancel completion`n[Cancel]`nKeys={Escape},AutoClip.ini 
IniRead,cancel,AutoClip.ini,Cancel,Keys ;keys to stop completion, remember {} 
IniRead,ignore,AutoClip.ini,Ignore,Keys ;keys not to send after completion 
IniRead,keys,AutoClip.ini,Autocomplete,Keys 
Loop,Parse,keys,`, 
{ 
  StringTrimLeft,key,A_LoopField,1 
  StringTrimRight,key,key,1 
  StringLen,length,key 
  If length=0 
    Hotkey,$`,,HOTKEYS 
  Else 
    Hotkey,$%key%,HOTKEYS 
} 
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Implementation and GUI for on-the-fly creation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NEWKEY:
Gui, Destroy
Gui, +AlwaysOnTop +Owner -SysMenu ;suppresses taskbar button, always on top, removes minimize/close
Gui, Add, Text,x15 y40, Hotstring:
Gui, Add, Edit, x13 y55 r1 W65 vRString,
Gui, Add, Text,x+20 y40, Text:
Gui, Add, Edit, xp y55 r6 W400 vFullText, Enter your replacement text here...
Gui, Add, Text,,Trigger with:
Gui, Add, Checkbox, vEnterCbox yp xp+75, Enter
Gui, Add, Checkbox, vTabCbox yp xp+60, Tab
Gui, Add, Checkbox, vSpaceCbox yp xp+60, Space
Gui, Add, Button,w80 default,&OK
Gui, Add, Button,w80 xp+100 GButtonCancel,&Cancel
Gui, Show, W500 H200
Hotkey,Esc,ButtonCancel,On
return

ButtonCancel:
Gui,Destroy
Hotkey,Esc,Off
return

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Implementation and GUI for on-the-fly creation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



TRAYMENU:
Menu,Tray,NoStandard 
Menu,Tray,DeleteAll 
;Menu,Tray,Add,Mouser,ABOUT
;Menu,Tray,Add,
Menu,Tray,Add,&Manage hotstrings,SETTINGS
;Menu,Tray,Add,&About...,ABOUT
Menu,Tray,Add,E&xit,EXIT
;Menu,Tray,Default,Texter
;Menu,Tray,Tip,Texter
Return

SETTINGS:
FileList =
Loop, %A_WorkingDir%\replacements\*.txt
{
	FileList = %FileList%%A_LoopFileName%|
}
StringReplace, FileList, FileList, .txt,,All
Gui, Destroy
Gui, font, s12, Arial  
;Gui, +Owner -SysMenu ;suppresses taskbar button, always on top, removes minimize/close
Gui, Add, Text,x15 y20, Hotstring:
Gui, Add, ListBox, x13 y40 r15 W100 vChoice gShowString,%FileList%
Gui, Add, Text,x+20 y20, Text:
Gui, Add, Edit, xp y40 r12 W400 vFullText, Enter your replacement text here...
Gui, Add, Text,,Execute with:
Gui, Add, Checkbox, vEnterCbox yp xp+75, Enter
Gui, Add, Checkbox, vTabCbox yp xp+60, Tab
Gui, Add, Checkbox, vSpaceCbox yp xp+60, Space
Gui,Add,Button,w80 GPButtonSave yp xp+100,&Save
Gui, Add, Button,w80 GPButtonOK xp-50 yp+80,&OK
Gui, Add, Button,w80 xp+100 GPButtonCancel,&Cancel
Gui, Add, Button, w25 x90 y320 GDelete,-
Gui, Show, W600 H400
return

DELETE:
MsgBox You wanna delete this?
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

;If RString<>
;{
;	if FullText<>
;	{
;		IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
;		{
;			if EnterCbox = 1 
;			{
;				FileAppend,%Rstring%`,, %A_WorkingDir%\bank\enter.csv
;				FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
;				FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
;				GoSub,Save
;			}
;			if TabCbox = 1
;			{
;;				FileAppend,%Rstring%`,, %A_WorkingDir%\bank\tab.csv
;				FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
;				IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
;					FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
;				GoSub,Save
;			}
;			if SpaceCbox = 1
;			{
;				FileAppend,%Rstring%`,, %A_WorkingDir%\bank\space.csv
;				FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
;				IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
;					FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
;				GoSub,Save
;			}
;		}
;	}
;	else
;		MsgBox Only replacement
;}
return
;
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
;	else
;	{
;		FileAppend,%ActiveChoice%`,, %A_WorkingDir%\bank\enter.csv
;		FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
;	}
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
;	else
;	{
;		FileAppend,%ActiveChoice%`,, %A_WorkingDir%\bank\enter.csv
;		FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
;	}
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
;	else
;	{
;		FileAppend,%ActiveChoice%`,, %A_WorkingDir%\bank\enter.csv
;		FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
;	}
}
return


EXIT: 
ExitApp 