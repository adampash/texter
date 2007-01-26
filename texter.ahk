; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Adam Pash <adam@lifehacker.com>
; Gratefully adapted several ideas from AutoClip by Skrommel:
;		http://www.donationcoder.com/Software/Skrommel/index.html#AutoClip
; Script Function:
;	Designed to implement simple, on-the-fly creation and managment 
;	of auto-replacing hotstrings for repetitive text
#SingleInstance,Force 
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.

SetWorkingDir,"%A_ScriptDir%" 
SetKeyDelay,0 
SetWinDelay,0 

;Gosub,BUILDTRAYMENU 
Gosub,READINI 
SetTimer,GETWINDOW,999 

; Read contents of CSV files for matching and firing hotstrings
FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey,^+h,NEWKEY
Goto, Start

START: 
hotkey= 
Input,input,V L99,{RCtrl} 
If hotkey In %cancel% 
  Goto,START 
StringGetPos,pos,input,: 
StringLeft,command,input,%pos% 
pos+=1 
StringTrimLeft,parameter,input,%pos% 
;;;;;;;;;;;;;;;;;;;;;;;;;; This is my addition for parsing out by triggers (enter/tab/space) ;;;;;;;;;;;;;;;;;;;;;;;;;;;
if hotkey = `{Tab`}
{
	;MsgBox, Tab2
	if input in %TabKeys%
	{
		;MsgBox Match
		GoSub, Execute
		Goto,Start
	}
	else 
	{
		Send,%hotkey%
		Goto,Start
	}
}
else if hotkey = `{Enter`}
{
	if input in %EnterKeys%
	{
		GoSub, Execute
		Goto,Start
	}
	else 
	{
		Send,%hotkey%
		Goto,Start
	}
} 
else if hotkey = `{Space`}
{
	if input in %SpaceKeys%
	{
		GoSub, Execute
		Goto,Start
	}
	else 
	{
		Send,%hotkey%
		Goto,Start
	}
}
else
{
	Send,%hotkey%
	Goto, Start
}
;;;;;;;;;;;;;;;;;;;;;;;;;;; End of section for firing hotkey by trigger ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;filename:=hexify(input) 
;IfNotExist,%filename%.clip 
;IfNotExist,%filename%.script 
;IfNotExist,%command%.exe 
;{ 
;  Send,%hotkey% 
;  Goto,START 
;} 
;IfExist,%command%.exe 
;{ 
;  Gosub,RUN 
;  Goto,START 
;} 
;StringLen,length,input 
;Send,{Backspace %length%} 
;post=clip 
;Gosub,EXECUTE 
;post=script 
;Gosub,EXECUTE 
If hotkey Not In %ignore% 
If hotkey Not In %cancel% 
  Send,%hotkey% 
Goto,START 

;;;;;;;;;;;;;;;;;;;;; My Execute thread ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EXECUTE:
SetTimer,GETWINDOW,Off
SoundPlay, %A_WinDir%\Media\Windows XP Restore.wav
FileRead, ReplacementText, %A_WorkingDir%\replacements\%input%.txt
WinActivate,ahk_id %window% 
WinWaitActive,ahk_id %window% 
ControlFocus,%control%,ahk_id %window%
oldClip = %Clipboard%
Clipboard = %ReplacementText%
StringReplace, Clipboard, ReplacementText, `%c, %oldClip%, All
StringGetPos,CursorPoint,Clipboard,`%|
if ErrorLevel = 0
{
	StringReplace, Clipboard, Clipboard, `%|,, All
	StringLen,ClipLength,Clipboard
	ReturnTo := ClipLength - CursorPoint
}
else
{
	ReturnTo := 0
}
StringLen,BSlength,input
Send {BS %BSlength%}
Send, ^v
if ReturnTo > 0
	Send {Left %ReturnTo%}
Clipboard = %oldClip%
SetTimer,GETWINDOW,On 
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; end of my Execute thread ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;EXECUTE: 
;SetTimer,GETWINDOW,Off 
;FileRead,Clipboard,*c %filename%.txt 
;WinActivate,ahk_id %window% 
;WinWaitActive,ahk_id %window% 
;ControlFocus,%control%,ahk_id %window% 
;If post=script 
;  Send,%Clipboard% 
;Else 
;  Send,^v 
;SetTimer,GETWINDOW,On 
;Return 
;
;RUN: 
;Run,%command%.exe "%parameter%" 
;Return 

HOTKEYS: 
StringTrimLeft,hotkey,A_ThisHotkey,1 
StringLen,hotkeyl,hotkey 
If hotkeyl>1 
  hotkey=`{%hotkey%`} 
Send,{RCtrl} 
Return 

READINI: 
IfNotExist,AutoClip.ini 
  FileAppend,;Keys that start completion - must include Ignore and Cancel keys`n[Autocomplete]`nKeys={Escape}`,{Tab}`,{Enter}`,{Space}`,{`,}`,{;}`,{.}`,{:}`n;Keys not to send after completion`n[Ignore]`nKeys={Tab}`,{Enter}`n;Keys that cancel completion`n[Cancel]`nKeys={Escape},AutoClip.ini 
IniRead,cancel,AutoClip.ini,Cancel,Keys ;keys to stop completion, remember {} 
IniRead,ignore,AutoClip.ini,Ignore,Keys ;keys not to send after completion 
IniRead,keys,AutoClip.ini,Autocomplete,Keys 
Loop,Parse,keys,`, 
{ 
  StringTrimLeft,key,A_LoopField,1 
  StringTrimRight,key,key,1 
  StringLen,length,key 
  If length=0 
    Hotkey,$`,,HOTKEYS 
  Else 
    Hotkey,$%key%,HOTKEYS 
} 
Return 

