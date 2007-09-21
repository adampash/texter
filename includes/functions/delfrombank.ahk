DelFromBank(HotString, Bundle, Trigger)
{
	BankFile = %Bundle%bank\%trigger%.csv
	FileRead, Bank, %BankFile%
	;HotString:=Dehexify(HotString)
	if HotString in %Bank%
	{
		StringReplace, Bank, Bank, %HotString%`,,,All
		FileDelete, %BankFile%
		FileAppend,%Bank%, %BankFile%
	}
}