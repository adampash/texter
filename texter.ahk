; Texter
; Author:         Adam Pash <adam@lifehacker.com>
; Gratefully adapted several ideas from AutoClip by Skrommel:
;		http://www.donationcoder.com/Software/Skrommel/index.html#AutoClip
; Huge thanks to Dustin Luck for his contributions
; Script Function:
;	Designed to implement simple, on-the-fly creation and managment 
;	of auto-replacing hotstrings for repetitive text
;	http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php
#SingleInstance,Force 
#NoEnv
AutoTrim,off
SetKeyDelay,0 
SetWinDelay,0 
SetWorkingDir, "%A_ScriptDir%"
Gosub,READINI
Gosub,RESOURCES
Gosub,TRAYMENU
;Gosub,AUTOCLOSE

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
ReturnTo := 0
StringLen,BSlength,input
Send {BS %BSlength%}
FileRead, ReplacementText, %A_WorkingDir%\replacements\%input%.txt

IfInString,ReplacementText,::scr::
{
	;To fix double spacing issue, replace `r`n (return + new line) as AHK sends a new line for each character
	StringReplace,ReplacementText,ReplacementText,`r`n,`n, All
	StringReplace,Script,ReplacementText,::scr::,,
	Send,%Script%
	return
}
else
{
	;To fix double spacing issue, replace `r`n (return + new line) as AHK sends a new line for each character
	;(but only in compatibility mode)
	if MODE = 0
	{
		StringReplace,ReplacementText,ReplacementText,`r`n,`n, All
	}
	IfInString,ReplacementText,`%c
	{
		StringReplace, ReplacementText, ReplacementText, `%c, %Clipboard%, All
	}
	IfInString,ReplacementText,`%t
	{
		FormatTime, CurrTime, , Time
		StringReplace, ReplacementText, ReplacementText, `%t, %CurrTime%, All
	}
	IfInString,ReplacementText,`%ds
	{
		FormatTime, SDate, , ShortDate
		StringReplace, ReplacementText, ReplacementText, `%ds, %SDate%, All
	}
	IfInString,ReplacementText,`%dl
	{
		FormatTime, LDate, , LongDate
		StringReplace, ReplacementText, ReplacementText, `%dl, %LDate%, All
	}
	IfInString,ReplacementText,`%|
	{
		;in clipboard mode, CursorPoint & ClipLength need to be calculated after replacing `r`n
		if MODE = 0
		{
			MeasurementText := ReplacementText
		}
		else
		{
			StringReplace,MeasurementText,ReplacementText,`r`n,`n, All
		}
		StringGetPos,CursorPoint,MeasurementText,`%|
		StringReplace, ReplacementText, ReplacementText, `%|,, All
		StringReplace, MeasurementText, MeasurementText, `%|,, All
		StringLen,ClipLength,MeasurementText
		ReturnTo := ClipLength - CursorPoint
	}

	if MODE = 0
		SendRaw,%ReplacementText%
	else
	{
		oldClip = %Clipboard%
		Clipboard = %ReplacementText%
		Send,^v
		Clipboard = %oldClip%
	}
	if ReturnTo > 0
	Send {Left %ReturnTo%}
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
IfNotExist texter.ini 
{
	MsgBox,4,Check for Updates?,Would you like app to automatically check for updates when it's run?
	IfMsgBox,Yes
		updatereply = 1
	else
		updatereply = 0
}	

IniWrite,0.2,texter.ini,Preferences,Version
cancel := GetValFromIni("Cancel","Keys","{Escape}") ;keys to stop completion, remember {} 
ignore := GetValFromIni("Ignore","Keys","{Tab}`,{Enter}`,{Space}") ;keys not to send after completion 
keys := GetValFromIni("Autocomplete","Keys","{Escape}`,{Tab}`,{Enter}`,{Space}`,{Left}`,{Right}`,{Esc}`,{Up}`,{Down}`,{LButton}")
otfhotkey := GetValFromIni("Hotkey","OntheFly","^+H")
managehotkey := GetValFromIni("Hotkey","Management","")
MODE := GetValFromIni("Settings","Mode",0)
EnterBox := GetValFromIni("Triggers","Enter",0)
TabBox := GetValFromIni("Triggers","Tab",0)
SpaceBox := GetValFromIni("Triggers","Space",0)
Update := GetValFromIni("Settings","UpdateCheck",updatereply)
if Update =
	IniWrite,1,texter.ini,Settings,UpdateCheck
if Update = 1
	SetTimer,UpdateCheck,10000


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

