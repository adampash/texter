AddToBank(HotString, Bundle, Trigger)
{
	;HotString:=Dehexify(HotString)
	BankFile = %Bundle%bank\%trigger%.csv
	IfNotExist %BankFile%
	{
	  FileAppend,, %BankFile%
	}
	FileRead, Bank, %BankFile%
	if HotString not in %Bank%
	{
		FileAppend,%HotString%`,, %BankFile%
		FileRead, Bank, %BankFile%
	}
}