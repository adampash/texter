;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Implementation and GUI for on-the-fly creation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NEWKEY:
Bundles=
Loop,bundles\*,2
{
	thisBundle = %A_LoopFileName%
	if (thisBundle != "Autocorrect")
	{
		Bundles = %Bundles%%A_LoopFileName%|
		StringReplace, thisBundle, thisBundle, .txt,,All
		StringReplace, thisBundle, thisBundle, %A_LoopFileName%,,
		%A_LoopFileName% = %thisBundle%
	}
}
if A_GuiControl = + ;;;; MAYBE CHANGE THIS TO IfWinExist,Texter Management
{
	GuiControlGet,CurrentBundle,,BundleTabs
	StringReplace,Bundles,Bundles,%CurrentBundle%,$
	StringSplit,Bundles,Bundles,$
;	MsgBox,%Bundles1% %Bundles2%
;	msgbox %currentbundle%
;	msgbox,%bundles2%
	Bundles = %Bundles1%%CurrentBundle%|%Bundles2%
}
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
IniRead,NoTrigBox,texter.ini,Triggers,NoTrig
Gui,1: font, s12, Arial  
Gui,1: +owner2 +AlwaysOnTop -SysMenu +ToolWindow  ;suppresses taskbar button, always on top, removes minimize/close
Gui,1: Add, Text,x10 y20, Hotstring:
Gui,1: Add, Edit, x13 y45 r1 W65 vRString,
Gui,1: Add, Edit, x100 y45 r4 W395 vFullText, Enter your replacement text here...
Gui,1: Add, Text,x115,Trigger:
Gui,1: Add, Checkbox, gDisableChecks vEnterCbox yp x175 Checked%EnterBox%, Enter
Gui,1: Add, Checkbox, gDisableChecks vTabCbox yp x242 Checked%TabBox%, Tab
Gui,1: Add, Checkbox, gDisableChecks vSpaceCbox yp x305 Checked%SpaceBox%, Space
Gui,1: Add, Checkbox, gDisableChecks vNoTrigCbox yp x388 Checked%NoTrigBox%, Instant
Gui,1: font, s8, Arial 
Gui,1: Add, Button,w80 x320 default,&OK
Gui,1: Add, Button,w80 xp+90 GButtonCancel,&Cancel
Gui,1: font, s12, Arial  
Gui,1: Add,DropDownList,x100 y15 w100 vTextOrScript, Text||Script
Gui,1: Add, Text,x315 y19, Bundle:
Gui,1: Add,DropDownList,x370 y15 w125 vBundle,Default||%Bundles%
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
if (Bundle != "") and (Bundle != "Default")
	AddToDir = Bundles\%Bundle%\
IfExist, %A_ScriptDir%\%AddToDir%replacements\%hexRString%.txt
{
	MsgBox,262144,Hotstring already exists, A replacement with the text %RString% already exists.  Would you like to try again?
	return
}
IsScript := (TextOrScript == "Script")
if SaveHotstring(RString, FullText, IsScript, AddToDir, SpaceCbox, TabCbox, EnterCbox, NoTrigCbox)
{
	Gui 2:-Disabled
	Gui,1: Submit
}
Gosub,GetFileList
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Implementation and GUI for on-the-fly creation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
