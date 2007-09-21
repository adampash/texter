AddToBank(HotString, Bundle, Trigger)
{
	;HotString:=Dehexify(HotString)
	BankFile = %Bundle%bank\%trigger%.csv
	FileRead, Bank, %BankFile%
	if HotString not in %Bank%
	{
		FileAppend,%HotString%`,, %BankFile%
		FileRead, Bank, %BankFile%
	}
}