DISABLE:
IniRead,disable,texter.ini,Settings,Disable
if Disable = 0
{
	IniWrite,1,texter.ini,Settings,Disable
;	EnableTriggers(false)
	Menu,Tray,Check,&Disable
	Disable = 1
	Send,{%SpecialKey%}
}
else
{
	IniWrite,0,texter.ini,Settings,Disable
;	EnableTriggers(true)
	Menu,Tray,Uncheck,&Disable
	Disable = 0
}
return