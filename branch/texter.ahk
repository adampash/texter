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
;MsgBox, %Ignore%
Gosub,TRAYMENU
;SetTimer,GETWINDOW,999 

FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv

Hotkey,^+h,NEWKEY

Goto Start

START:
hotkey = 
Input,input,V L99,{SC77}
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
;SetTimer,GETWINDOW,Off 
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
IfInString,Clipboard,::scr::
{
	StringReplace,Script,Clipboard,::scr::,,
	Send,%Script%
	oldClip = %Clipboard% ; this is to make sure that if someone scripts a copy, it is retained
}
else
{
	Send,^v
}
if ReturnTo > 0
	Send {Left %ReturnTo%}
Clipboard = %oldClip%
;SetTimer,GETWINDOW,On 
return

HOTKEYS: 
StringTrimLeft,hotkey,A_ThisHotkey,1 
StringLen,hotkeyl,hotkey 
If hotkeyl>1 
  hotkey=`{%hotkey%`} 
Send,{SC77}
Return 

READINI: 
IfNotExist bank
	FileCreateDir, bank
IfNotExist replacements
	FileCreateDir, replacements
IfNotExist,AutoClip.ini 
  FileAppend,;Keys that start completion - must include Ignore and Cancel keys`n[Autocomplete]`nKeys={Escape}`,{Tab}`,{Enter}`,{Space}`,{`,}`,{;}`,{.}`,{:}`,{Left}`,{Right}`n;Keys not to send after completion`n[Ignore]`nKeys={Tab}`,{Enter}`,{Space}`n;Keys that cancel completion`n[Cancel]`nKeys={Escape},AutoClip.ini 
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
Gui,1: Destroy
Gui,1: font, s12, Arial  
Gui,1: +AlwaysOnTop -SysMenu +ToolWindow  ;suppresses taskbar button, always on top, removes minimize/close
Gui,1: Add, Text,x10 y20, Hotstring:
Gui,1: Add, Edit, x13 y45 r1 W65 vRString,
Gui,1: Add, Text,x100 y20, Text:
Gui,1: Add, Edit, xp y45 r4 W395 vFullText, Enter your replacement text here...
Gui,1: Add, Text,x115,Trigger:
Gui,1: Add, Checkbox, vEnterCbox yp x175, Enter
Gui,1: Add, Checkbox, vTabCbox yp x242, Tab
Gui,1: Add, Checkbox, vSpaceCbox yp x305, Space
Gui,1: font, s8, Arial 
Gui,1: Add, Button,w80 x320 default,&OK
Gui,1: Add, Button,w80 xp+90 GButtonCancel,&Cancel
Gui,1: Show, W500 H200,Add new hotstring...
Hotkey,Esc,ButtonCancel,On
return

ButtonCancel:
Gui,1: Destroy
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
Menu,Tray,Add,&Manage hotstrings,MANAGE
;Menu,Tray,Add,&About...,ABOUT
Menu,Tray,Add,E&xit,EXIT
;Menu,Tray,Default,Texter
;Menu,Tray,Tip,Texter
Return

GetFileList:
FileList =
Loop, %A_WorkingDir%\replacements\*.txt
{
	FileList = %FileList%%A_LoopFileName%|
}
StringReplace, FileList, FileList, .txt,,All
return

MANAGE:
GoSub,GetFileList
StringReplace, FileList, FileList, .txt,,All
Gui,2: Destroy
Gui,2: font, s12, Arial  
Gui,2: Add, Text,x15 y20, Hotstring:
Gui,2: Add, ListBox, x13 y40 r15 W100 vChoice gShowString Sort,%FileList%
Gui,2: Add, Text,x+20 y20, Text:
Gui,2: Add, Edit, xp y40 r12 W460 vFullText,
Gui,2: Add, Text,y282 x150,Trigger:
Gui,2: Add, Checkbox, vEnterCbox yp xp+60, Enter
Gui,2: Add, Checkbox, vTabCbox yp xp+65, Tab
Gui,2: Add, Checkbox, vSpaceCbox yp xp+60, Space
Gui,2: font, s8, Arial
Gui,2: Add,Button,w80 GPButtonSave yp x500,&Save
Gui,2: Add, Button,w80 default GPButtonOK x420 yp+80,&OK
Gui,2: Add, Button,w80 xp+90 GPButtonCancel,&Cancel
Gui,2: font, s12, Arial 
Gui,2: Add, Button, w35 x20 y320 GAdd,+
Gui,2: Add, Button, w35 x60 y320 GDelete,-
Gui,2: Show, W600 H400, Texter Management
return

ADD:
Loop,Parse,keys,`, 
{ 
  StringTrimLeft,key,A_LoopField,1 
  StringTrimRight,key,key,1 
  StringLen,length,key 
  If length=0 
    Hotkey,$`,,Off
  Else 
    Hotkey,$%key%,Off
}
GoSub,Newkey
IfWinExist,Add new hotstring...
{
	;MsgBox Window exists
	WinWaitClose,Add new hotstring...,,
}
GoSub,GetFileList
StringReplace, FileList, FileList,|%RString%|,|%RString%||
;MsgBox %FileList% `n %RString%
GuiControl,,Choice,|%FileList%
GoSub,ShowString
Loop,Parse,keys,`, 
{ 
  StringTrimLeft,key,A_LoopField,1 
  StringTrimRight,key,key,1
  StringLen,length,key 
  If length=0 
    Hotkey,$`,,On
  Else 
    Hotkey,$%key%,On
}
return

DELETE:
GuiControlGet,ActiveChoice,,Choice
MsgBox,1,Confirm Delete,Are you sure you want to delete this hotstring: %ActiveChoice%?
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

;;;;;;;;;;;;;;;;;;; REMOVE IF NOT IN USE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GETWINDOW: 
WinGet,window0,ID,A 
WinGetClass,class,ahk_id %window0% 
If class<> 
If class<>Shell_TrayWnd 
If class<>AutoHotkey 
{ 
  ControlGetFocus,control,ahk_id %window0% 
  window=%window0% 
} 
Return 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EXIT: 
ExitApp 