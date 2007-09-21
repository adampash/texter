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