GetValFromIni(section, key, default)
{
	IniRead,IniVal,texter.ini,%section%,%key%
	if IniVal = ERROR
	{
		IniWrite,%default%,texter.ini,%section%,%key%
		IniVal := default
	}
	return IniVal
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Implementation and GUI for on-the-fly creation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NEWKEY:
Gui,1: Destroy
Gui,1: font, s12, Arial  
Gui,1: +AlwaysOnTop -SysMenu +ToolWindow  ;suppresses taskbar button, always on top, removes minimize/close
Gui,1: Add, Text,x10 y20, Hotstring:
Gui,1: Add, Edit, x13 y45 r1 W65 vRString,
Gui,1: Add, Edit, x100 y45 r4 W395 vFullText, Enter your replacement text here...
Gui,1: Add, Text,x115,Trigger:
Gui,1: Add, Checkbox, vEnterCbox yp x175 Checked%EnterBox%, Enter
Gui,1: Add, Checkbox, vTabCbox yp x242 Checked%TabBox%, Tab
Gui,1: Add, Checkbox, vSpaceCbox yp x305 Checked%SpaceBox%, Space
Gui,1: font, s8, Arial 
Gui,1: Add, Button,w80 x320 default,&OK
Gui,1: Add, Button,w80 xp+90 GButtonCancel,&Cancel
Gui,1: font, s12, Arial  
Gui,1: Add,DropDownList,x100 y15 vTextOrScript, Text||Script
Gui,1: Add,Picture,x20 y100,%A_WorkingDir%\resources\texter48x48.png
Gui,1: Show, W500 H200,Add new hotstring...
Hotkey,IfWinActive, Add new hotstring
Hotkey,Esc,ButtonCancel,On
Hotkey,IfWinActive
return

ButtonCancel:
Gui,1: Destroy
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
			IniWrite,1,texter.ini,Triggers,Enter
			FileAppend,%Rstring%`,, %A_WorkingDir%\bank\enter.csv
			FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
			if TextOrScript = Script
				FullText = ::scr::%FullText%
			FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
		}
		else
			IniWrite,0,texter.ini,Triggers,Enter
		if TabCbox = 1
		{
			IniWrite,1,texter.ini,Triggers,Tab
			FileAppend,%Rstring%`,, %A_WorkingDir%\bank\tab.csv
			FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
			IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
			{
				if TextOrScript = Script
					FullText = ::scr::%FullText%
				FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
			}
		}
		else
			IniWrite,0,texter.ini,Triggers,Tab
		if SpaceCbox = 1
		{
			IniWrite,1,texter.ini,Triggers,Space
			FileAppend,%Rstring%`,, %A_WorkingDir%\bank\space.csv
			FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
			IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
			{
				if TextOrScript = Script
					FullText = ::scr::%FullText%
				FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
			}
		}
		else
			IniWrite,0,texter.ini,Triggers,Space
	}
}
IniRead,EnterBox,texter.ini,Triggers,Enter
IniRead,TabBox,texter.ini,Triggers,Tab
IniRead,SpaceBox,texter.ini,Triggers,Space
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
Menu,TRAY,Add,&Disable,DISABLE
if disable = 1
	Menu,Tray,Check,&Disable
Menu,TRAY,Add,E&xit,EXIT
Menu,TRAY,Default,&Manage hotstrings
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
Hotkey,IfWinActive, About Texter
Hotkey,Esc,DismissAbout,On
Hotkey,IfWinActive
Return

DISABLE:
Loop,Parse,keys,`,
{ 
  StringTrimLeft,key,A_LoopField,1 
  StringTrimRight,key,key,1 
  StringLen,length,key 
  If length=0 
	Hotkey,$`,Toggle
  Else 
	Hotkey,$%key%,Toggle
} 
if disable = 0
{
	IniWrite,1,texter.ini,Settings,Disable
	Menu,Tray,Check,&Disable
}
else
{
	IniWrite,0,texter.ini,Settings,Disable
	Menu,Tray,Uncheck,&Disable
}
return

TexterHomepage:
Run http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php
return

BasicUse:
Run http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php#basic
return

Scripting:
Run http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php#advanced
return

DismissAbout:
Gui,4: Destroy
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
Hotkey,IfWinActive, Texter Help
Hotkey,Esc,DismissHelp,On
Hotkey,IfWinActive
Return

DismissHelp:
Gui,5: Destroy
return

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
Gui,3: Add, Tab,x5 y5 w300 h190,General|Print ;|Import|Export Add these later
Gui,3: Add,Text,x10 y40,On-the-Fly shortcut:
Gui,3: Add,Hotkey,xp+10 yp+20 w100 vsotfhotkey, %otfhotkey%
Gui,3: Add,Text,x150 y40,Hotstring Management shortcut:
Gui,3: Add,Hotkey,xp+10 yp+20 w100 vsmanagehotkey, %managehotkey%
;code optimization -- use mode value to set in initial radio values
CompatMode := NOT MODE
Gui,3: Add,Radio,x10 y100 vModeGroup Checked%CompatMode%,Compatibility mode (Default)
Gui,3: Add,Radio,Checked%MODE%,Clipboard mode (Faster, but less compatible)
IniRead,OnStartup,texter.ini,Settings,Startup
Gui,3: Add,Checkbox, vStartup x20 yp+30 Checked%OnStartup%,Run Texter at start up
IniRead,Update,texter.ini,Settings,UpdateCheck
Gui,3: Add,Checkbox, vUpdate x20 yp+20 Checked%Update%,Check for updates at launch?
Gui,3: Add,Button,x150 y200 w75 GSETTINGSOK Default,&OK
Gui,3: Add,Button,x230 y200 w75 GSETTINGSCANCEL,&Cancel
Gui,3: Tab,2
Gui,3: Add,Button,w150 h150 gPrintableList,Create Printable Texter Cheatsheet
Gui,3: Add,Text,xp+160 y50 w125 Wrap,Click the big button to export a printable cheatsheet of all your Texter hotstrings, replacements, and triggers.
;Gui,3: Tab,3
;Gui,3: Add,Button,x150 y200 w75 GSETTINGSOK Default,&OK
;Gui,3: Add,Button,x230 y200 w75 GSETTINGSCANCEL,&Cancel
Gui,3: Show,AutoSize,Texter Preferences
Hotkey,IfWinActive, Texter Preferences
Hotkey,Esc,SETTINGSCANCEL,On
Hotkey,IfWinActive
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
;code optimization -- calculate MODE from ModeGroup
MODE := ModeGroup - 1
IniWrite,%MODE%,texter.ini,Settings,Mode
IniWrite,%Update%,texter.ini,Settings,UpdateCheck
If Startup = 1
{
	IfNotExist %A_StartMenu%\Programs\Startup\Texter.lnk
		;Get icon for shortcut link:
		;1st from compiled EXE
		if %A_IsCompiled%
		{
			IconLocation=%A_ScriptFullPath%
		}
		;2nd from icon in resources folder
		else IfExist %A_WorkingDir%\resources\texter.ico
		{
			IconLocation=%A_WorkingDir%\resources\texter.ico
		}
		;3rd from the AutoHotkey application itself
		else
		{
			IconLocation=%A_AhkPath%
		}
		;use %A_ScriptFullPath% instead of %A_WorkingDir%\texter.exe
		;to allow compatibility with source version
		FileCreateShortcut,%A_ScriptFullPath%,%A_StartMenu%\Programs\Startup\Texter.lnk,%A_WorkingDir%,,Text replacement system tray application,%IconLocation%
}
else
{
	IfExist %A_StartMenu%\Programs\Startup\Texter.lnk
	{
		FileDelete %A_StartMenu%\Programs\Startup\Texter.lnk
	}
}
IniWrite,%Startup%,texter.ini,Settings,Startup

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
Hotkey,IfWinActive, Texter Management
Hotkey,Esc,PButtonCancel,On
Hotkey,IfWinActive
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
Gui,2: Destroy
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
;code optimization -- removed IfNotExist tests
;redundant when final arg to FileInstall is 0
FileInstall,resources\texter.ico,%A_ScriptDir%\resources\texter.ico,0
FileInstall,resources\replace.wav,%A_ScriptDir%\resources\replace.wav,0
FileInstall,resources\texter48x48.png,%A_ScriptDir%\resources\texter48x48.png,0
return

;AUTOCLOSE:
;:*?B0:(::){Left}
;:*?B0:[::]{Left}
;:*?B0:{::{}}{Left}
;return

PrintableList:
List = <html><head><title>Texter Hotstrings and Replacement Text Cheatsheet</title></head></body><h2>Texter Hostrings and Replacement Text Cheatsheet</h2><table border="1"><th>Hotstring</th><th>Replacement Text</th><th>Trigger(s)</th>
Loop, %A_WorkingDir%\replacements\*.txt
{
	trig =
	hs = %A_LoopFileName%
	StringReplace, hs, hs, .txt
	FileRead, rp, %A_WorkingDir%\replacements\%hs%.txt
	If hs in %EnterKeys%
		trig = Enter
	If hs in %TabKeys%
		trig = %trig% Tab
	If hs in %SpaceKeys%
		trig = %trig% Space
	StringReplace, rp, rp, <,&lt;,All
	StringReplace, rp, rp, >,&gt;,All
	List = %List%<tr><td>%hs%</td><td>%rp%</td><td>%trig%</td></tr>
	
}
List = %List%</table></body></html>
IfExist %A_WorkingDir%\resources\Texter Replacement Guide.html
	FileDelete,%A_WorkingDir%\resources\Texter Replacement Guide.html
FileAppend,%List%, %A_WorkingDir%\resources\Texter Replacement Guide.html
Run,%A_WorkingDir%\resources\Texter Replacement Guide.html
return

UpdateCheck:
update("texter")
return

update(program)
{
	SetTimer, UpdateCheck, Off
	UrlDownloadToFile,http://svn.adampash.com/%program%/CurrentVersion.txt,%A_WorkingDir%\VersionCheck.txt
	if ErrorLevel = 0
	{
		FileReadLine, Latest, %A_WorkingDir%\VersionCheck.txt,1
		IniRead,Current,%program%.ini,Preferences,Version
		if (Latest != Current)
		{
			MsgBox,4,A new version of Texter is available!,Would you like to visit the Texter homepage and download the latest version?
			IfMsgBox,Yes
				Goto,TexterHomepage
		}
		FileDelete,%A_WorkingDir%\VersionCheck.txt ;; delete version check
	}
}
return

EXIT: 
ExitApp 