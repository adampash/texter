GetFileList:
FileList =
Loop, %A_ScriptDir%\replacements\*.txt
{
	thisFile:=Dehexify(A_LoopFileName)
	FileList = %FileList%%thisFile%|
}
StringReplace, FileList, FileList, .txt,,All
return