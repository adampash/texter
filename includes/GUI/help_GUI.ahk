HELP:
Gui,5: Destroy
Gui,5: +owner
Gui,5: Add,Picture,x200 y5,%TexterPNG%
Gui,5: font, s36, Courier New
Gui,5: Add, Text,x20 y40,Texter
Gui,5: font, s9, Arial 
Gui,5: Add,Text,x19 y285 w300 center,All of Texter's documentation can be found online at the
Gui,5:Font,underline bold
Gui,5:Add,Text,cBlue gHomepage Center x125 y305,Texter homepage
Gui,5: font, s9 norm, Arial 
Gui,5: Add,Text,x10 y100 w300,For help by topic, click on one of the following:
Gui,5:Font,underline bold
Gui,5:Add,Text,x30 y120 cBlue gBasicUse,Basic Use: 
Gui,5:Font,norm
Gui,5:Add,Text,x50 y140 w280, Covers how to create basic text replacement hotstrings.
Gui,5:Font,underline bold
Gui,5:Add,Text,x30 y180 cBlue gScripting,Sending advanced keystrokes: 
Gui,5:Font,norm
Gui,5:Add,Text,x50 y200 w280, Texter is capable of sending advanced keystrokes, like keyboard combinations.  This section lists all of the special characters used in script creation, and offers a few examples of how you might use scripts.
Gui,5: Color,F8FAF0
Gui,5: Show,auto,Texter Help
Return

5GuiEscape:
DismissHelp:
Gui,5: Destroy
return
