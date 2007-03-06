; Texter
; Author:         Adam Pash <adam@lifehacker.com>
; Gratefully adapted several ideas from AutoClip by Skrommel:
;		http://www.donationcoder.com/Software/Skrommel/index.html#AutoClip
; Script Function:
;	Designed to implement simple, on-the-fly creation and managment 
;	of auto-replacing hotstrings for repetitive text
;	http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php
#SingleInstance,Force 
#NoEnv
SetKeyDelay,0 
SetWinDelay,0 
SetWorkingDir, "%A_ScriptDir%"
Gosub,READINI
Gosub,RESOURCES
Gosub,TRAYMENU

FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
Gosub,GetFileList
Goto Start

START:
hotkey = 
Input,input,V L99,{SC77}
if hotkey In %cancel%
{
	Send,%hotkey%
	Goto,START
}
IfNotInString,FileList,%input%|
{
	Send,%hotkey%
	Goto,START
}
else if hotkey = `{Space`}
{
	if input in %SpaceKeys%
	{
		GoSub, Execute
		Goto,START
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
		Goto,START
	}
	else
	{
		Send,%hotkey%
		Goto,Start
	}
}
else if hotkey = `{Tab`}
{
	if input in %TabKeys%
	{
		GoSub, Execute
		GoTo,Start
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
	Goto,START
}
return

EXECUTE:
SoundPlay, %A_ScriptDir%\resources\replace.wav
oldClip = %Clipboard%
ReturnTo := 0
StringLen,BSlength,input
Send {BS %BSlength%}
FileRead, Clipboard, %A_WorkingDir%\replacements\%input%.txt
IfInString,Clipboard,::scr::
{
	StringReplace,Script,Clipboard,::scr::,,
	Send,%Script%
	oldClip = %Clipboard% ; this is to make sure that if someone scripts a copy, it is retained
	return
}
else
{
	IfInString,Clipboard,`%c
	{
		StringReplace, Clipboard, Clipboard, `%c, %oldClip%, All
	}
	IfInString,Clipboard,`%|
	{
		StringGetPos,CursorPoint,Clipboard,`%|
		StringReplace, MeasureClip,Clipboard,`n,,All
		StringGetPos,CursorPoint,MeasureClip,`%|
		StringReplace, Clipboard, Clipboard, `%|,, All
		StringReplace, MeasureClip,Clipboard,`n,,All
		StringLen,ClipLength,MeasureClip
		ReturnTo := ClipLength - CursorPoint
	}
	Send,^v
	if ReturnTo > 0
	Send {Left %ReturnTo%}
	Clipboard = %oldClip%
}
Return

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
IfNotExist resources
	FileCreateDir, resources
