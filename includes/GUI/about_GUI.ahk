ABOUT:
Gui,4: Destroy
Gui,4: +owner
Gui,4: Add,Picture,x200 y0,%TexterPNG%
Gui,4: font, s36, Courier New
Gui,4: Add, Text,x10 y35,Texter
Gui,4: font, s8, Courier New
Gui,4: Add, Text,x171 y77,%Version%
Gui,4: font, s9, Arial 
Gui,4: Add,Text,x10 y110 Center,Texter is a text replacement utility designed to save`nyou countless keystrokes on repetitive text entry by`nreplacing user-defined abbreviations (or hotstrings)`nwith your frequently-used text snippets.`n`nTexter is written by Adam Pash and distributed`nby Lifehacker under the GNU Public License.`nFor details on how to use Texter, check out the
Gui,4:Font,underline bold
Gui,4:Add,Text,cBlue gHomepage Center x110 y230,Texter homepage
Gui,4: Color,F8FAF0
Gui 2:+Disabled
Gui,4: Show,auto,About Texter
Return

4GuiClose:
4GuiEscape:
DismissAbout:
Gui 2:-Disabled
Gui,4: Destroy
return
