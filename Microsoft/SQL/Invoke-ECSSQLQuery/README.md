#powershell_microsoft_SQL_Invoke-ECSSQLQuery
A simple function that is used to execute a SQL query in Powershell.  

The main purpose is to retrieve data in powershell from SQL for use in other purposes, but it can be used for anything that's executed via a SQL query.

Syntax example for windows auth:
Invoke-ECSSQLQuery -DatabaseServer "ServerNameonly or ServerName\Instance" -DatabaseName "database" -SQLQuery "select column from table where column = '3'"

Syntax example for SQL auth:
Invoke-ECSSQLQuery -DatabaseServer "ServerNameOnly or ServerName\Instance" -DatabaseName "database" -SQLUserID "SA" -SQLUserPassword "Password" -SQLQuery "select column from table where column = '3'"

There is also an optional timeout parameter that can be used for long running queries.  Setting the parameter to 0 = no time out.  Default is 30.

For more information, contact the author at http://www.ericcsinger.com/powershell-scripting-invoke-ecssqlquery/

The basic structure of the query is not mine, its borrowed from random websites out on the web.  All I did was put it into a function.
