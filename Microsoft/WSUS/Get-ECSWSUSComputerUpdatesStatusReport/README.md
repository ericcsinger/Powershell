Get-ECSWSUSComputerUpdatesStatusReport

About:
This function will return a status report of all updates that are applicable to a given computer.  I show you the approved update status as well as the non-approved.  I wrote this query to help automate patching (checking the status) but also because it's WAY faster to query SQL direct than wait on the WSUS web app.

This function will return an object with sub-objects.  My suggestion is if you need to export the info, dump it to a JSON or XML.

Syntax example for windows auth:
Get-ECSWSUSComputerUpdatesStatusReport -WSUSDataBaseServerName "Database Server Name" -WSUSDataBaseName "SUSDB or whatever you called it" -WSUSComputerObject $ObjectFromtheGetECSWSUSComputerorTarget -SQLQueryTimeoutSeconds "Optional, enter time in seconds"

Dependencies:
You'll need my Invoke-ECSSQLQuery function.  You can find that here https://github.com/ericcsinger/Powershell/blob/master/Microsoft/SQL/Invoke-ECSSQLQuery/Invoke-ECSSQLQuery.ps1
If you need to use SQL auth, you can adjust the Get-ECSWSUSComputersInTargetGroup to use SQL auth.  Read up on my SQL query function and you'll figure it out.

This function requires that you capture the output of the Get-ECSWSUSComputersInTargetGroup or Get-ECSWSUSComputers.  This function only looks at a singular object.  So if you have an array of computers you want to check, do a foreach loop.

Optional Parameter:
The timeout is the only optional param.  The default is 30 seconds.  if you have a slow SQL server or something else related to SQL causing a timeout error, you can use this param to increase the time out.  Setting it to "0" equals no timeout.

For more information, contact the author here http://www.ericcsinger.com/powershell-scripting-get-ecswsuscomputerupdatesstatusreport/