IfNotExist,texter.ini 
  FileAppend,[Hotkey]`nOntheFly=^+H`nManagement=`n[Autocomplete]`nKeys={Escape}`,{Tab}`,{Enter}`,{Space}`,{`,}`,{;}`,{.}`,{:}`,{Left}`,{Right}`n[Ignore]`nKeys={Tab}`,{Enter}`,{Space}`n[Cancel]`nKeys={Escape}`n,texter.ini 
IniRead,cancel,texter.ini,Cancel,Keys ;keys to stop completion, remember {} 
IniRead,ignore,texter.ini,Ignore,Keys ;keys not to send after completion 
IniRead,keys,texter.ini,Autocomplete,Keys 
IniRead,otfhotkey,texter.ini,Hotkey,OntheFly
IniRead,managehotkey,texter.ini,Hotkey,Management
;MsgBox,%otfhotkey%
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
if otfhotkey<>
	Hotkey,%otfhotkey%,NEWKEY
if managehotkey <>
	Hotkey,%managehotkey%,MANAGE
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Implementation and GUI for on-the-fly creation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NEWKEY:
Gui,1: Destroy
Gui,1: font, s12, Arial  
Gui,1: +AlwaysOnTop -SysMenu +ToolWindow  ;suppresses taskbar button, always on top, removes minimize/close
Gui,1: Add, Text,x10 y20, Hotstring:
Gui,1: Add, Edit, x13 y45 r1 W65 vRString,
Gui,1: Add, Edit, x100 y45 r4 W395 vFullText, Enter your replacement text here...
Gui,1: Add, Text,x115,Trigger:
Gui,1: Add, Checkbox, vEnterCbox yp x175, Enter
Gui,1: Add, Checkbox, vTabCbox yp x242, Tab
Gui,1: Add, Checkbox, vSpaceCbox yp x305, Space
Gui,1: font, s8, Arial 
Gui,1: Add, Button,w80 x320 default,&OK
Gui,1: Add, Button,w80 xp+90 GButtonCancel,&Cancel
Gui,1: font, s12, Arial  
Gui,1: Add,DropDownList,x100 y15 vTextOrScript, Text||Script
Gui,1: Add,Picture,x20 y100,%A_WorkingDir%\resources\texter48x48.png
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
	MsgBox,262144,Hotstring already exists, A replacement with the text %Rstring% already exists.  Would you like to try again?
	return
}
GuiControlGet,EnterCbox,,EnterCbox
GuiControlGet,TabCbox,,TabCbox
GuiControlGet,SpaceCbox,,SpaceCbox
if EnterCbox = 0
	if TabCbox = 0
		if SpaceCbox = 0
		{
			MsgBox,262144,Choose a trigger,You need to choose a trigger in order to save a hotstring replacement.
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
			if TextOrScript = Script
				FullText = ::scr::%FullText%
			FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
		}
		if TabCbox = 1
		{
			FileAppend,%Rstring%`,, %A_WorkingDir%\bank\tab.csv
			FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
			IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
			{
				if TextOrScript = Script
					FullText = ::scr::%FullText%
				FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
			}
		}
		if SpaceCbox = 1
		{
			FileAppend,%Rstring%`,, %A_WorkingDir%\bank\space.csv
			FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
			IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
			{
				if TextOrScript = Script
					FullText = ::scr::%FullText%
				FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
			}
		}
	}
}
Gosub,GetFileList
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Implementation and GUI for on-the-fly creation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



TRAYMENU:
Menu,TRAY,NoStandard 
Menu,TRAY,DeleteAll 
Menu,TRAY,Add,&Manage hotstrings,MANAGE
Menu,TRAY,Add,&Create new hotstring,NEWKEY
Menu,TRAY,Add
Menu,TRAY,Add,&Preferences...,PREFERENCES
Menu,TRAY,Add,&Help,HELP
Menu,TRAY,Add
Menu,TRAY,Add,&About...,ABOUT
Menu,TRAY,Add,E&xit,EXIT
Menu,Tray,Tip,Texter
Return

ABOUT:
Gui,4: Destroy
Gui,4: Add,Picture,x30 y10,%A_WorkingDir%\resources\texter48x48.png
Gui,4: font, s36, Arial
Gui,4: Add, Text,x90 y5,Texter
Gui,4: font, s9, Arial 
Gui,4: Add,Text,x10 y70 Center,Texter is a text replacement utility designed to save`nyou countless keystrokes on repetitive text entry by`nreplacing user-defined abbreviations (or hotstrings)`nwith your frequently-used text snippets.`n`nTexter is written by Adam Pash and distributed`nby Lifehacker under the GNU Public License.`nFor details on how to use Texter, check out the
Gui,4:Font,underline bold
Gui,4:Add,Text,cBlue gTexterHomepage Center x110 y190,Texter homepage
Gui,4: Show,w310 h220,About Texter
Return

TexterHomepage:
Run http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php
return

BasicUse:
Run http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php#basic
return

Scripting:
Run http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php#advanced
return

HELP:
Gui,5: Destroy
Gui,5: Add,Picture,x65 y10,%A_WorkingDir%\resources\texter48x48.png
Gui,5: font, s36, Arial
Gui,5: Add, Text,x125 y5,Texter
Gui,5: font, s9, Arial 
Gui,5: Add,Text,x19 y255 w300 center,All of Texter's documentation can be found online at the
Gui,5:Font,underline bold
Gui,5:Add,Text,cBlue gTexterHomepage Center x125 y275,Texter homepage
Gui,5: font, s9 norm, Arial 
Gui,5: Add,Text,x10 y70 w300,For help by topic, click on one of the following:
Gui,5:Font,underline bold
Gui,5:Add,Text,x30 y90 cBlue gBasicUse,Basic Use: 
Gui,5:Font,norm
Gui,5:Add,Text,x50 y110 w280, Covers how to create basic text replacement hotstrings.
Gui,5:Font,underline bold
Gui,5:Add,Text,x30 y150 cBlue gScripting,Sending advanced keystrokes: 
Gui,5:Font,norm
Gui,5:Add,Text,x50 y170 w280, Texter is capable of sending advanced keystrokes, like keyboard combinations.  This section lists all of the special characters used in script creation, and offers a few examples of how you might use scripts.
Gui,5: Show,w350 h300,Texter Help
Return

GetFileList:
FileList =
Loop, %A_WorkingDir%\replacements\*.txt
{
	FileList = %FileList%%A_LoopFileName%|
}
StringReplace, FileList, FileList, .txt,,All
return

PREFERENCES:
if otfhotkey<>
	HotKey,%otfhotkey%,Off
if managehotkey<>
	HotKey,%managehotkey%,Off
Gui,3: Destroy
Gui,3: Add,Text,x10 y10,On-the-Fly shortcut:
Gui,3: Add,Hotkey,xp+10 yp+20 w100 vsotfhotkey, %otfhotkey%
Gui,3: Add,Text,x150 y10,Hotstring Management shortuct:
Gui,3: Add,Hotkey,xp+10 yp+20 w100 vsmanagehotkey, %managehotkey%
Gui,3: Add,Button,x150 y95 w75 GSETTINGSOK Default,&OK
Gui,3: Add,Button,x230 y95 w75 GSETTINGSCANCEL,&Cancel
Gui,3: Show,w310 h120,Texter Preferences
Return

SETTINGSOK:
Gui,3: Submit
If sotfhotkey<>
{
  otfhotkey:=sotfhotkey
  Hotkey,%otfhotkey%,Newkey
  IniWrite,%otfhotkey%,texter.ini,Hotkey,OntheFly
  HotKey,%otfhotkey%,On
}
else
{
	otfhotkey:=sotfhotkey
	IniWrite,%otfhotkey%,texter.ini,Hotkey,OntheFly
}
If smanagehotkey<>
{
  managehotkey:=smanagehotkey
  Hotkey,%managehotkey%,Manage
  IniWrite,%managehotkey%,texter.ini,Hotkey,Management
  HotKey,%managehotkey%,On
}
else
{	
	managehotkey:=smanagehotkey
	IniWrite,%managehotkey%,texter.ini,Hotkey,Management
}
Return

SETTINGSCANCEL:
Gui,3:Destroy
if otfhotkey<>
	HotKey,%otfhotkey%,On
if managehotkey <>
	HotKey,%managehotkey%,On
Return

MANAGE:
GoSub,GetFileList
StringReplace, FileList, FileList, .txt,,All
Gui,2: Destroy
Gui,2: font, s12, Arial  
Gui,2: Add, Text,x15 y20, Hotstring:
Gui,2: Add, ListBox, x13 y40 r15 W100 vChoice gShowString Sort,%FileList%
Gui,2: Add,DropDownList,x+20 y15 vTextOrScript, Text||Script
Gui,2: Add, Edit, xp y45 r12 W460 vFullText,
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
	WinWaitClose,Add new hotstring...,,
}
GoSub,GetFileList
StringReplace, FileList, FileList,|%RString%|,|%RString%||
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
MsgBox,1,Confirm Delete,Are you sure you want to delete this hotstring: %ActiveChoice%
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
	GuiControl,,EnterCbox,1
}
else
	GuiControl,,EnterCbox,0
