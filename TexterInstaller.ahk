#SingleInstance,Force 
#NoEnv
#NoTrayIcon
Goto,DIRECTORY

DIRECTORY:
InstallDir = 
Gui, Add, Text,y10 x10,Where would you like to install Texter?
Gui, Add, Edit, x20 y30 r1 W300 vInstallDir,%A_ProgramFiles%\Texter
Gui, Add, Button,w80 GBrowse x320 y29,&Browse
Gui,Add,Text,y60 x30,Note: If Texter is currently running, close the program before continuing.
Gui, Add, Button,w80 default GInstall x225 yp+50,&Install
Gui, Add, Button,w80 xp+90 GCancel,&Cancel
Gui, Show, W400 H140,Install Texter
RETURN

BROWSE:
FileSelectFolder, InstallDir,,1,Select your installation folder
if ErrorLevel = 0
	GuiControl,,InstallDir,%InstallDir%
RETURN

INSTALL:
Gui, Submit
Gui,Destroy
;MsgBox,%InstallDir%
IfNotExist,%InstallDir%
	FileCreateDir,%InstallDir%
FileInstall,texter.exe,%InstallDir%\texter.exe,1
if ErrorLevel = 0
{
	;MsgBox Problem!
	Gui, Add, Text,y10 x10,Texter successfully installed!
	Gui, Add, Checkbox, Checked y30 x20 vLaunch, Click here if you'd like to view the Texter install directory.
	Gui,Add,Text,y45 x45, Double-click texter.exe to launch Texter.
	Gui, Add, Button,w80 default GAutoRun x300 yp+65,&Finish
	Gui, Show, W400 H140,Installation complete
}
;MsgBox, Installed

return

AUTORUN:
Gui,Submit
Gui,Destroy
if Launch = 1
	Run,%InstallDir%\
Goto,Exit
return

CANCEL:
Gui, Destroy
Goto,Exit
return

EXIT:
ExitApp