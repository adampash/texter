SaveHotstring(HotString, Replacement, IsScript, Bundle, SpaceIsTrigger, TabIsTrigger, EnterIsTrigger, NoTrigger)
{
global EnterCSV
global TabCSV
global SpaceCSV
global NoTrigCSV
global EnterKeys
global TabKeys
global SpaceKeys
global NoTrigKeys
	HotString:=Hexify(HotString)
	successful := false
	if (!EnterIsTrigger AND !TabIsTrigger AND !SpaceIsTrigger AND !NoTrigger)
	{
		MsgBox,262144,Choose a trigger,You need to choose a trigger method in order to save a hotstring replacement.
	}
	else if (HotString <> "" AND Replacement <> "")
	{
		successful := true
		if IsScript
		{
			Replacement = ::scr::%Replacement%
		}

		IniWrite,%SpaceIsTrigger%,texter.ini,Triggers,Space
		IniWrite,%TabIsTrigger%,texter.ini,Triggers,Tab
		IniWrite,%EnterIsTrigger%,texter.ini,Triggers,Enter
		IniWrite,%NoTrigger%,texter.ini,Triggers,NoTrig

		FileDelete, %A_ScriptDir%\%Bundle%replacements\%HotString%.txt
		FileAppend,%Replacement%,%A_ScriptDir%\%Bundle%replacements\%HotString%.txt

		if EnterIsTrigger
		{
			AddToBank(HotString, Bundle, "enter")
		}
		else
		{
			DelFromBank(HotString, Bundle, "enter")
		}
		if TabIsTrigger
		{
			AddToBank(HotString, Bundle, "tab")
		}
		else
		{
			DelFromBank(HotString, Bundle, "tab")
		}
		if SpaceIsTrigger
		{
			AddToBank(HotString, Bundle, "space")
		}
		else
		{
			DelFromBank(HotString, Bundle, "space")
		}
		if NoTrigger
		{
			AddToBank(HotString, Bundle, "notrig")
		}
		else
		{
			DelFromBank(HotString, Bundle, "notrig")
		}
	}
	GoSub,BuildActive
	return successful
}

DeleteHotstring(Hotstring, Bundle)
{
	Hotstring:=Hexify(Hotstring)
	if (Bundle != "") and (Bundle != "Default")
	RemoveFromDir = Bundles\%Bundle%\
	else
		RemoveFromDir = 
	FileDelete,%A_ScriptDir%\%RemoveFromDir%replacements\%Hotstring%.txt
	DelFromBank(Hotstring, RemoveFromDir, "enter")
	DelFromBank(Hotstring, RemoveFromDir, "tab")
	DelFromBank(Hotstring, RemoveFromDir, "space")
	DelFromBank(Hotstring, RemoveFromDir, "notrig")
	GuiControl,2:,Choice,|%Bundle%
	GuiControl,2:,FullText,
	GuiControl,2:,EnterCbox,0
	GuiControl,2:,TabCbox,0
	GuiControl,2:,SpaceCbox,0
	Gosub, BuildActive
	return
}