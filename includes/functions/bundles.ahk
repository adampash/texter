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
Gosub,ListBundle
return