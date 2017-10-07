Get-ECSWSUSComputer

About:
This function has limited function by its self, but who am I to judge.  This function will return a list of all WSUS comptuers based on your naming pattern.  The WSUSComputerName param supports wildcards in the form of "*" or "%".  So if you wanted all computers that started with pc-, simply put pc-*.

The main purpose of the function is to feed the Get-ECSWSUSComputerUpdatesStatusReport function with a list of computers that you want to report on.

Syntax example for windows auth:
Get-ECSWSUSComputer -WSUSDataBaseServerName "Database Server Name" -WSUSDataBaseName "SUSDB or whatever you called it" -WSUSComputerName "ComputerName or Computer Name pattern" -SQLQueryTimeoutSeconds "Optional, enter time in seconds"

Dependencies:
You'll need my Invoke-ECSSQLQuery function.  You can find that here https://github.com/ericcsinger/Powershell/blob/master/Microsoft/SQL/Invoke-ECSSQLQuery/Invoke-ECSSQLQuery.ps1

If you need to use SQL auth, you can adjust the Get-ECSWSUSComputer to use SQL auth.  Read up on my SQL query function and you'll figure it out.

Optional Parameter:
The timeout is the only optional param.  The default is 30 seconds.  if you have a slow SQL server or something else related to SQL causing a timeout error, you can use this param to increase the time out.  Setting it to "0" equals no timeout.

For more information, contact the author here http://www.ericcsinger.com/powershell-scripting-get-ecswsuscomputer-and-get-ecswsuscomputersintargetgroup/


