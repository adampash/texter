InstallAutocorrect:
	Gui,10: Destroy
	Gui,10: +owner
	Gui,10: Add, Text, x5 y10, Loading...

	Gui,10: Add,Picture,x200 y0,%TexterPNG%
	Gui,10: font, s36, Courier New
	Gui,10: Add, Text,x10 y35,Texter
	Gui,10: font, s8, Courier New
	Gui,10: Add, Text,x171 y77,%Version%
	Gui,10: font, s9, Arial
	Gui,10: Add,Text,x10 y110 Center,Texter is initializing. This will only happen once.
	Gui,10: Color,F8FAF0
	Gui 2:+Disabled
	Gui,10: Show,auto,About Texter
	BundleDir = Active\Autocorrect\
	AutoCorrectBundle = resources\autocorrect.txt
	LineSwitch := 0
	Loop, Read, %AutoCorrectBundle%
	{
    LineSwitch := 1 - LineSwitch
	if A_LoopReadLine = ¢Triggers¢
		{
			readFrom = %A_Index%
			break
		}
	  if (A_Index = 1)
	  {
		continue
	  }
	  if (LineSwitch = 1)
	  {
		FileName := Hexify(A_LoopReadLine)

		StringReplace, Hotstring, FileName, .txt
	  }
	  else
	  {
	    Replacement =
		StringReplace,Replacement, A_LoopReadLine,`%bundlebreak,`r`n,All
		FileAppend, %Replacement%, %BundleDir%replacements\%FileName%.txt

		FileName=
		Replacement=
		}
	}
	CSVListAt := readFrom + 1
	CSVList2At := readFrom + 2
	pipeListAt := readFrom + 3

	FileReadLine,ACTrigs,%AutoCorrectBundle%,%CSVListAt%
	FileReadLine,ACTrigs2,%AutoCorrectBundle%,%CSVListAt2%
	FileReadLine,ACPipeList,%AutoCorrectBundle%,%pipeListAt%

	FileAppend,%ACTrigs%%ACTrigs2%,Active\Autocorrect\autocorrect.csv
	FileAppend,%ACPipeList%,Active\Autocorrect\pipelist.txt
	Gui,10: Destroy
return