SaveHotstring(HotString, Replacement, IsScript, Bundle, SpaceIsTrigger, TabIsTrigger, EnterIsTrigger)
{
global EnterCSV
global TabCSV
global SpaceCSV
global EnterKeys
global TabKeys
global SpaceKeys
	HotString:=Hexify(HotString)
	successful := false
	if (!EnterIsTrigger AND !TabIsTrigger AND !SpaceIsTrigger)
	{
		MsgBox,262144,Choose a trigger,You need to choose a trigger in order to save a hotstring replacement.
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
	}
	GoSub,BuildActive
	return successful
}
