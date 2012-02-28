; Texter
; Author:         Adam Pash <adam@lifehacker.com>
; Gratefully adapted several ideas from AutoClip by Skrommel:
;		http://www.donationcoder.com/Software/Skrommel/index.html#AutoClip
; Huge thanks to Dustin Luck for his contributions
; Script Function:
;	Designed to implement simple, on-the-fly creation and managment 
;	of auto-replacing hotstrings for repetitive text
;	http://lifehacker.com/software//lifehacker-code-texter-windows-238306.php
SetWorkingDir %A_ScriptDir%
#SingleInstance,Force 
#NoEnv
StringCaseSense On
AutoTrim,off
SetKeyDelay,-1
SetWinDelay,0 
;Gosub,UpdateCheck
Gosub,ASSIGNVARS
Gosub,RESOURCES
Gosub,READINI
;EnableTriggers(true)
Gosub,TRAYMENU
Gosub,BuildActive

; Autocorrect and autoclose not yet fully implemented
;if AutoCorrect = 1
;	Gosub,AUTOCORRECT
;if AutoClose = 1
;	Gosub,AUTOCLOSE

FileRead, EnterKeys, %EnterCSV%
FileRead, TabKeys, %TabCSV%
FileRead, SpaceKeys, %SpaceCSV%
FileRead, NoTrigKeys, %NoTrigCSV%
FileRead, AutocorrectKeys, %AutocorrectCSV%
;Gosub,GetFileList
;Goto Start
; WinGet PrevWinID, ID, A
; SetTimer, MonitorWindows, 500
Starting=1
Loop
{
  ;wait for a matching hotstring
  if (Disable = 1)
  {
		continue
  }
  if Starting <>
  {
	  Loop
	  { ;grab input one character at a time looking for a match
		if (Disable = 1)
		{
			break
		}
	    Input, UserInput, L1 V M, %EndKeys%
		;Tooltip, Input received, 10, 10
	    if (SubStr(ErrorLevel, 1, 6) = "EndKey")
	    { ;any end key resets the search for a match
	      PossibleMatch=
	    }
	    else
	    {
	      PossibleMatch=%PossibleMatch%%UserInput% 
	    }
		;Tooltip, PossibleMatch= %PossibleMatch%    
	    IfInString, HotStrings, |%PossibleMatch%|
	    { ;found a match - go to trigger search
	      break
	    }
	  }			; end of inside loop
  }
  PossHexMatch := Hexify(PossibleMatch)
  ;PHMPipe = |%PossHexMatch%|
  if AutoCorrect = 1
  {
	  IfInString, AutocorrectKeys, |%PossibleMatch%|
	  {
		AutoMatch = 1
	  }
	  else
	  {
		AutoMatch=
	  }
  }
  if (Autocorrect = 1 and AutoMatch = 1)
  {
		;msgbox %autocorrectkeys% 
	  ;if PossHexMatch in %AutocorrectKeys%
	  ;{ ;matched in triggerless list	
		ReadFrom = %A_ScriptDir%\Active\Autocorrect\replacements
	    Match := Hexify(PossibleMatch)
		;msgbox %match%
		if GetKeyState("Shift", "P") ; the following loop prevents the shift key from being stuck, which happens if it's released while the execute thread is in progress
		{
			Loop
			{
				if GetKeyState("Shift", "P")
				{
					continue
				}
				else
				{
					break
				}
			}
		}
	  ;}
	}
  else if PossHexMatch in %NoTrigKeys%
  {
    Match := PossHexMatch
	ReadFrom = %A_ScriptDir%\Active\replacements
	if GetKeyState("Shift", "P") ; the following loop prevents the shift key from being stuck, which happens if it's released while the execute thread is in progress
	{
		Loop
		{
			if GetKeyState("Shift", "P")
			{
				continue
			}
			else
			{
				break
			}
		}
	}
  }
  else
  { ;get a single character of input to look for triggers
    Transform, CtrlC, Chr, 3  ; used for the Ctrl-C check
    Input, UserInput, L1 M, %EndKeys%
		;Tooltip, ErrorLevel= %ErrorLevel%, 10, 10
	;msgbox %userinput%
      AltState := GetKeyState("Alt", "P")
      CtrlState := GetKeyState("Ctrl", "P")
      ShiftState := GetKeyState("Shift", "P")
      LWinState := GetKeyState("LWin", "P")
      RWinState := GetKeyState("RWin", "P")
      WinState := LWinState || RWinState
	  Modifier=
      if (AltState || CtrlState || WinState || ShiftState)
      {	
		if AltState
		{
		  Modifier = !
		  PossibleMatch=
		}
		if CtrlState
		{
		  Modifier = %Modifier%^
		  PossibleMatch=
		}
		if ShiftState
		{
		  Modifier = %Modifier%+
		}
		if WinState
		{
		  Modifier = %Modifier%#
		  PossibleMatch=
		}
      }
	if (SubStr(ErrorLevel, 1, 6) = "EndKey")
    { ;trigger found
      Trigger := SubStr(ErrorLevel, 8)
	  if (Trigger = "Backspace")
	  { ; trim possmatch so trigger still works if miskeyed
		Send %Modifier%{BS}
	    StringTrimRight, PossibleMatch, PossibleMatch, 1
		continue
	  }
	  Bank = %Trigger%Keys
	  Bank := %Bank%
	  PossHexMatch := Hexify(PossibleMatch)	
      if PossHexMatch in %Bank%
      { ;hotstring/trigger match
		ReadFrom = %A_ScriptDir%\Active\replacements
        Match := PossHexMatch
      }
      else
      {
	    if (AltState && !CtrlState && !ShiftState && !WinState)
        {
		  ;Msgbox alt alone
          if AltState
          {
            Send, {Alt Down}`{%Trigger%`}
		    AltState := GetKeyState("Alt", "P")
		    Loop
		    {
		      if AltState
			  {
			    AltState := GetKeyState("Alt", "P")
			  }
			  else
			  {
			    Send, {Alt Up}
			    break
			  }
		    }
			PossibleMatch=
			Starting=1
			continue
          }
		}
		else if (AltState || CtrlState || WinState || ShiftState)
		{
		  ;msgbox not alone: %modifier%
		  Send, %Modifier%`{%Trigger%`}
		  PossibleMatch=
		  Starting=1
		  continue
		}
        else
        {
		  ;MsgBox %Trigger%
          Send, `{%Trigger%`}
		  ;msgbox sent trigger
		  PossibleMatch=
		  Starting=1
		  continue
        }
        ;MsgBox, Trigger=%Trigger%
      }
    }
  }
  if Match<>
  {
    ;msgbox %possiblematch%
	GoSub, EXECUTE
    PossibleMatch=
	PossHexMatch=
    Match=
	Starting=1
	continue
  }
  else
  {
	  if AltState
	  {
		Send, {Alt Down}%UserInput%
		AltState := GetKeyState("Alt", "P")
		Loop
		{
		  if AltState
		  {
			AltState := GetKeyState("Alt", "P")
		  }
		  else
		  {
			Send, {Alt Up}
			break
		  }
		}
	  }
	  else if UserInput = %CtrlC% ; this doesn't seem like the best fix, but Ctrl-C was not working correctly w/out
	  {								  ; all other modifiers + letters seem to be working fine
		SendInput, ^c
		PossibleMatch=
		Starting=1
		;msgbox boom hi there
		continue
	  }
;	  else if (Modifier <> && !ShiftState) ;is this even doing anything anymore?
;	  {
;		SendInput,%Modifier%%UserInput%
;		msgbox sending
;		PossibleMatch=
;		Starting=1
;		continue
;	   }
		;msgbox sending %userinput%
	    PossibleMatch=%PossibleMatch%%UserInput%
		;Tooltip, PossibleMatch= %PossibleMatch%
	    SendRaw, %UserInput%  ; SendRaw ensures special characters like #, !, {}, etc. are interpreted and sent correctly
		Starting=
		Modifier=
	  
	}
 
}
return

