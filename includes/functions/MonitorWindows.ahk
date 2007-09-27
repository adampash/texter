MonitorWindows:
WinGet CurrWinID, ID, A
;Tooltip, CurrWinID= %CurrWinID% ~ PrevWinID= %PrevWinID%
if (CurrWinID <> PrevWinID)
{
  PrevWinID = %CurrWinID%
  PossibleMatch=
}
return
