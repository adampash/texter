textPrompt(thisText) {
	Gui,7: +AlwaysOnTop -SysMenu +ToolWindow
	Gui,7: Add,Text,x5 y5, Enter the text you want to insert:
	Gui,7: Add,Edit,x20 y25 r1 vpromptText
	Gui,7: Add,Text,x5 y50,Your text will be replace the `%p variable:
	Gui,7: Add,Text,w300 Wrap x20 y70,%thisText%
	Gui,7: Show,auto,Enter desired text
	Hotkey,IfWinActive,Enter desired text
	Hotkey,Enter,SubmitPrompt
	;Hotkey,Space,
	WinWaitClose,Enter desired text
}
return

SubmitPrompt:
Gui, 7: Submit
Gui, 7: Destroy
StringReplace,ReplacementText,ReplacementText,`%p,%promptText%
return
