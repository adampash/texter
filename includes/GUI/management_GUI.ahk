;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Implementation and GUI for management ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MAINWINTOOLBAR:
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
return

MANAGE:
Gui,2: Destroy
Gosub,MAINWINTOOLBAR
GoSub,GetFileList
Bundles =
Loop,bundles\*,2
{
	thisBundle = %A_LoopFileName%
	if (thisBundle != "Autocorrect")
	{
		Bundles = %Bundles%|%A_LoopFileName%
;	Loop,bundles\%A_LoopFileName%\replacements\*.txt
;	{
;		thisReplacement:=Dehexify(A_LoopFileName)
;		thisBundle = %thisBundle%%thisReplacement%|
;	}
		StringReplace, thisBundle, thisBundle, .txt,,All
		StringReplace, thisBundle, thisBundle, %A_LoopFileName%,,
		%A_LoopFileName% = %thisBundle%
	}
}
StringReplace, FileList, FileList, .txt,,All
StringTrimLeft,Bundles,Bundles,1
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
Gui,2: Add, Checkbox, gDisableChecks vEnterCbox yp xp+65, Enter
Gui,2: Add, Checkbox, gDisableChecks vTabCbox yp xp+65, Tab
Gui,2: Add, Checkbox, gDisableChecks vSpaceCbox yp xp+60, Space
Gui,2: Add, Checkbox, gDisableChecks vNoTrigCbox yp xp+80, Instant
Gui,2: Font, s8, Arial
Gui,2: Add,Button, w80 GPButtonSave xs+375 yp, &Save
IniRead,bundleCheck,texter.ini,Bundles,Default
Gui,2: Add, Checkbox, Checked%bundleCheck% vbundleCheck gToggleBundle xs+400 yp+50,Enabled
Gui,2: Add, Button, w80 Default GPButtonOK xs+290 yp+30,&OK
Gui,2: Add, Button, w80 xp+90 GPButtonCancel, &Cancel
Gui,2: Show, , Texter Management
GuiControl,2: Focus, Choice
Hotkey,IfWinActive, Texter Management
Hotkey,!p,Preferences
;Hotkey,delete,Delete
Hotkey,^s,PButtonSave
Hotkey,IfWinActive
return

ListBundle:
if A_GuiControl = BundleTabs
	GuiControlGet,CurrentBundle,2:,BundleTabs
IniRead,bundleCheck,texter.ini,Bundles,%CurrentBundle%
GuiControl,2:,Choice,|
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
GuiControl,2:,FullText,
GuiControl,2:,EnterCbox,0
GuiControl,2:,TabCbox,0
GuiControl,2:,SpaceCbox,0
GuiControl,2:,bundleCheck,%bundleCheck%
if CurrentBundle = Default
{
	Gosub,GetFileList
	CurrentBundle = %FileList%
	GuiControl,,Choice,%CurrentBundle%
}
else
{
	StringTrimLeft,CurrentBundle,%CurrentBundle%,0
	GuiControl,2:,Choice,%CurrentBundle%
}
return

ToggleBundle:
GuiControlGet,CurrentBundle,,BundleTabs
GuiControlGet,bundleCheck,,bundleCheck
IniWrite,%bundleCheck%,texter.ini,Bundles,%CurrentBundle%
Gosub,BuildActive
return

ADD:
;EnableTriggers(false)
GoSub,Newkey
IfWinExist,Add new hotstring...
{
	WinWaitClose,Add new hotstring...,,
}
;GoSub,GetFileList
GoSub,ListBundle
StringReplace, CurrentBundle, CurrentBundle,|%RString%|,|%RString%||
GuiControl,,Choice,|%CurrentBundle%
;EnableTriggers(true)
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
FileRead,notrig,%ReadFrom%bank\notrig.csv

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
if ActiveChoice in %notrig%
{
	GuiControl,,NoTrigCbox,1
}
else
	GuiControl,,NoTrigCbox,0
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
	PSaveSuccessful := SaveHotstring(Choice, FullText, IsScript, SaveToDir, SpaceCbox, TabCbox, EnterCbox, NoTrigCbox)
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
{
	Gui,2: Submit
	Gui,2: Destroy
}
return
