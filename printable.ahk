#SingleInstance,Force 
#NoEnv
SetWorkingDir, "%A_ScriptDir%"
FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
Gosub,PrintableList
return



PrintableList:
List = <html><head><title>Texter Hotstrings and Replacement Text Cheatsheet</title></head></body><h2>Texter Hostrings and Replacement Text Cheatsheet</h2><table border="1"><th>Hotstring</th><th>Replacement Text</th><th>Trigger(s)</th>
Loop, %A_WorkingDir%\replacements\*.txt
{
	trig =
	hs = %A_LoopFileName%
	StringReplace, hs, hs, .txt
	FileRead, rp, %A_WorkingDir%\replacements\%hs%.txt
	If hs in %EnterKeys%
		trig = Enter
	If hs in %TabKeys%
		trig = %trig% Tab
	If hs in %SpaceKeys%
		trig = %trig% Space
	StringReplace, rp, rp, <,&lt;,All
	StringReplace, rp, rp, >,&gt;,All
	List = %List%<tr><td>%hs%</td><td>%rp%</td><td>%trig%</td></tr>
	
}
List = %List%</table></body></html>
IfExist %A_WorkingDir%\resources\Replacement guide.html
	FileDelete,%A_WorkingDir%\resources\Texter Replacement Guide.html
FileAppend,%List%, %A_WorkingDir%\resources\Texter Replacement Guide.html
Run,%A_WorkingDir%\resources\Texter Replacement Guide.html
return