GETWINDOW: 
WinGet,window0,ID,A 
WinGetClass,class,ahk_id %window0% 
If class<> 
If class<>Shell_TrayWnd 
If class<>AutoHotkey 
{ 
  ControlGetFocus,control,ahk_id %window0% 
  window=%window0% 
} 
Return 

;;;;;;;;; This section covers the on-the-fly hotstring creation

NEWKEY:
Gui, Destroy
Gui, +AlwaysOnTop +Owner -SysMenu ;suppresses taskbar button, always on top, removes minimize/close
Gui, Add, Text,x15 y40, Hotstring:
Gui, Add, Edit, x13 y55 r1 W65 vRString,
Gui, Add, Text,x+20 y40, Text:
Gui, Add, Edit, xp y55 r6 W400 vFullText, Enter your replacement text here...
Gui, Add, Text,,Execute with:
Gui, Add, Checkbox, vEnterCbox yp xp+75, Enter
Gui, Add, Checkbox, vTabCbox yp xp+60, Tab
Gui, Add, Checkbox, vSpaceCbox yp xp+60, Space
Gui, Add, Button,w80 default,&OK
Gui, Add, Button,w80 xp+100 GButtonCancel,&Cancel
Gui, Show, W500 H200
return


ButtonCancel:
Gui,Destroy
return

