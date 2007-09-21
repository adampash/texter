HexAll:
;MsgBox,Hexing time!
FileCopyDir,replacements,resources\backup\replacements
FileCopyDir,bank,resources\backup\bank
Loop, %A_ScriptDir%\replacements\*.txt
{
	StringReplace, thisFile, A_LoopFileName, .txt,,All
	thisFile:=Hexify(thisFile)
	;MsgBox,% thisFile
	FileMove,%A_ScriptDir%\replacements\%A_LoopFileName%,%A_ScriptDir%\replacements\%thisFile%.txt
}
Loop, %A_ScriptDir%\bank\*.csv
{
	FileRead,thisBank,%A_ScriptDir%\bank\%A_LoopFileName%
	Loop,Parse,thisBank,CSV
	{
		thisString:=Hexify(A_LoopField)

		hexBank = %hexBank%%thisString%,
	}
	FileDelete,%A_ScriptDir%\bank\%A_LoopFileName%
	FileAppend,%hexBank%,%A_ScriptDir%\bank\%A_LoopFileName%
}
;TODO: Also hexify .csv files

IniWrite,1,texter.ini,Settings,Hexified
IniWrite,1,texter.ini,Bundles,Default
return

