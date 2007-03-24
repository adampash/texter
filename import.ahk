; Mostly complete - just need to do a bit of testing,
; then set up for actual import/append to .csv files


#SingleInstance,Force 
#NoEnv
SetWorkingDir, "%A_ScriptDir%"
FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
Gosub,Import

return


IMPORT:
FileSelectFolder,ImportFrom,,,Select the Texter import folder
Gosub,GetFileList
Loop,%ImportFrom%\*.txt
{
	;StringReplace,A_LoopField,A_LoopField,.txt,,
	;rp_import = %rp_import%%A_LoopField%
	MsgBox,%A_LoopFileFullPath%
	FileCreateDir,%A_WorkingDir%\Import
	FileCopy,%A_LoopFileFullPath%,%A_WorkingDir%\Import
	
}
FileRead, ImportEnter, %ImportFrom%\enter.csv
FileRead, ImportTab, %ImportFrom%\tab.csv
FileRead, ImportSpace, %ImportFrom%\space.csv
Loop,Parse,ImportEnter,|
{
	if A_LoopField not in %EnterKeys%
		FileAppend,%A_LoopField%`,,%A_WorkingDir%\Import\enter.csv
}
Loop,Parse,ImportTab,|
{
	if A_LoopField not in %TabKeys%
		FileAppend,%A_LoopField%`,,%A_WorkingDir%\Import\tab.csv

}
Loop,Parse,ImportSpace,|
{
	if A_LoopField not in %SpaceKeys%
		FileAppend,%A_LoopField%`,,%A_WorkingDir%\Import\space.csv
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