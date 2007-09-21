;; method written by Dustin Luck for writing to ini
GetValFromIni(section, key, default)
{
	IniRead,IniVal,texter.ini,%section%,%key%
	if IniVal = ERROR
	{
		IniWrite,%default%,texter.ini,%section%,%key%
		IniVal := default
	}
	return IniVal
}
