DisableChecks:

    CheckedCbox = %A_GuiControl%
    if (CheckedCbox = "NoTrigCbox")
    {
        GuiControl,,EnterCbox,0
        GuiControl,,TabCbox,0
        GuiControl,,SpaceCbox,0
    }
    else
    {
        GuiControl,,NoTrigCbox,0
    }
return