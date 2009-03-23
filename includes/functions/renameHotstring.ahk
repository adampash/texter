RENAME:
Gui,9: Submit
Gui,9: Destroy
if ActiveChoice in %enter%
{
	EnterCbox := true
}
else
	EnterCbox := false
if ActiveChoice in %tab%
{
	TabCbox:=true
}
else
	TabCbox:= false
if ActiveChoice in %space%
{
	SpaceCbox:= true
}
else
	SpaceCbox:= false
if ActiveChoice in %notrig%
{
	NoTrigCbox:= true
}
else
	NoTrigCbox:= false
if (CurrentBundle != "") and (CurrentBundle != "Default")
{
	AddToDir = Bundles\%CurrentBundle%\
}
else
{
	AddToDir=
}
if NewName = %editThis%
{
	return
}
else if SaveHotstring(NewName, Text, IsScript, AddToDir, SpaceCbox, TabCbox, EnterCbox, NoTrigCbox)
{
	DeleteHotstring(editThis, CurrentBundle)
	MakeActive = %NewName%
	GoSub,ListBundle
}
return

9GuiEscape:
Gui,9: Destroy
return