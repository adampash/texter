#SingleInstance,Force 
#NoEnv
SetWorkingDir, "%A_ScriptDir%"
FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
Gosub,Export

return


EXPORT:
GoSub,GetFileList
StringReplace, FileList, FileList, .txt,,All
Gui,5: Destroy
Gui,5: font, s12, Arial  
Gui,5: Add, Text,x15 y20, Hotstring:
Gui,5: Add, ListBox, 0x8 x13 y40 r15 W100 vExportChoice gShowString Sort,%FileList%
Gui,5: Add, Button,w80 default GExportOK x420 yp+80,&Export
Gui,5: Show, W600 H400, Texter Management
return

ExportOK:
Gui,Submit
IfNotExist %A_WorkingDir%\Texter Export
	FileCreateDir,%A_WorkingDir%\Texter Export
Loop,Parse,ExportChoice,|
{
	FileCopy,%A_WorkingDir%\replacements\%A_LoopField%.txt,%A_WorkingDir%\Texter Export\%A_LoopField%.txt
	if A_LoopField in %EnterKeys%
		FileAppend,%A_LoopField%`,,%A_WorkingDir%\Texter Export\enter.csv
	if A_LoopField in %TabKeys%
		FileAppend,%A_LoopField%`,,%A_WorkingDir%\Texter Export\tab.csv
	if A_LoopField in %SpaceKeys%
		FileAppend,%A_LoopField%`,,%A_WorkingDir%\Texter Export\space.csv
}

return

GetFileList:
FileList =
Loop, %A_WorkingDir%\replacements\*.txt
{
	FileList = %FileList%%A_LoopFileName%|
}
StringReplace, FileList, FileList, .txt,,All
return

ShowString:

return