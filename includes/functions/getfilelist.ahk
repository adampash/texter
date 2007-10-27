GetFileList:
FileList =
Loop, %A_ScriptDir%\replacements\*.txt
{
	if A_Index = 1
	{
		thisFile:=Dehexify(A_LoopFileName)
		FileList = |%thisFile%|
		;MakeActive = %thisFile%
	}
	else
	{
		thisFile:=Dehexify(A_LoopFileName)
		FileList = %FileList%%thisFile%|
	}
}
CurrentBundle = Default
StringReplace, FileList, FileList, .txt,,All
return