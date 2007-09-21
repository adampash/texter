EnableTriggers(doEnable)
{
global keys
	StringReplace,tempKeys,keys,`}`,`{,`n,All
	Loop,Parse,TempKeys,`n,`{`} 
	{
		if (doEnable)
		{
			Hotkey,IfWinNotActive,Enter desired text
			Hotkey,$%A_LoopField%,HOTKEYS
			Hotkey,$%A_LoopField%,On
			Hotkey,IfWinActive
		}
		else
		{
			Hotkey,IfWinNotActive,Enter desired text
			Hotkey,$%A_LoopField%,Off
			Hotkey,IfWinActive
		}
	}
}
