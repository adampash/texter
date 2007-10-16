PrintableList:
alt := 0
List = <html xmlns="http://www.w3.org/1999/xhtml"><head><link type="text/css" href="style.css" rel="stylesheet"><title>Texter Hotstrings and Replacement Text Cheatsheet</title></head><body><h2>Texter Hostrings and Replacement Text Cheatsheet</h2><h2 style="color:red">Default</h2><span class="hotstring" style="border:none`; color:black`;"><h3>Hotstring</h3></span><span class="replacement" style="border:none`;"><h3>Replacement Text</h3></span><span class="trigger" style="border:none`;"><h3>Trigger(s)</h3></span>
Loop, replacements\*.txt
{
	alt := 1 - alt
	trig =
	hs = %A_LoopFileName%
	StringReplace, hs, hs, .txt
	FileRead, rp, replacements\%hs%.txt
	FileRead, entertrig, bank\enter.csv
	FileRead, tabtrig, bank\tab.csv
	FileRead, spacetrig, bank\space.csv
	FileRead, notrig, bank\notrig.csv
	If hs in %entertrig%
		trig = Enter
	If hs in %tabtrig%
		trig = %trig% Tab
	If hs in %spacetrig%
		trig = %trig% Space
	If hs in %notrig%
		trig = %trig% Instant
	StringReplace, rp, rp, <,&lt;,All
	StringReplace, rp, rp, >,&gt;,All
	hs := DeHexify(hs)
	List = %List%<div class="row%alt%"><span class="hotstring">%hs%</span><span class="replacement">%rp%</span><span class="trigger">%trig%</span></div><br />
	
}
Loop,bundles\*,2
{
	thisBundle = %A_LoopFileName%
	List = %List%<br><br><br><h2 style="color:red; clear:both;">%thisBundle%</h2><span class="hotstring" style="border:none`; color:black`;"><h3>Hotstring</h3></span><span class="replacement" style="border:none`;"><h3>Replacement Text</h3></span><span class="trigger" style="border:none`;"><h3>Trigger(s)</h3></span>
	Loop,bundles\%A_LoopFileName%\replacements\*.txt
	{
		trig =
		hs = %A_LoopFileName%
		StringReplace, hs, hs, .txt
		FileRead, rp, bundles\%thisBundle%\replacements\%hs%.txt
		FileRead, entertrig, bundles\%thisBundle%\bank\enter.csv
		FileRead, tabtrig, bundles\%thisBundle%\bank\tab.csv
		FileRead, spacetrig, bundles\%thisBundle%\bank\space.csv
		FileRead, notrig, bundles\%thisBundle%\bank\notrig.csv
		If hs in %entertrig%
			trig = Enter
		If hs in %tabtrig%
			trig = %trig% Tab
		If hs in %spacetrig%
			trig = %trig% Space
		If hs in %notrig%
			trig = %trig% Instant
		StringReplace, rp, rp, <,&lt;,All
		StringReplace, rp, rp, >,&gt;,All
		hs := DeHexify(hs)
		List = %List%<div class="row%alt%"><span class="hotstring">%hs%</span><span class="replacement">%rp%</span><span class="trigger">%trig%</span></div><br />
	}
	StringReplace, thisBundle, thisBundle, .txt,,All
	StringReplace, thisBundle, thisBundle, %A_LoopFileName%,,
	%A_LoopFileName% = %thisBundle%
} 
List = %List%</body></html>
IfExist resources\Texter Replacement Guide.html
	FileDelete,resources\Texter Replacement Guide.html
FileAppend,%List%, resources\Texter Replacement Guide.html
Run,resources\Texter Replacement Guide.html
return
