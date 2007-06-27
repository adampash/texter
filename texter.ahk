; Texter
; Author:         Adam Pash <adam@lifehacker.com>
; Gratefully adapted several ideas from AutoClip by Skrommel:
;		http://www.donationcoder.com/Software/Skrommel/index.html#AutoClip
; Huge thanks to Dustin Luck for his contributions
; Script Function:
;	Designed to implement simple, on-the-fly creation and managment 
;	of auto-replacing hotstrings for repetitive text
;	http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php
SetWorkingDir %A_ScriptDir%
#SingleInstance,Force 
#NoEnv
StringCaseSense On
AutoTrim,off
SetKeyDelay,-1
SetWinDelay,0 
Gosub,UpdateCheck
Gosub,ASSIGNVARS
Gosub,READINI
EnableTriggers(true)
Gosub,RESOURCES
Gosub,TRAYMENU
Gosub,BuildActive
;Gosub,AUTOCLOSE

FileRead, EnterKeys, %EnterCSV%
FileRead, TabKeys, %TabCSV%
FileRead, SpaceKeys, %SpaceCSV%
;Gosub,GetFileList
Goto Start

START:
hotkey = 
executed = false
Input,input,V L99,{SC77}
input:=hexify(input)
IfInString,ActiveList,%input%|
{ ;input matches a hotstring -- see if hotkey matches a trigger for hotstring
	if hotkey in %ignore%
	{
		StringTrimLeft,Bank,hotkey,1
		StringTrimRight,Bank,Bank,1
		Bank = %Bank%Keys
		Bank := %Bank%
		if input in %Bank%
		{
			GoSub, EXECUTE
			executed = true
		}
	}
}
if executed = false
{
	SendInput,%hotkey%
}
Goto,START
return

EXECUTE:
WinGetActiveTitle,thisWindow ; this variable ensures that the active Window is receiving the text, activated before send
;; below added b/c SendMode Play appears not to be supported in Vista 
if (A_OSVersion = "WIN_VISTA") or (Synergy = 1) ;;; need to implement this in the preferences - should work, though
	SendMode Input
else
	SendMode Play   ; Set an option in Preferences to enable for use with Synergy - Use SendMode Input to work with Synergy
if (ExSound = 1)
	SoundPlay, %ReplaceWAV%
ReturnTo := 0
hexInput:=Dehexify(input)
StringLen,BSlength,hexInput
Send, {BS %BSlength%}
FileRead, ReplacementText, %A_ScriptDir%\Active\replacements\%input%.txt
StringLen,ClipLength,ReplacementText

