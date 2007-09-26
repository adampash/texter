#IfWinActive,Texter Management
Ins & LWin::
Ins & Rwin::
SendRaw,#
return

Ins & Shift::SendRaw,+
Ins & Ctrl::SendRaw,^
Ins & Alt::SendRaw,!
Ins & i::SendRaw,{Ins}

Ins & F1::
Ins & F2::
Ins & F3::
Ins & F4::
Ins & F5::
Ins & F6::
Ins & F7::
Ins & F8::
Ins & F9::
Ins & F10::
Ins & F11::
Ins & F12::
Ins & !::
Ins & #::
Ins & +::
Ins & ^::
Ins & {::
Ins & }::
Ins & Enter::
Ins & Esc::
Ins & Space::
Ins & Tab::
Ins & BS::
Ins & Del::
Ins & Up::
Ins & Down::
Ins & Left::
Ins & Right::
Ins & Home::
Ins & End::
Ins & PgUp::
Ins & PgDn::
Ins & CapsLock::
Ins & ScrollLock::
Ins & NumLock::
Ins & AppsKey::
Ins & PrintScreen::
Ins & Pause::
Ins & WheelDown::
Ins & WheelUp::
Ins & LButton::
Ins & RButton::
InsText:="Ins & "
StringReplace,SpecKey,A_ThisHotkey,%InsText%,,
SendRaw,{%SpecKey%}
return
#IfWinActive