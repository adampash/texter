PREFERENCES:
Gui,3: Destroy
Gui,3: +owner
Gui,3: Add, Tab,x5 y5 w306 h280 vTabs,General|Print|Stats ;|Import|Export Add these later
IniRead,otfhotkey,texter.ini,Hotkey,OntheFly
Gui,3: Add,Text,x10 y40,On-the-Fly shortcut:
Gui,3: Add,Hotkey,xp+10 yp+20 w100 vsotfhotkey, %otfhotkey%
Gui,3: Add,Text,x150 y40,Hotstring Management shortcut:
IniRead,managehotkey,texter.ini,Hotkey,Management
Gui,3: Add,Hotkey,xp+10 yp+20 w100 vsmanagehotkey, %managehotkey%
Gui,3: Add,Text,x10 yp+25,Global disable shortcut:
IniRead,disablehotkey,texter.ini,Hotkey,Disable
Gui,3: Add,Hotkey,xp+10 yp+20 w100 vdisablehotkey,%disablehotkey%
;code optimization -- use mode value to set in initial radio values
CompatMode := NOT MODE
Gui,3: Add,Radio,x10 yp+30 vModeGroup Checked%CompatMode%,Compatibility mode (Default)
Gui,3: Add,Radio,Checked%MODE%,Clipboard mode (Faster, but less compatible)
OnStartup := GetValFromIni(Settings, Startup, false)
Gui,3: Add,Checkbox, vStartup x20 yp+30 Checked%OnStartup%,Run Texter at start up
IniRead,Update,texter.ini,Preferences,UpdateCheck
Gui,3: Add,Checkbox, vUpdate x20 yp+20 Checked%Update%,Check for updates at launch?
IniRead,AutoCorrect,texter.ini,Preferences,AutoCorrect
Gui,3: Add,Checkbox, vAutoCorrect x20 yp+20 gToggle Checked%AutoCorrect%,Enable Universal Spelling AutoCorrect?
IniRead,ExSound,texter.ini,Preferences,ExSound
Gui,3: Add,Checkbox, vExSound x20 yp+20 gToggle Checked%ExSound%,Play sound when replacement triggered?
IniRead,Synergy,texter.ini,Preferences,Synergy
Gui,3: Add,Checkbox, vSynergy x20 yp+20 gToggle Checked%Synergy%,Make Texter compatible across computers with Synergy?
;Gui,3: Add,Button,x150 y200 w75 GSETTINGSOK Default,&OK
Gui,3: Add,Button,x150 yp+30 w75 GSETTINGSOK Default,&OK
Gui,3: Add,Button,x230 yp w75 GSETTINGSCANCEL,&Cancel
Gui,3: Tab,2
Gui,3: Add,Button,w150 h150 gPrintableList,Create Printable Texter Cheatsheet
Gui,3: Add,Text,xp+160 y50 w125 Wrap,Click the big button to export a printable cheatsheet of all your Texter hotstrings, replacements, and triggers.
Gui,3: Tab,3
Gui,3: Add,Text,x10 y40,Your Texter stats:
IniRead,expanded,texter.ini,Stats,Expanded
if expanded = ERROR
{
	expanded = 0
}
Gui,3: Add,Text,x25 y60,Snippets expanded:   %expanded% 
IniRead,chars_saved,texter.ini,Stats,Characters
if chars_saved = ERROR
{
	chars_saved = 0
}
Gui,3: Add,Text,x25 y80,Characters saved:     %chars_saved%
SetFormat,FLOAT,0.2
time_saved := chars_saved/24000
Gui,3: Add,Text,x25 y100,Hours saved:             %time_saved% (assuming 400 chars/minute)
;Gui,3: Add,Button,x150 y200 w75 GSETTINGSOK Default,&OK
;Gui,3: Add,Button,x230 y200 w75 GSETTINGSCANCEL,&Cancel
Gui 2:+Disabled
Gui,3: Show,,Texter Preferences
GuiControl,3: Focus, Tabs
Disable=1
WinWaitClose, Texter Preferences
Disable=
Return

SETTINGSOK:
Gui,3: Submit, NoHide
If (sotfhotkey != otfhotkey)
{
    if otfhotkey <> ; disable old hotkey
	{
		Hotkey,IfWinNotActive,Texter Preferences
		Hotkey, %otfhotkey%,Off
		Hotkey,IfWinActive
	}
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
IniWrite,%disablehotkey%,texter.ini,Hotkey,Disable
if disablehotkey <>
{
	Hotkey,IfWinNotActive,Texter Preferences
	Hotkey,%disablehotkey%,DISABLE
	Hotkey,IfWinActive
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