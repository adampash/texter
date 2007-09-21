DISABLE:
IniRead,disable,texter.ini,Settings,Disable
if disable = 0
{
	IniWrite,1,texter.ini,Settings,Disable
	EnableTriggers(false)
	Menu,Tray,Check,&Disable
}
else
{
	IniWrite,0,texter.ini,Settings,Disable
	EnableTriggers(true)
	Menu,Tray,Uncheck,&Disable
}
return