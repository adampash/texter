AddBundle:
EnableTriggers(false)
Hotkey,IfWinActive,New Bundle
Hotkey,Space,NOSPACE
Hotkey,IfWinActive
InputBox,BundleName,New Bundle,What would you like to call your bundle? (no spaces),,160,150,,,
if ErrorLevel
{
	EnableTriggers(true)
	return
}
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
EnableTriggers(true)
return

NOSPACE:
Msgbox,0,Oops...,Whoops... Bundle names must not have any spaces.
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
	FileDelete,Texter Exports\%CurrentBundle%.texter
	FileAppend,%CurrentBundle%`n,Texter Exports\%CurrentBundle%.texter
	if (CurrentBundle = "Default")
		BundleDir = 
	else
		BundleDir = bundles\%CurrentBundle%\
	Loop,%BundleDir%replacements\*,0
	{
		FileRead,replacement,%A_LoopFileFullPath%
		IfInString,replacement,`r`n
			StringReplace,replacement,replacement,`r`n,`%bundlebreak,All
		FileAppend,%A_LoopFileName%`n,Texter Exports\%CurrentBundle%.texter
		FileAppend,%replacement%`n,Texter Exports\%CurrentBundle%.texter
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
	FileReadLine, BundleName, %ImportBundle%, 1
	InputBox, BundleName, Bundle Name, What would you like to call this bundle?,,,,,,,,%BundleName%
	BundleDir = bundles\%BundleName%
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
	if (BundleName = "Default")
	{
	  MsgBox,4,%BundleName% bundle already exitsts,%BundleName% bundle already installed.`nWould you like to overwrite previous %BundleName% bundle?
	  IfMsgBox, No
	  BundleDir= 
	  	return
	}
	if BundleDir <>
	{
	  FileCreateDir,%BundleDir%
	  FileCreateDir,%BundleDir%\replacements
	  FileCreateDir,%BundleDir%\bank
	}
	LineSwitch := 0
	Loop, Read, %ImportBundle%
	{
	  if (A_Index = 1)
	  {
		continue
	  }
	  if (LineSwitch = 0)
	  {
	    LineSwitch := 1 - LineSwitch
		FileName = %A_LoopReadLine%
		StringReplace, Hotstring, FileName, .txt
		bundleCollection = %Hotstring%,%bundleCollection%
	  }
	  else
	  {
	    LineSwitch := 1 - LineSwitch
		StringReplace,Replacement, A_LoopReadLine,`%bundlebreak,`r`n,All
		FileAppend, %Replacement%, %BundleDir%\replacements\%FileName%
		FileName=
		Replacement=
		}
	}
	Gui, 8: Add, Text, Section x10 y10,What triggers would you like to use with the %BundleName% bundle?
	Gui,8: Add, Checkbox, vEnterCbox x30, Enter
	Gui,8: Add, Checkbox, vTabCbox yp xp+65, Tab
	Gui,8: Add, Checkbox, vSpaceCbox yp xp+60, Space
	Gui,8: Add,Button, x180 Default w80 GCreateBank,&OK
	Gui, 8: Show,,Set default triggers
}
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
Bundles =
Loop,bundles\*,2
{
	Bundles = %Bundles%%A_LoopFileName%|
	;thisBundle = %A_LoopFileName%
	if BundleName = %A_LoopFileName%
		Bundles = %Bundles%|
}
GuiControl,2:,BundleTabs,|Default|%Bundles%
CurrentBundle = %BundleName%
Gosub,ListBundle
return