IfInString,ReplacementText,::scr::
{
	;To fix double spacing issue, replace `r`n (return + new line) as AHK sends a new line for each character
	StringReplace,ReplacementText,ReplacementText,`r`n,`n, All
	StringReplace,ReplacementText,ReplacementText,::scr::,,
	IfInString,ReplacementText,`%p
	{
		textPrompt(ReplacementText)
	}
	IfInString,ReplacementText,`%s
	{
		StringReplace, ReplacementText, ReplacementText,`%s(, ¢, All
		Loop,Parse,ReplacementText,¢
		{
			if (A_Index != 1)
			{
				StringGetPos,len,A_LoopField,)
				StringTrimRight,sleepTime,A_LoopField,%len%
				StringMid,thisScript,A_LoopField,(len + 2),
				Sleep,%sleepTime%
				;WinActivate,%thisWindow%  The assumption must be made that in script mode
				; the user can intend to enter text in other windows
				SendInput,%thisScript%
			}
			else
			{
				;WinActivate,%thisWindow%  The assumption must be made that in script mode
				; the user can intend to enter text in other windows
				SendInput,%A_LoopField%
			}
		}
	}
	else
		SendInput,%ReplacementText%
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
	IfInString,ReplacementText,`%p
	{
		textPrompt(ReplacementText)
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
	{
		if ReturnTo > 0
		{
			if ReplacementText contains !,#,^,+,{
			{
				WinActivate,%thisWindow%
				SendRaw, %ReplacementText%
				Send,{Left %ReturnTo%}
			}
			else
			{
				WinActivate,%thisWindow%
				Send,%ReplacementText%{Left %ReturnTo%}
			}
		}
		else
		{
			WinActivate,%thisWindow%
			SendRaw,%ReplacementText%
		}
	}
	else
	{
		oldClip = %Clipboard%
		Clipboard = %ReplacementText%
		if ReturnTo > 0
		{
			WinActivate,%thisWindow%
			Send,^v{Left %ReturnTo%}
		}
		else
		{
			WinActivate,%thisWindow%
			Send,^v
		}
		Clipboard = %oldClip%
	}
;	if ReturnTo > 0
;		Send, {Left %ReturnTo%}
}
SendMode Event
IniRead,expanded,texter.ini,Stats,Expanded
IniRead,chars_saved,texter.ini,Stats,Characters
expanded += 1
chars_saved += ClipLength
IniWrite,%expanded%,texter.ini,Stats,Expanded
IniWrite,%chars_saved%,texter.ini,Stats,Characters
Return

HOTKEYS: 
StringTrimLeft,hotkey,A_ThisHotkey,1 
StringLen,hotkeyl,hotkey 
If hotkeyl>1 
  hotkey=`{%hotkey%`} 
Send,{SC77}
Return 

ASSIGNVARS:
Version = 0.4
EnterCSV = %A_ScriptDir%\Active\bank\enter.csv
TabCSV = %A_ScriptDir%\Active\bank\tab.csv
SpaceCSV = %A_ScriptDir%\Active\bank\space.csv
ReplaceWAV = %A_ScriptDir%\resources\replace.wav
TexterPNG = %A_ScriptDir%\resources\texter.png
TexterICO = %A_ScriptDir%\resources\texter.ico
StyleCSS = %A_ScriptDir%\resources\style.css
return

READINI:
IfNotExist bank
	FileCreateDir, bank
IfNotExist replacements
	FileCreateDir, replacements
else
{
	IniRead,hexified,texter.ini,Settings,Hexified
	if hexified = ERROR
		Gosub,HexAll
}
IfNotExist resources
	FileCreateDir, resources
IfNotExist bundles
	FileCreateDir, bundles
IfNotExist Active
{
	FileCreateDir, Active
	FileCreateDir, Active\replacements
	FileCreateDir, Active\bank
}
IniWrite,%Version%,texter.ini,Preferences,Version
cancel := GetValFromIni("Cancel","Keys","{Escape}") ;keys to stop completion, remember {} 
ignore := GetValFromIni("Ignore","Keys","{Tab}`,{Enter}`,{Space}") ;keys not to send after completion 
IniWrite,{Escape}`,{Tab}`,{Enter}`,{Space}`,{Left}`,{Right}`,{Up}`,{Down},texter.ini,Autocomplete,Keys
keys := GetValFromIni("Autocomplete","Keys","{Escape}`,{Tab}`,{Enter}`,{Space}`,{Left}`,{Right}`,{Esc}`,{Up}`,{Down}")
otfhotkey := GetValFromIni("Hotkey","OntheFly","^+H")
managehotkey := GetValFromIni("Hotkey","Management","^+M")
MODE := GetValFromIni("Settings","Mode",0)
EnterBox := GetValFromIni("Triggers","Enter",0)
TabBox := GetValFromIni("Triggers","Tab",0)
SpaceBox := GetValFromIni("Triggers","Space",0)
ExSound := GetValFromIni("Preferences","ExSound",1)
Synergy := GetValFromIni("Preferences","Synergy",0)

;; Enable hotkeys for creating new keys and managing replacements
if otfhotkey <>
{
	Hotkey,IfWinNotActive,Texter Preferences
	Hotkey,%otfhotkey%,NEWKEY	
	Hotkey,IfWinActive
}
if managehotkey <>
{
	Hotkey,IfWinNotActive,Texter Preferences
	Hotkey,%managehotkey%,MANAGE
	Hotkey,IfWinActive
}


;; This section is intended to exit the input in the Start thread whenever the mouse is clicked or 
;; the user Alt-Tabs to another window so that Texter is prepared
~LButton::Send,{SC77}
$!Tab::
{
	GetKeyState,capsL,Capslock,T
	SetCapsLockState,Off
	pressed = 0
	Loop {
		Sleep,10
		GetKeyState,altKey,Alt,P
		GetKeyState,tabKey,Tab,P
		if (altKey = "D") and (tabKey = "D")
		{
			if pressed = 0
			{
				pressed = 1
				Send,{Alt down}{Tab}
				continue
			}
			else
			{
				continue
			}
		}
		else if (altKey = "D")
		{
			pressed = 0
			continue
		}
		else
		{
			Send,{Alt up}
			break
		}
	}
	Send,{SC77}
	if (capsL = "D")
		SetCapsLockState,On
}

$!+Tab::
{
	GetKeyState,capsL,Capslock,T
	SetCapsLockState,Off
	pressed = 0
	Loop {
		Sleep,10
		GetKeyState,altKey,Alt,P
		GetKeyState,tabKey,Tab,P
		GetKeyState,shiftKey,Shift,P
		if (altKey = "D") and (tabKey = "D") and (shiftKey = "D")
		{
			if pressed = 0
			{
				pressed = 1
				Send,{Alt down}{Shift down}{Tab}
				;Send,{Shift up}
				continue
			}
			else
			{
				continue
			}
		}
		else if (altKey = "D") and (shiftKey != "D")
		{
			pressed = 0
			Send,{Shift up}
			break
		}
		else if (altKey = "D") and (shiftKey = "D")
		{
			pressed = 0
			continue
		}
		else
		{
			Send,{Alt up}{Shift up}
			break
		}
	}
;	Send,{SC77}
	if (capsL = "D")
		SetCapsLockState,On
}
Return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Implementation and GUI for on-the-fly creation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NEWKEY:
if A_GuiControl = + ;;;; MAYBE CHANGE THIS TO IfWinExist,Texter Management
	GuiControlGet,CurrentBundle,,BundleTabs
else
	CurrentBundle =
if (CurrentBundle != "") and (CurrentBundle != "Default")
	AddToDir = Bundles\%CurrentBundle%\
else
	AddToDir = 
Gui,1: Destroy
IniRead,EnterBox,texter.ini,Triggers,Enter
IniRead,TabBox,texter.ini,Triggers,Tab
IniRead,SpaceBox,texter.ini,Triggers,Space
Gui,1: font, s12, Arial  
Gui,1: +owner2 +AlwaysOnTop -SysMenu +ToolWindow  ;suppresses taskbar button, always on top, removes minimize/close
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
Gui,1: Add,Picture,x0 y105,%TexterPNG%
Gui 2:+Disabled
Gui,1: Show, W500 H200,Add new hotstring...
return

GuiEscape:
ButtonCancel:
Gui 2:-Disabled
Gui,1: Destroy
return

ButtonOK:
Gui,1: Submit, NoHide
Gui 1:+OwnDialogs
hexRString:=hexify(RString)
IfExist, %A_ScriptDir%\%AddToDir%replacements\%hexRString%.txt
{
	MsgBox,262144,Hotstring already exists, A replacement with the text %RString% already exists.  Would you like to try again?
	return
}
IsScript := (TextOrScript == "Script")

if SaveHotstring(RString, FullText, IsScript, AddToDir, SpaceCbox, TabCbox, EnterCbox)
{
	Gui 2:-Disabled
	Gui,1: Submit
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
Menu,TRAY,Add,P&references...,PREFERENCES
Menu,TRAY,Add,&Import bundle,IMPORT
Menu,TRAY,Add,&Help,HELP
Menu,TRAY,Add
Menu,TRAY,Add,&About...,ABOUT
Menu,TRAY,Add,&Disable,DISABLE
if disable = 1
	Menu,Tray,Check,&Disable
Menu,TRAY,Add,E&xit,EXIT
Menu,TRAY,Default,&Manage hotstrings
Menu,Tray,Tip,Texter
Menu,TRAY,Icon,resources\texter.ico
Return

ABOUT:
Gui,4: Destroy
Gui,4: +owner2
Gui,4: Add,Picture,x200 y0,%TexterPNG%
Gui,4: font, s36, Courier New
Gui,4: Add, Text,x10 y35,Texter
Gui,4: font, s8, Courier New
Gui,4: Add, Text,x171 y77,%Version%
Gui,4: font, s9, Arial 
Gui,4: Add,Text,x10 y110 Center,Texter is a text replacement utility designed to save`nyou countless keystrokes on repetitive text entry by`nreplacing user-defined abbreviations (or hotstrings)`nwith your frequently-used text snippets.`n`nTexter is written by Adam Pash and distributed`nby Lifehacker under the GNU Public License.`nFor details on how to use Texter, check out the
Gui,4:Font,underline bold
Gui,4:Add,Text,cBlue gHomepage Center x110 y230,Texter homepage
Gui,4: Color,F8FAF0
Gui 2:+Disabled
Gui,4: Show,auto,About Texter
Return

DISABLE:
IniRead,disable,texter.ini,Settings,Disable
if disable = 0
{
	IniWrite,1,texter.ini,Settings,Disable
	EnableTriggers(false)
	Menu,Tray,Check,&Disable
}
else
{
	IniWrite,0,texter.ini,Settings,Disable
	EnableTriggers(true)
	Menu,Tray,Uncheck,&Disable
}
return

Homepage:
Run http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php
return

BasicUse:
Run http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php#basic
return

Scripting:
Run http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php#advanced
return

4GuiClose:
4GuiEscape:
DismissAbout:
Gui 2:-Disabled
Gui,4: Destroy
return

HELP:
Gui,5: Destroy
Gui,5: Add,Picture,x200 y5,%TexterPNG%
Gui,5: font, s36, Courier New
Gui,5: Add, Text,x20 y40,Texter
Gui,5: font, s9, Arial 
Gui,5: Add,Text,x19 y285 w300 center,All of Texter's documentation can be found online at the
Gui,5:Font,underline bold
Gui,5:Add,Text,cBlue gHomepage Center x125 y305,Texter homepage
Gui,5: font, s9 norm, Arial 
Gui,5: Add,Text,x10 y100 w300,For help by topic, click on one of the following:
Gui,5:Font,underline bold
Gui,5:Add,Text,x30 y120 cBlue gBasicUse,Basic Use: 
Gui,5:Font,norm
Gui,5:Add,Text,x50 y140 w280, Covers how to create basic text replacement hotstrings.
Gui,5:Font,underline bold
Gui,5:Add,Text,x30 y180 cBlue gScripting,Sending advanced keystrokes: 
Gui,5:Font,norm
Gui,5:Add,Text,x50 y200 w280, Texter is capable of sending advanced keystrokes, like keyboard combinations.  This section lists all of the special characters used in script creation, and offers a few examples of how you might use scripts.
Gui,5: Color,F8FAF0
Gui,5: Show,auto,Texter Help
Return

5GuiEscape:
DismissHelp:
Gui,5: Destroy
return

GetFileList:
FileList =
Loop, %A_ScriptDir%\replacements\*.txt
{
	thisFile:=Dehexify(A_LoopFileName)
	FileList = %FileList%%thisFile%|
}
StringReplace, FileList, FileList, .txt,,All
return

PREFERENCES:
Gui,3: Destroy
Gui,3: +owner2
Gui,3: Add, Tab,x5 y5 w306 h230,General|Print|Stats ;|Import|Export Add these later
Gui,3: Add,Button,x150 y240 w75 GSETTINGSOK Default,&OK
IniRead,otfhotkey,texter.ini,Hotkey,OntheFly
Gui,3: Add,Text,x10 y40,On-the-Fly shortcut:
Gui,3: Add,Hotkey,xp+10 yp+20 w100 vsotfhotkey, %otfhotkey%
Gui,3: Add,Text,x150 y40,Hotstring Management shortcut:
Gui,3: Add,Hotkey,xp+10 yp+20 w100 vsmanagehotkey, %managehotkey%
;code optimization -- use mode value to set in initial radio values
CompatMode := NOT MODE
Gui,3: Add,Radio,x10 y100 vModeGroup Checked%CompatMode%,Compatibility mode (Default)
Gui,3: Add,Radio,Checked%MODE%,Clipboard mode (Faster, but less compatible)
OnStartup := GetValFromIni(Settings, Startup, false)
Gui,3: Add,Checkbox, vStartup x20 yp+30 Checked%OnStartup%,Run Texter at start up
IniRead,Update,texter.ini,Preferences,UpdateCheck
Gui,3: Add,Checkbox, vUpdate x20 yp+20 Checked%Update%,Check for updates at launch?
IniRead,ExSound,texter.ini,Preferences,ExSound
Gui,3: Add,Checkbox, vExSound x20 yp+20 gToggle Checked%ExSound%,Play sound when replacement triggered?
IniRead,Synergy,texter.ini,Preferences,Synergy
Gui,3: Add,Checkbox, vSynergy x20 yp+20 gToggle Checked%Synergy%,Make Texter compatible across computers with Synergy?
;Gui,3: Add,Button,x150 y200 w75 GSETTINGSOK Default,&OK
Gui,3: Add,Button,x230 y240 w75 GSETTINGSCANCEL,&Cancel
Gui,3: Tab,2
Gui,3: Add,Button,w150 h150 gPrintableList,Create Printable Texter Cheatsheet
Gui,3: Add,Text,xp+160 y50 w125 Wrap,Click the big button to export a printable cheatsheet of all your Texter hotstrings, replacements, and triggers.
Gui,3: Tab,3
Gui,3: Add,Text,x10 y40,Your Texter stats:
IniRead,expanded,texter.ini,Stats,Expanded
Gui,3: Add,Text,x25 y60,Snippets expanded:   %expanded% 
IniRead,chars_saved,texter.ini,Stats,Characters
Gui,3: Add,Text,x25 y80,Characters saved:     %chars_saved%
SetFormat,FLOAT,0.2
time_saved := chars_saved/24000
Gui,3: Add,Text,x25 y100,Hours saved:             %time_saved% (assuming 400 chars/minute)
;Gui,3: Add,Button,x150 y200 w75 GSETTINGSOK Default,&OK
;Gui,3: Add,Button,x230 y200 w75 GSETTINGSCANCEL,&Cancel
Gui 2:+Disabled
Gui,3: Show,AutoSize,Texter Preferences
Return

SETTINGSOK:
Gui,3: Submit, NoHide
If (sotfhotkey != otfhotkey)
{
	otfhotkey:=sotfhotkey
	If otfhotkey<>
	{
	  Hotkey,IfWinNotActive,Texter Preferences
	  Hotkey,%otfhotkey%,Newkey
	  HotKey,%otfhotkey%,On
	  Hotkey,IfWinActive
	}
	IniWrite,%otfhotkey%,texter.ini,Hotkey,OntheFly
}

If (smanagehotkey != managehotkey)
{
	managehotkey:=smanagehotkey
	If managehotkey<>
	{
	  Hotkey,IfWinNotActive,Texter Preferences
	  Hotkey,%managehotkey%,Manage
	  HotKey,%managehotkey%,On
	  Hotkey,IfWinActive
	}
	IniWrite,%managehotkey%,texter.ini,Hotkey,Management
}
;code optimization -- calculate MODE from ModeGroup
MODE := ModeGroup - 1
IniWrite,%MODE%,texter.ini,Settings,Mode
IniWrite,%Update%,texter.ini,Preferences,UpdateCheck
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
		else IfExist %TexterICO%
		{
			IconLocation=%TexterICO%
		}
		;3rd from the AutoHotkey application itself
		else
		{
			IconLocation=%A_AhkPath%
		}
		;use %A_ScriptFullPath% instead of texter.exe
		;to allow compatibility with source version
		FileCreateShortcut,%A_ScriptFullPath%,%A_StartMenu%\Programs\Startup\Texter.lnk,%A_ScriptDir%,,Text replacement system tray application,%IconLocation%
}
else
{
	IfExist %A_StartMenu%\Programs\Startup\Texter.lnk
	{
		FileDelete %A_StartMenu%\Programs\Startup\Texter.lnk
	}
}
IniWrite,%Startup%,texter.ini,Settings,Startup
3GuiClose:
3GuiEscape:
SETTINGSCANCEL:
Gui 2:-Disabled
Gui,3: Destroy

Return

TOGGLE:
GuiControlGet,ToggleValue,,%A_GuiControl%
IniWrite,%ToggleValue%,texter.ini,Preferences,%A_GuiControl%
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Implementation and GUI for management ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MANAGE:
GoSub,GetFileList
Bundles =
Loop,bundles\*,2
{
	Bundles = %Bundles%|%A_LoopFileName%
	thisBundle = %A_LoopFileName%
;	Loop,bundles\%A_LoopFileName%\replacements\*.txt
;	{
;		thisReplacement:=Dehexify(A_LoopFileName)
;		thisBundle = %thisBundle%%thisReplacement%|
;	}
	StringReplace, thisBundle, thisBundle, .txt,,All
	StringReplace, thisBundle, thisBundle, %A_LoopFileName%,,
	%A_LoopFileName% = %thisBundle%
}
StringReplace, FileList, FileList, .txt,,All
StringTrimLeft,Bundles,Bundles,1
Gui,2: Destroy
Gui,2: Default
Gui,2: Font, s12, Arial
Gui,2: Add,Tab,x5 y5 h390 w597 vBundleTabs gListBundle,Default|%Bundles% ;;;;;; START ADDING BUNDLES
Gui,2: Add, Text, Section,
Gui,2: Tab ;;; Every control after this point belongs to no individual tab
Gui,2: Add, Text,ys xs,Hotstring:
Gui,2: Add, ListBox, xs r15 W100 vChoice gShowString Sort, %FileList%
Gui,2: Add, Button, w35 xs+10 GAdd,+
Gui,2: Add, Button, w35 xp+40 GDelete,-
Gui,2: Add, DropDownList, Section ys vTextOrScript, Text||Script
Gui,2: Font, s12, Arial
Gui,2: Add, Edit, r12 W460 xs vFullText
Gui,2: Add, Text, xs,Trigger:
Gui,2: Add, Checkbox, vEnterCbox yp xp+65, Enter
Gui,2: Add, Checkbox, vTabCbox yp xp+65, Tab
Gui,2: Add, Checkbox, vSpaceCbox yp xp+60, Space
Gui,2: Font, s8, Arial
Gui,2: Add,Button, w80 GPButtonSave xs+375 yp, &Save
IniRead,bundleCheck,texter.ini,Bundles,Default
Gui,2: Add, Checkbox, Checked%bundleCheck% vbundleCheck gToggleBundle xs+400 yp+50,Enabled
Gui,2: Add, Button, w80 Default GPButtonOK xs+290 yp+30,&OK
Gui,2: Add, Button, w80 xp+90 GPButtonCancel, &Cancel
Menu, ToolsMenu, Add, P&references..., Preferences
Menu, MgmtMenuBar, Add, &Tools, :ToolsMenu
Menu, BundlesMenu, Add, &Export, Export
Menu, BundlesMenu, Add, &Import, Import
Menu, BundlesMenu, Add, &Add, AddBundle
Menu, BundlesMenu, Add, &Remove, DeleteBundle
Menu, MgmtMenuBar, Add, &Bundles, :BundlesMenu
Menu, HelpMenu, Add, &Basic Use, BasicUse
Menu, HelpMenu, Add, Ad&vanced Use, Scripting
Menu, HelpMenu, Add, &Homepage, Homepage
Menu, HelpMenu, Add, &About..., About
Menu, MgmtMenuBar, Add, &Help, :HelpMenu
Gui,2: Menu, MgmtMenuBar
Gui,2: Show, , Texter Management
Hotkey,IfWinActive, Texter Management
Hotkey,!p,Preferences
Hotkey,delete,Delete
Hotkey,IfWinActive
return

ListBundle:
if A_GuiControl = BundleTabs
	GuiControlGet,CurrentBundle,,BundleTabs
IniRead,bundleCheck,texter.ini,Bundles,%CurrentBundle%
GuiControl,,Choice,|
Loop,bundles\*,2
{
	Bundles = %Bundles%|%A_LoopFileName%
	thisBundle = %A_LoopFileName%
	Loop,bundles\%A_LoopFileName%\replacements\*.txt
	{
		thisReplacement:=Dehexify(A_LoopFileName)
		thisBundle = %thisBundle%%thisReplacement%|
	}
;	StringReplace, thisBundle, thisBundle, .txt,,All
	StringReplace, thisBundle, thisBundle, %A_LoopFileName%,,
	%A_LoopFileName% = %thisBundle%
}
;if A_GuiControl = Tab
;	GuiControl,,Choice,|
;else
;	GuiControl,,Choice,%RString%||
GuiControl,,FullText,
GuiControl,,EnterCbox,0
GuiControl,,TabCbox,0
GuiControl,,SpaceCbox,0
GuiControl,,bundleCheck,%bundleCheck%
if CurrentBundle = Default
{
	Gosub,GetFileList
	CurrentBundle = %FileList%
	GuiControl,,Choice,%CurrentBundle%
}
else
{
	StringTrimLeft,CurrentBundle,%CurrentBundle%,0
	GuiControl,,Choice,%CurrentBundle%
}
return

ToggleBundle:
GuiControlGet,CurrentBundle,,BundleTabs
GuiControlGet,bundleCheck,,bundleCheck
IniWrite,%bundleCheck%,texter.ini,Bundles,%CurrentBundle%
Gosub,BuildActive
return

BuildActive:
activeBundles =
FileDelete,Active\replacements\*
FileDelete,Active\bank\*
Loop,bundles\*,2
{
	IniRead,activeCheck,texter.ini,Bundles,%A_LoopFileName%
	if activeCheck = 1
		activeBundles = %activeBundles%%A_LoopFileName%,
}
IniRead,activeCheck,texter.ini,Bundles,Default
if activeCheck = 1
	activeBundles = %activeBundles%Default
Loop,Parse,activeBundles,CSV
{
;	MsgBox,%A_LoopField%
	if A_LoopField = Default
	{
		FileCopy,replacements\*.txt,Active\replacements
		FileRead,tab,bank\tab.csv
		FileAppend,%tab%,Active\bank\tab.csv
		FileRead,space,bank\space.csv
		FileAppend,%space%,Active\bank\space.csv
		FileRead,enter,bank\enter.csv
		FileAppend,%enter%,Active\bank\enter.csv
	}
	else
	{
		FileCopy,Bundles\%A_LoopField%\replacements\*.txt,active\replacements
		FileRead,tab,Bundles\%A_LoopField%\bank\tab.csv
		FileAppend,%tab%,active\bank\tab.csv
		FileRead,space,Bundles\%A_LoopField%\bank\space.csv
		FileAppend,%space%,active\bank\space.csv
		FileRead,enter,Bundles\%A_LoopField%\bank\enter.csv
		FileAppend,%enter%,active\bank\enter.csv
	}
;		IfExist active\replacements\wc.txt
;			MsgBox,%A_LoopFileName% put me here
}
FileRead, EnterKeys, %A_WorkingDir%\Active\bank\enter.csv
FileRead, TabKeys, %A_WorkingDir%\Active\bank\tab.csv
FileRead, SpaceKeys, %A_WorkingDir%\Active\bank\space.csv
ActiveList =
Loop, Active\replacements\*.txt
{
	ActiveList = %ActiveList%%A_LoopFileName%|
}
StringReplace, ActiveList, ActiveList, .txt,,All

return

ADD:
EnableTriggers(false)
GoSub,Newkey
IfWinExist,Add new hotstring...
{
	WinWaitClose,Add new hotstring...,,
}
;GoSub,GetFileList
GoSub,ListBundle
StringReplace, CurrentBundle, CurrentBundle,|%RString%|,|%RString%||
GuiControl,,Choice,|%CurrentBundle%
EnableTriggers(true)
GoSub,ShowString
return

DELETE:
Gui 2:+OwnDialogs
GuiControlGet,ActiveChoice,,Choice
GuiControlGet,CurrentBundle,,BundleTabs
if (CurrentBundle != "") and (CurrentBundle != "Default")
	RemoveFromDir = Bundles\%CurrentBundle%\
else
	RemoveFromDir = 

MsgBox,1,Confirm Delete,Are you sure you want to delete this hotstring: %ActiveChoice%
IfMsgBox, OK
{
	ActiveChoice:=Hexify(ActiveChoice)
	FileDelete,%A_ScriptDir%\%RemoveFromDir%replacements\%ActiveChoice%.txt
	DelFromBank(ActiveChoice, RemoveFromDir, "enter")
	DelFromBank(ActiveChoice, RemoveFromDir, "tab")
	DelFromBank(ActiveChoice, RemoveFromDir, "space")
	GoSub,ListBundle
	Gosub,BuildActive
	GuiControl,,Choice,|%CurrentBundle%
	GuiControl,,FullText,
	GuiControl,,EnterCbox,0
	GuiControl,,TabCbox,0
	GuiControl,,SpaceCbox,0
}
return

ShowString:
GuiControlGet,ActiveChoice,,Choice
ActiveChoice:=Hexify(ActiveChoice)
GuiControlGet,CurrentBundle,,BundleTabs
if CurrentBundle = Default
	ReadFrom = 
else
	ReadFrom = bundles\%CurrentBundle%\

FileRead,enter,%ReadFrom%bank\enter.csv
FileRead,tab,%ReadFrom%bank\tab.csv
FileRead,space,%ReadFrom%bank\space.csv

if ActiveChoice in %enter%
{
	GuiControl,,EnterCbox,1
}
else
	GuiControl,,EnterCbox,0
if ActiveChoice in %tab%
{
	GuiControl,,TabCbox,1
}
else
	GuiControl,,TabCbox,0
if ActiveChoice in %space%
{
	GuiControl,,SpaceCbox,1
}
else
	GuiControl,,SpaceCbox,0
FileRead, Text, %ReadFrom%replacements\%ActiveChoice%.txt
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
Gui,2: Submit, NoHide
IsScript := (TextOrScript == "Script")

If Choice <>
{
	if (CurrentBundle != "") and (CurrentBundle != "Default")
		SaveToDir = Bundles\%CurrentBundle%\
	else
		SaveToDir = 
	PSaveSuccessful := SaveHotstring(Choice, FullText, IsScript, SaveToDir, SpaceCbox, TabCbox, EnterCbox)
}
else
{
	PSaveSuccessful = true
}
return

2GuiEscape:
PButtonCancel:
Gui,2: Destroy
return

PButtonOK:
Gosub,PButtonSave
if PSaveSuccessful
	Gui,2: Submit
return

AddBundle:
InputBox,BundleName,New Bundle,What would you like to call your bundle?,,150,138,,,
if ErrorLevel
	return
else
{
	IfExist bundles\%BundleName%
		MsgBox,,Bundle already in use,%BundleName% bundle already exists.`nChoose another name or delete the current %BundleName% bundle.
	else
	{
		FileCreateDir,bundles\%BundleName%
		FileCreateDir,bundles\%BundleName%\replacements
		FileCreateDir,bundles\%BundleName%\bank
		IniWrite,1,texter.ini,Bundles,%BundleName%
		Bundles =
		Loop,bundles\*,2
		{
			Bundles = %Bundles%|%A_LoopFileName%
			;thisBundle = %A_LoopFileName%
			if BundleName = %A_LoopFileName%
				Bundles = %Bundles%|
		}
		GuiControl,,BundleTabs,|Default|%Bundles%
		GuiControl,,Choice,|
	}
}
return

DeleteBundle:
GuiControlGet,CurrentBundle,,BundleTabs
if CurrentBundle = Default
{
	MsgBox,You can't remove the Default bundle.
	return
}
MsgBox,4,Confirm bundle delete,Are you sure you want to remove the %CurrentBundle% bundle?
IfMsgBox, Yes
{
	FileRemoveDir,bundles\%CurrentBundle%,1
	Bundles =
	Loop,bundles\*,2
	{
		Bundles = %Bundles%|%A_LoopFileName%
	}
	GuiControl,,BundleTabs,|Default|%Bundles%
	Gosub,GetFileList
	GuiControl,,Choice,%FileList%
}
return

EXPORT:
GuiControlGet,CurrentBundle,,BundleTabs
MsgBox,4,Confirm Bundle Export,Are you sure you want to export the %CurrentBundle% bundle?
IfMsgBox, Yes
{
	IfNotExist %A_WorkingDir%\Texter Export
		FileCreateDir,%A_WorkingDir%\Texter Exports
	IniWrite,%CurrentBundle%,Texter Exports\%CurrentBundle%.texter,Info,Name
	if (CurrentBundle = "Default")
		BundleDir = 
	else
		BundleDir = bundles\%CurrentBundle%\
	Loop,%BundleDir%replacements\*,0
	{
		FileRead,replacement,%A_LoopFileFullPath%
		IfInString,replacement,`r`n
			StringReplace,replacement,replacement,`r`n,`%bundlebreak,All
		IniWrite,%A_LoopFileName%,Texter Exports\%CurrentBundle%.texter,%A_Index%,Hotstring
		IniWrite,%replacement%,Texter Exports\%CurrentBundle%.texter,%A_Index%,Replacement
	}
	MsgBox,4,Your bundle was successfully created!,Congratulations, your bundle was successfully exported!`nYou can now share your bundle with the world by sending them the %CurrentBundle%.texter file.`nThey can add it to Texter through the import feature. `n`nWould you like to see the %CurrentBundle% bundle?
IfMsgBox, Yes
	Run,Texter Exports\
}

return

IMPORT:
FileSelectFile, ImportBundle,,, Import Texter bundle, *.texter
if ErrorLevel = 0
{
	IniRead,BundleName,%ImportBundle%,Info,Name
	IfExist bundles\%BundleName%
	{
		MsgBox,4,%BundleName% bundle already installed,%BundleName% bundle already installed.`nWould you like to overwrite previous %BundleName% bundle?
		IfMsgBox, No
			return
		else
		{
			FileRemoveDir,bundles\%BundleName%,1
		}
	}
	FileCreateDir,bundles\%BundleName%
	FileCreateDir,bundles\%BundleName%\replacements
	FileCreateDir,bundles\%BundleName%\bank
	
	Loop
	{
		IniRead,file,%ImportBundle%,%A_Index%,Hotstring
		IniRead,replacement,%ImportBundle%,%A_Index%,Replacement
		StringReplace, hotstring, file, .txt
		StringReplace,replacement,replacement,`%bundlebreak,`r`n,All
		bundleCollection = %hotstring%,%bundleCollection%
		if file = ERROR
				break
		else
			FileAppend,%replacement%,bundles\%BundleName%\replacements\%file%
	}
	Gui, 8: Add, Text, Section x10 y10,What triggers would you like to use with the %BundleName% bundle?
	Gui,8: Add, Checkbox, vEnterCbox x30, Enter
	Gui,8: Add, Checkbox, vTabCbox yp xp+65, Tab
	Gui,8: Add, Checkbox, vSpaceCbox yp xp+60, Space
	Gui,8: Add,Button, x180 Default w80 GCreateBank,&OK
	Gui, 8: Show,,Set default triggers
}
else
	Msgbox,Error
return

CreateBank:
Gui,8: Submit
Gui,8: Destroy
if EnterCbox = 1
	FileAppend,%bundleCollection%,bundles\%BundleName%\bank\enter.csv
if TabCbox = 1
	FileAppend,%bundleCollection%,bundles\%BundleName%\bank\tab.csv
if SpaceCbox = 1
	FileAppend,%bundleCollection%,bundles\%BundleName%\bank\space.csv
MsgBox,4,Enable %BundleName% bundle?,Would you like to enable the %BundleName% bundle?
IfMsgBox,Yes
{
	IniWrite,1,texter.ini,Bundles,%BundleName%
	Gosub,BuildActive
}
else
	IniWrite,0,texter.ini,Bundles,%BundleName%
return

;; method written by Dustin Luck for writing to ini
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

SaveHotstring(HotString, Replacement, IsScript, Bundle, SpaceIsTrigger, TabIsTrigger, EnterIsTrigger)
{
global EnterCSV
global TabCSV
global SpaceCSV
global EnterKeys
global TabKeys
global SpaceKeys
	HotString:=Hexify(HotString)
	successful := false
	if (!EnterIsTrigger AND !TabIsTrigger AND !SpaceIsTrigger)
	{
		MsgBox,262144,Choose a trigger,You need to choose a trigger in order to save a hotstring replacement.
	}
	else if (HotString <> "" AND Replacement <> "")
	{
		successful := true
		if IsScript
		{
			Replacement = ::scr::%Replacement%
		}

		IniWrite,%SpaceIsTrigger%,texter.ini,Triggers,Space
		IniWrite,%TabIsTrigger%,texter.ini,Triggers,Tab
		IniWrite,%EnterIsTrigger%,texter.ini,Triggers,Enter

		FileDelete, %A_ScriptDir%\%Bundle%replacements\%HotString%.txt
		FileAppend,%Replacement%,%A_ScriptDir%\%Bundle%replacements\%HotString%.txt

		if EnterIsTrigger
		{
			AddToBank(HotString, Bundle, "enter")
		}
		else
		{
			DelFromBank(HotString, Bundle, "enter")
		}
		if TabIsTrigger
		{
			AddToBank(HotString, Bundle, "tab")
		}
		else
		{
			DelFromBank(HotString, Bundle, "tab")
		}
		if SpaceIsTrigger
		{
			AddToBank(HotString, Bundle, "space")
		}
		else
		{
			DelFromBank(HotString, Bundle, "space")
		}
	}
	GoSub,BuildActive
	return successful
}

AddToBank(HotString, Bundle, Trigger)
{
	;HotString:=Dehexify(HotString)
	BankFile = %Bundle%bank\%trigger%.csv
	FileRead, Bank, %BankFile%
	if HotString not in %Bank%
	{
		FileAppend,%HotString%`,, %BankFile%
		FileRead, Bank, %BankFile%
	}
}

DelFromBank(HotString, Bundle, Trigger)
{
	BankFile = %Bundle%bank\%trigger%.csv
	FileRead, Bank, %BankFile%
	;HotString:=Dehexify(HotString)
	if HotString in %Bank%
	{
		StringReplace, Bank, Bank, %HotString%`,,,All
		FileDelete, %BankFile%
		FileAppend,%Bank%, %BankFile%
	}
}

EnableTriggers(doEnable)
{
global keys
	StringReplace,tempKeys,keys,`}`,`{,`n,All
	Loop,Parse,TempKeys,`n,`{`} 
	{
		if (doEnable)
		{
			Hotkey,IfWinNotActive,Enter desired text
			Hotkey,$%A_LoopField%,HOTKEYS
			Hotkey,$%A_LoopField%,On
			Hotkey,IfWinActive
		}
		else
		{
			Hotkey,IfWinNotActive,Enter desired text
			Hotkey,$%A_LoopField%,Off
			Hotkey,IfWinActive
		}
	}
}

RESOURCES:
;code optimization -- removed IfNotExist tests
;redundant when final arg to FileInstall is 0
FileInstall,resources\texter.ico,%TexterICO%,1
FileInstall,resources\replace.wav,%ReplaceWAV%,0
FileInstall,resources\texter.png,%TexterPNG%,1
FileInstall,resources\style.css,%StyleCSS%,0
return

;AUTOCLOSE:
;:*?B0:(::){Left}
;:*?B0:[::]{Left}
;:*?B0:{::{}}{Left}
;return

PrintableList:
alt := 0
List = <html xmlns="http://www.w3.org/1999/xhtml"><head><link type="text/css" href="style.css" rel="stylesheet"><title>Texter Hotstrings and Replacement Text Cheatsheet</title></head><body><h2>Texter Hostrings and Replacement Text Cheatsheet</h2><span class="hotstring" style="border:none`; color:black`;"><h3>Hotstring</h3></span><span class="replacement" style="border:none`;"><h3>Replacement Text</h3></span><span class="trigger" style="border:none`;"><h3>Trigger(s)</h3></span>
Loop, replacements\*.txt
{
	alt := 1 - alt
	trig =
	hs = %A_LoopFileName%
	StringReplace, hs, hs, .txt
	FileRead, rp, replacements\%hs%.txt
	If hs in %EnterKeys%
		trig = Enter
	If hs in %TabKeys%
		trig = %trig% Tab
	If hs in %SpaceKeys%
		trig = %trig% Space
	StringReplace, rp, rp, <,&lt;,All
	StringReplace, rp, rp, >,&gt;,All
	List = %List%<div class="row%alt%"><span class="hotstring">%hs%</span><span class="replacement">%rp%</span><span class="trigger">%trig%</span></div><br />
	
}
List = %List%</body></html>
IfExist resources\Texter Replacement Guide.html
	FileDelete,resources\Texter Replacement Guide.html
FileAppend,%List%, resources\Texter Replacement Guide.html
Run,resources\Texter Replacement Guide.html
return

UpdateCheck: ;;;;;;; Update the version number on each new release ;;;;;;;;;;;;;
IfNotExist texter.ini 
{
	MsgBox,4,Check for Updates?,Would you like to automatically check for updates when on startup?
	IfMsgBox,Yes
		updatereply = 1
	else
		updatereply = 0
}
update := GetValFromIni("Preferences","UpdateCheck",updatereply)
IniWrite,%Version%,texter.ini,Preferences,Version
if (update = 1)
	SetTimer,RunUpdateCheck,10000
return

RunUpdateCheck:
update("texter")
return

update(program) {
	SetTimer, RunUpdateCheck, Off
	UrlDownloadToFile,http://svn.adampash.com/%program%/CurrentVersion.txt,VersionCheck.txt
	if ErrorLevel = 0
	{
		FileReadLine, Latest, VersionCheck.txt,1
		IniRead,Current,%program%.ini,Preferences,Version
		;MsgBox,Latest: %Latest% `n Current: %Current%
		if (Latest > Current)
		{
			MsgBox,4,A new version of %program% is available!,Would you like to visit the %program% homepage and download the latest version?
			IfMsgBox,Yes
				Goto,Homepage
		}
		FileDelete,VersionCheck.txt ;; delete version check
	}
}

textPrompt(thisText) {
	Gui,7: Add,Text,x5 y5, Enter the text you want to insert:
	Gui,7: Add,Edit,x20 y25 r1 vpromptText
	Gui,7: Add,Text,x5 y50,Your text will be replace the `%p variable:
	Gui,7: Add,Text,w300 Wrap x20 y70,%thisText%
	Gui,7: Show,auto,Enter desired text
	Hotkey,IfWinActive,Enter desired text
	Hotkey,Enter,SubmitPrompt
	;Hotkey,Space,
	WinWaitClose,Enter desired text
}
return

SubmitPrompt:
Gui, 7: Submit
Gui, 7: Destroy
StringReplace,ReplacementText,ReplacementText,`%p,%promptText%
return


HexAll:
;MsgBox,Hexing time!
Loop, %A_ScriptDir%\replacements\*.txt
{
	StringReplace, thisFile, A_LoopFileName, .txt,,All
	thisFile:=Hexify(thisFile)
	;MsgBox,% thisFile
	FileMove,%A_ScriptDir%\replacements\%A_LoopFileName%,%A_ScriptDir%\replacements\%thisFile%.txt
}
Loop, %A_ScriptDir%\bank\*.csv
{
	FileRead,thisBank,%A_ScriptDir%\bank\%A_LoopFileName%
	Loop,Parse,thisBank,CSV
	{
		thisString:=Hexify(A_LoopField)

		hexBank = %hexBank%%thisString%,
	}
	FileDelete,%A_ScriptDir%\bank\%A_LoopFileName%
	FileAppend,%hexBank%,%A_ScriptDir%\bank\%A_LoopFileName%
}
;TODO: Also hexify .csv files

IniWrite,1,texter.ini,Settings,Hexified
return

Hexify(x) ;Stolen from Autoclip/Laszlo 
{ 
  StringLen,len,x 
  format=%A_FormatInteger% 
  SetFormat,Integer,Hex 
  hex= 
  Loop,%len% 
  { 
    Transform,y,Asc,%x% 
    StringTrimLeft,y,y,2 
    hex=%hex%%y% 
    StringTrimLeft,x,x,1 
  } 
  SetFormat,Integer,%format% 
  Return,hex
} 

DeHexify(x) 
{ 
   StringLen,len,x 
   ;len:=(len-4)/2 
   string= 
   Loop,%len% 
   { 
      StringLeft,hex,x,2
      hex=0x%hex% 
      Transform,y,Chr,%hex% 
      string=%string%%y% 
      StringTrimLeft,x,x,2 
   } 
   Return,string 
} 


EXIT: 
ExitApp 