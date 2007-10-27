RESOURCES:
;code optimization -- removed IfNotExist tests
;redundant when final arg to FileInstall is 0
IfNotExist bank
	FileCreateDir, bank
IfNotExist replacements
	FileCreateDir, replacements
IfNotExist bundles
	FileCreateDir, bundles
IfNotExist resources
	FileCreateDir, resources
FileInstall,resources\texter.ico,%TexterICO%,1
FileInstall,resources\replace.wav,%ReplaceWAV%,0
FileInstall,resources\texter.png,%TexterPNG%,1
FileInstall,resources\style.css,%StyleCSS%,0
FileInstall,resources\throbber.gif,%Throbber%,1
Gui,10: Destroy
Gui,10: +owner
Gui,10: Add, Text, x5 y10, Loading...
;Gui,10: Add,Picture,x60 y10,%Throbber%
Gui,10: Add,Picture,x200 y0,%TexterPNG%
Gui,10: font, s36, Courier New
Gui,10: Add, Text,x10 y35,Texter
Gui,10: font, s8, Courier New
Gui,10: Add, Text,x171 y77,%Version%
Gui,10: font, s9, Arial 
Gui,10: Add,Text,x10 y110 Center,Texter is initializing. This will only happen once.
Gui,10: Color,F8FAF0
Gui 2:+Disabled
Gui,10: Show,auto,About Texter
IfNotExist Active
{
	FileCreateDir, Active
	FileCreateDir, Active\replacements
	FileCreateDir, Active\bank
}
IfNotExist Active\Autocorrect
{
	FileCreateDir, Active\Autocorrect
	FileCreateDir, Active\Autocorrect\replacements
	FileInstall,resources\autocorrect.txt,resources\autocorrect.txt,1
	FileInstall,Active\Autocorrect\pipelist.txt,Active\Autocorrect\pipelist.txt,1
	FileInstall,Active\Autocorrect\autocorrect.csv,Active\Autocorrect\autocorrect.csv,1
	Gosub,InstallAutocorrect
}
Gui,10: Destroy
return
