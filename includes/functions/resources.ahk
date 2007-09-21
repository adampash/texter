RESOURCES:
;code optimization -- removed IfNotExist tests
;redundant when final arg to FileInstall is 0
FileInstall,resources\texter.ico,%TexterICO%,1
FileInstall,resources\replace.wav,%ReplaceWAV%,0
FileInstall,resources\texter.png,%TexterPNG%,1
FileInstall,resources\style.css,%StyleCSS%,0
return
