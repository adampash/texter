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
	;FileInstall,Active\Autocorrect\pipelist.txt,Active\Autocorrect\pipelist.txt,1
	;FileInstall,Active\Autocorrect\autocorrect.csv,Active\Autocorrect\autocorrect.csv,1
	Gosub,InstallAutocorrect
}
return