if ActiveChoice in %TabKeys%
{
	GuiControl,,TabCbox,1
}
else
	GuiControl,,TabCbox,0
if ActiveChoice in %SpaceKeys%
{
	GuiControl,,SpaceCbox,1
}
else
	GuiControl,,SpaceCbox,0

FileRead, Text, %A_WorkingDir%\replacements\%ActiveChoice%.txt
IfInString,Text,::scr::
{
	GuiControl,,TextOrScript,|Text|Script||
	StringReplace,Text,Text,::scr::,,
}
else
	GuiControl,,TextOrScript,|Text||Script
GuiControl,,FullText,%Text%
return

PButtonSave:
GuiControlGet,ActiveChoice,,Choice
GuiControlGet,SaveText,,FullText
GuiControlGet,ToS,,TextOrScript
FileDelete, %A_WorkingDir%\replacements\%ActiveChoice%.txt
if ToS = Text
{
	FileAppend,%SaveText%,%A_WorkingDir%\replacements\%ActiveChoice%.txt
}
else
{
	FileAppend,::scr::%SaveText%,%A_WorkingDir%\replacements\%ActiveChoice%.txt
}
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
GuiControlGet,ToS,,TextOrScript
FileDelete, %A_WorkingDir%\replacements\%ActiveChoice%.txt
if ToS = Text
	FileAppend,%SaveText%,%A_WorkingDir%\replacements\%ActiveChoice%.txt
else
	FileAppend,::scr::%SaveText%,%A_WorkingDir%\replacements\%ActiveChoice%.txt

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

RESOURCES:
IfNotExist,%A_ScriptDir%\resources\texter.ico
	FileInstall,texter.ico,%A_ScriptDir%\resources\texter.ico,1
IfNotExist,%A_ScriptDir%\resources\replace.wav
	FileInstall,replace.wav,%A_ScriptDir%\resources\replace.wav,1
IfNotExist,%A_ScriptDir%\resources\texter48x48.png
	FileInstall,texter48x48.png,%A_ScriptDir%\resources\texter48x48.png,1
return

EXIT: 
ExitApp 