ButtonOK:
Gui, Submit
If RString<>
{
	if FullText<>
	{
		IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
		{
			if EnterCbox = 1 
			{
				FileAppend,%Rstring%`,, %A_WorkingDir%\bank\enter.csv
				FileRead, EnterKeys, %A_WorkingDir%\bank\enter.csv
				FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
			}
			if TabCbox = 1
			{
				FileAppend,%Rstring%`,, %A_WorkingDir%\bank\tab.csv
				FileRead, TabKeys, %A_WorkingDir%\bank\tab.csv
				IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
					FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
			}
			if SpaceCbox = 1
			{
				FileAppend,%Rstring%`,, %A_WorkingDir%\bank\space.csv
				FileRead, SpaceKeys, %A_WorkingDir%\bank\space.csv
				IfNotExist, %A_WorkingDir%\replacements\%RString%.txt
					FileAppend,%FullText%,%A_WorkingDir%\replacements\%Rstring%.txt
			}
		}
		else
		{
			MsgBox %Rstring% replacment already exists
		}
		;MsgBox You entered text in both
	}
	else
		MsgBox Only replacement
}
return

;;;;;;;;;;;;;;;;;;;          End of on-the-fly hotkey creation         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


EXIT: 
ExitApp 


;;;;;;;;;;;;;;;;;;;;; Every function below this line ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; is not in use and ripe for deletion ;;;;;;;;;;;;;;;;;;;;;;;;;;

BUILDTRAYMENU: 
Menu,Tray,NoStandard 
Menu,Tray,DeleteAll 
post=clip 
Gosub,ADDTRAYFILES 
Menu,Tray,Add,&Add Clip,ADDCLIP 
Menu,Tray,Add,&Remove Clip,REMOVECLIP 
Menu,Tray,Add 
post=script 
Gosub,ADDTRAYFILES 
Menu,Tray,Add,&Add Script,ADDSCRIPT 
Menu,Tray,Add,&Remove Script,REMOVESCRIPT 
Menu,Tray,Add 
Menu,Tray,Add,&List All,LIST 
Menu,Tray,Add,&Help,HELP 
Menu,Tray,Add,E&xit,EXIT 
Return 

ADDTRAYFILES: 
filelist= 
Loop,*.%post% 
  filelist=%FileList%%A_LoopFileName%`n 
Sort,filelist 
counter=0 
Loop,Parse,filelist,`n 
{ 
  If A_LoopField= 
    Continue 
  counter+=1 
  FileRead,Clipboard,*c %A_LoopField% 
  shorthand:=Dehexify(A_LoopField) 
  Menu,Tray,Add,%shorthand%,PASTE%post% 
} 
Return 

REMOVECLIP: 
post=clip 
Gosub,REMOVE 
Return 

REMOVESCRIPT: 
post=script 
Gosub,REMOVE 
Return 

REMOVE: 
Input 
filelist= 
Loop,*.%post% 
  filelist=%FileList%%A_LoopFileName%`n 
Sort,filelist 
Menu,clipmenu,Add 
Menu,clipmenu,DeleteAll 
counter=0 
Loop,Parse,filelist,`n 
{ 
  If A_LoopField= 
    Continue 
  counter+=1 
  FileRead,Clipboard,*c %A_LoopField% 
  shorthand:=Dehexify(A_LoopField) 
  Menu,clipmenu,Add,%shorthand%,REMOVESELECT 
} 
Menu,clipmenu,Show 
Return 

REMOVESELECT: 
Input 
filename:=hexify(A_ThisMenuItem) 
IfNotExist,%filename%.%post% 
  MsgBox,0,Remove %post%,Filename %shorthand% doesn't exists. 
Else 
  FileDelete,%filename%.%post% 
Gosub,BUILDTRAYMENU 
;Menu,clipmenu,Delete,%shorthand% 
Return 

PASTECLIP: 
post=clip 
Gosub,PASTESELECT 
Return 

PASTESCRIPT: 
post=script 
Gosub,PASTESELECT 
Return 

PASTESELECT: 
Input 
filename:=hexify(A_ThisMenuItem) 
IfNotExist,%filename%.%post% 
{ 
  MsgBox,0,AutoClip,Shorthand %A_ThisMenuItem% doesn't exists. 
  Gosub,BUILDTRAYMENU 
  Return 
} 
FileRead,Clipboard,*c %filename%.%post% 
Gosub,EXECUTE 
Return 

LIST: 
Input 
FileDelete,AutoClip.rtf 
FileAppend,,AutoClip.rtf 
Run,WordPad.exe "AutoClip.rtf" 
WinWait,AutoClip.rtf - WordPad,,5 
If ErrorLevel=1 
{ 
  MsgBox,Can't find WordPad 
  Return 
} 
post=clip 
Gosub,LISTLOOP 
post=script 
Gosub,LISTLOOP 
Return 

LISTLOOP: 
filelist= 
Loop,*.%post% 
  filelist=%FileList%%A_LoopFileName%`n 
Sort,filelist 
counter=0 
Loop,Parse,filelist,`n 
{ 
  If A_LoopField= 
    Continue 
  counter+=1 
  FileRead,Clipboard,*c %A_LoopField% 
  shorthand:=Dehexify(A_LoopField) 
  WinActivate,AutoClip.rtf - WordPad 
  WinWaitActive,AutoClip.rtf - WordPad 
  Send,%post%%counter%: %shorthand%`n`n{Up}^v{Down}`n 
} 
Send,^s 
Return 

Hexify(x) ;Stolen from Laszlo 
{ 
  StringLen,len,x 
  format=%A_FormatInteger% 
  SetFormat,Integer,Hex 
  hex= 
  Loop,%len% 
  { 
    Transform,y,Asc,%x% 
    StringTrimLeft,y,y,2 
    hex=%hex%%y% 
    StringTrimLeft,x,x,1 
  } 
  SetFormat,Integer,%format% 
  Return,hex 
} 

DeHexify(x) 
{ 
   StringLen,len,x 
   len:=(len-5)/2 
   string= 
   Loop,%len% 
   { 
      StringLeft,hex,x,2 
      hex=0x%hex% 
      Transform,y,Chr,%hex% 
      string=%string%%y% 
      StringTrimLeft,x,x,2 
   } 
   Return,string 
} 

HELP: 
help=         AutoClip v4.0 
help=%help%`n 
help=%help%`n Replaces text you type with any formatted text, image or other clip. 
help=%help%`n 
help=%help%`n Example: Place the clip you want to use on the clipboard by selecting 
help=%help%`n text or an image, and press Ctrl-C.  
help=%help%`n Rightclick the tray icon, select Add Clip, and input the shorthand. 
help=%help%`n Rightclick the tray icon to Remove or List clips. F12=Add Clip. 
help=%help%`n The clips are showed at the top of the tray menu, and clicking 
help=%help%`n pastes the clip into the active control of the active window. 
help=%help%`n 
help=%help%`n You can also make Scripts that send key presses for automation, using 
help=%help%`n {Tab}{Enter}{Left}{PgUp} etc... !=alt, ^=ctrl, +=shift, #=windows. 
help=%help%`n Example: Start Notepad, write user{Tab}password, select the text, 
help=%help%`n press Ctrl-C. 
help=%help%`n Rightclick the tray icon, select Add Script, and input the shorthand. 
help=%help%`n Rightclick the tray icon to Remove or List scripts. F11=Add Script. 
help=%help%`n The scripts are showed in the middle of the tray menu, and clicking 
help=%help%`n sends the script into the active control of the active window. 
help=%help%`n 
help=%help%`n AutoClip can also run external programs. Any exe-file placed together 
help=%help%`n with AutoClip is run by typing the name of the exe-file, 
help=%help%`n a colon, and the parameters to send. Example: calc:1+2*3 
help=%help%`n 
help=%help%`n The clips and scripts are listed using WordPad. 
help=%help%`n 
help=%help%`n It also works in programs without an input box, like PaintBrush. 
help=%help%`n
help=%help%`n Skrommel @2005    www.donationcoders.com/skrommel
MsgBox,0,AutoClip,%help% 
help= 
Return