;~$BS::StringTrimRight, PossibleMatch, PossibleMatch, 1


EXECUTE:
WinGetActiveTitle,thisWindow ; this variable ensures that the active Window is receiving the text, activated before send
;; below added b/c SendMode Play appears not to be supported in Vista 
;EnableTriggers(false)
if (A_OSVersion = "WIN_VISTA") or (Synergy = 1)
	SendMode Input
else
	SendMode Play   ; Set an option in Preferences to enable for use with Synergy - Use SendMode Input to work with Synergy
if (ExSound = 1)
	SoundPlay, %ReplaceWAV%
ReturnTo := 0
hexInput:=Dehexify(Match)
StringLen,BSlength,hexInput
Send, {BS %BSlength%}
FileRead, ReplacementText, %ReadFrom%\%Match%.txt
;msgbox %hexinput%
StringLen,ClipLength,ReplacementText

IfInString,ReplacementText,::scr::
{
	;To fix double spacing issue, replace `r`n (return + new line) as AHK sends a new line for each character
	StringReplace,ReplacementText,ReplacementText,`r`n,`n, All
	StringReplace,ReplacementText,ReplacementText,::scr::,,
	IfInString,ReplacementText,`%p
	{
		textPrompt(ReplacementText)
		if escapePrompt = 1
		{
			Exit
		}
	}
	IfInString,ReplacementText,`%s
	{
		StringReplace, ReplacementText, ReplacementText,`%s(, ¢, All
		Loop,Parse,ReplacementText,¢
		{
			if (A_Index != 1)
			{
				StringGetPos,len,A_LoopField,)
				StringTrimRight,sleepTime,A_LoopField,%len%
				StringMid,thisScript,A_LoopField,(len + 2),
				Sleep,%sleepTime%
				;WinActivate,%thisWindow%  The assumption must be made that in script mode
				; the user can intend to enter text in other windows
				SendInput,%thisScript%
			}
			else
			{
				;WinActivate,%thisWindow%  The assumption must be made that in script mode
				; the user can intend to enter text in other windows
				SendInput,%A_LoopField%
			}
		}
	}
	else
		SendInput,%ReplacementText%
	return
}
else
{
	;To fix double spacing issue, replace `r`n (return + new line) as AHK sends a new line for each character
	;(but only in compatibility mode)
	if MODE = 0
	{
		StringReplace,ReplacementText,ReplacementText,`r`n,`n, All
	}
	IfInString,ReplacementText,`%c
	{
		StringReplace, ReplacementText, ReplacementText, `%c, %Clipboard%, All
	}
	IfInString,ReplacementText,`%t
	{
		FormatTime, CurrTime, , Time
		StringReplace, ReplacementText, ReplacementText, `%t, %CurrTime%, All
	}
	IfInString,ReplacementText,`%ds
	{
		FormatTime, SDate, , ShortDate
		StringReplace, ReplacementText, ReplacementText, `%ds, %SDate%, All
	}
	IfInString,ReplacementText,`%dm
	{
		FormatTime, XDate, , MM/dd/yyyy
		StringReplace, ReplacementText, ReplacementText, `%dm, %XDate%, All
	}
	IfInString,ReplacementText,`%dl
	{
		FormatTime, LDate, , LongDate
		StringReplace, ReplacementText, ReplacementText, `%dl, %LDate%, All
	}
	IfInString,ReplacementText,`%p
	{
		textPrompt(ReplacementText)
		if escapePrompt = 1
		{
			return
		}		
	}
	IfInString,ReplacementText,`%|
	{
		;in clipboard mode, CursorPoint & ClipLength need to be calculated after replacing `r`n
		if MODE = 0
		{
			MeasurementText := ReplacementText
		}
		else
		{
			StringReplace,MeasurementText,ReplacementText,`r`n,`n, All
		}
		StringGetPos,CursorPoint,MeasurementText,`%|
		StringReplace, ReplacementText, ReplacementText, `%|,, All
		StringReplace, MeasurementText, MeasurementText, `%|,, All
		StringLen,ClipLength,MeasurementText
		ReturnTo := ClipLength - CursorPoint
	}

	if MODE = 0
	{
		if ReturnTo > 0
		{
			if ReplacementText contains !,#,^,+,{
			{
				WinActivate,%thisWindow%
				SendRaw, %ReplacementText%
				Send,{Left %ReturnTo%}
			}
			else
			{
				WinActivate,%thisWindow%
				Send,%ReplacementText%{Left %ReturnTo%}
			}
		}
		else
		{
			WinActivate,%thisWindow%
			SendRaw,%ReplacementText%
		}
	}
	else
	{
		oldClip = %Clipboard%
		Clipboard = %ReplacementText%
		if ReturnTo > 0
		{
			WinActivate,%thisWindow%
			Send,^v{Left %ReturnTo%}
		}
		else
		{
			WinActivate,%thisWindow%
			Send,^v
		}
		Clipboard = %oldClip%
	}
;	if ReturnTo > 0
;		Send, {Left %ReturnTo%}

}
SendMode Event
IniRead,expanded,texter.ini,Stats,Expanded
IniRead,chars_saved,texter.ini,Stats,Characters
expanded += 1
chars_saved += ClipLength
IniWrite,%expanded%,texter.ini,Stats,Expanded
IniWrite,%chars_saved%,texter.ini,Stats,Characters
Return

HOTKEYS: 
StringTrimLeft,hotkey,A_ThisHotkey,1 
StringLen,hotkeyl,hotkey 
If hotkeyl>1 
  hotkey=`{%hotkey%`} 
Send,{SC77}
Return 

ASSIGNVARS:
Version = 0.6
EnterCSV = %A_ScriptDir%\Active\bank\enter.csv
TabCSV = %A_ScriptDir%\Active\bank\tab.csv
SpaceCSV = %A_ScriptDir%\Active\bank\space.csv
NoTrigCSV = %A_ScriptDir%\Active\bank\notrig.csv
AutocorrectCSV = %A_ScriptDir%\Active\Autocorrect\pipelist.txt
ReplaceWAV = %A_ScriptDir%\resources\replace.wav
TexterPNG = %A_ScriptDir%\resources\texter.png
TexterICO = %A_ScriptDir%\resources\texter.ico
StyleCSS = %A_ScriptDir%\resources\style.css
Throbber =  %A_ScriptDir%\resources\throbber.gif
SpecialKey = vkFF
EndKeys={Enter}{Esc} {Tab}{Right}{Left}{Up}{Down}{Del}{BS}{Home}{End}{PgUp}{PgDn}{%SpecialKey%}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}
Disable = 0
return

READINI:
IniWrite,%Version%,texter.ini,Preferences,Version
IniWrite,0,texter.ini,Settings,Disable
cancel := GetValFromIni("Cancel","Keys","{Escape}") ;keys to stop completion, remember {} 
ignore := GetValFromIni("Ignore","Keys","{Tab}`,{Enter}`,{Space}") ;keys not to send after completion 
IniWrite,{Escape}`,{Tab}`,{Enter}`,{Space}`,{Left}`,{Right}`,{Up}`,{Down},texter.ini,Autocomplete,Keys
keys := GetValFromIni("Autocomplete","Keys","{Escape}`,{Tab}`,{Enter}`,{Space}`,{Left}`,{Right}`,{Esc}`,{Up}`,{Down}")
otfhotkey := GetValFromIni("Hotkey","OntheFly","^+H")
managehotkey := GetValFromIni("Hotkey","Management","^+M")
disablehotkey := GetValFromIni("Hotkey", "Disable","")
MODE := GetValFromIni("Settings","Mode",0)
EnterBox := GetValFromIni("Triggers","Enter",0)
TabBox := GetValFromIni("Triggers","Tab",0)
SpaceBox := GetValFromIni("Triggers","Space",0)
ExSound := GetValFromIni("Preferences","ExSound",1)
Synergy := GetValFromIni("Preferences","Synergy",0)
Autocorrect := GetValFromIni("Preferences","AutoCorrect",1)
Default := GetValFromIni("Bundles","Default",1)
OnStartup := GetValFromIni(Settings, Startup, 0)




;; Enable hotkeys for creating new keys and managing replacements
if otfhotkey <>
{
	Hotkey,IfWinNotActive,Texter Preferences
	Hotkey,%otfhotkey%,NEWKEY	
	Hotkey,IfWinActive
}
if managehotkey <>
{
	Hotkey,IfWinNotActive,Texter Preferences
	Hotkey,%managehotkey%,MANAGE
	Hotkey,IfWinActive
}

if disablehotkey <>
{
	Hotkey,IfWinNotActive,Texter Preferences
	Hotkey,%disablehotkey%,DISABLE
	Hotkey,IfWinActive
}

~LButton::PossibleMatch=
~RButton::PossibleMatch=
~MButton::PossibleMatch=

; GUI
#Include includes\GUI\newkey_GUI.ahk     		 	; the GUI for new on-the-fly hotstring creation
#Include includes\GUI\traymenu_GUI.ahk 		  	; Builds the right-click system tray menu
#Include includes\GUI\about_GUI.ahk       		  	; About Texter GUI window
#Include includes\GUI\help_GUI.ahk          		 	; Help dialog/window
#Include includes\GUI\preferences_GUI.ahk			; Preferences GUI and accept/cancel threads
#Include includes\GUI\management_GUI.ahk		; Implementation of the hotstring management GUI
#Include includes\GUI\textprompt_GUI.ahk			; GUI that prompts for text when %p operator is included
#Include includes\GUI\disablechecks.ahk			; Keeps instant exclusive from tab, enter, and space keys (greys out others)


; Functions
#Include includes\functions\disable.ahk  				; Disable/enable Texter... need to check if this is still in use (not sure it is)
#Include includes\functions\urls.ahk       				; Links to Texter homepage and usage instructions
#Include includes\functions\getfilelist.ahk				; Loops the main %A_ScriptDir%\replacements\*.txt dir and gathers the list of replacements 
#Include includes\functions\buildactive.ahk			; Loops the enabled bundles and builds the active set of replacements in Active\replacements\ and Active\replacements
#Include includes\functions\bundles.ahk				; Implementation for working with bundles in the management GUI
#Include includes\functions\getvalfromini.ahk		; method for writing to ini
#Include includes\functions\savehotstring.ahk		; method for saving a new hotstring
#Include includes\functions\addtobank.ahk			; method for adding a new hotstring to the bank list of replacements
#Include includes\functions\delfrombank.ahk		; method for deleting a hotstring to the bank list of replacements
#Include includes\functions\enabletriggers.ahk		; method for enabling/disabling Texter
#Include includes\functions\resources.ahk			; Installs file resources like images and sounds
#Include includes\functions\printablelist.ahk			; Builds Texter Replacement Guide HTML file 
#Include includes\functions\updatecheck.ahk		; If enabled, checks for updates to Texter on startup
; #Include includes\functions\hexall.ahk					; Converts pre-0.5 version of Texter to the new hexified replacement format... may remove in future versions
#Include includes\functions\hexify.ahk					; Translates back and forth between hex values for replacements
#Include includes\functions\InsSpecKeys.ahk		; Insert special characters in Texter script mode by pressing insert and then the special key
#Include includes\functions\MonitorWindows.ahk 	; monitors active window and clears input when window switches
#include includes\functions\renameHotstring.ahk	; rename hotstrings in the Texter Management GUI via the right-click context menu
#include includes\functions\InstallAutocorrect.ahk	; sets up autocorrect folder when Texter is first run

;#Include includes\functions\autocorrect.ahk			; Spelling autocorrect--may implement in 0.6
; #Include includes\functions\autoclose.ahk			; Automatically closes bracketed puntuation, like parentheticals - not currently implemented

EXIT: 
ExitApp 