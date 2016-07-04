Function Invoke-ECSSQLQuery
    {
    <#
  	.SYNOPSIS
  	This function is used to execute a SQL query via Powershell.


    There are three required parameters, DatabaseServer, DatabaseName and the SQLQuery.  By default, the fuction users windows auth.  If you need SQL auth, simply specify the...
    SQLUserID and the SQLUserPassword.  The final parameter is the timeout.  By default its set to 30 seconds.  If you want an unlimited timeout, specify the parameter with...
    a 0 or the the timeout value you want to use in seconds.  

    To access a non-default SQL instance, simply use SQLServerName\InstanceName in the DatabaseServerName parameter

    The query its self should be a string like "Select * from table where column = 'value'".  The other option is using a multi-line string such as...

    $SQLQuery = @"
SELECT 
      [ComputerID]
      ,[SID]
      ,[LastSyncTime]
      ,[LastReportedStatusTime]
      ,[LastReportedRebootTime]
      ,[IPAddress]
      ,[FullDomainName]
      ,[IsRegistered]
      ,[LastInventoryTime]
      ,[LastNameChangeTime]
      ,[EffectiveLastDetectionTime]
      ,[ParentServerTargetID]
      ,[LastSyncResult]
	  ,[SUSDB].[dbo].[tbExpandedTargetInTargetGroup].TargetGroupID
	  ,[SUSDB].[PUBLIC_VIEWS].[vComputerTargetGroup].[Name]
	  
  FROM [SUSDB].[dbo].[tbComputerTarget]

  INNER JOIN [SUSDB].[dbo].[tbExpandedTargetInTargetGroup] ON 
	(
	[SUSDB].[dbo].[tbComputerTarget].[TargetID] = [SUSDB].[dbo].[tbExpandedTargetInTargetGroup].[TargetID]
	)

	INNER JOIN [SUSDB].[PUBLIC_VIEWS].[vComputerTargetGroup] ON 
	(
	[SUSDB].[PUBLIC_VIEWS].[vComputerTargetGroup].[ComputerTargetGroupId] = [SUSDB].[dbo].[tbExpandedTargetInTargetGroup].[TargetGroupID]
	)

"@


    Question or comments, see http://ericcsinger.com, but I did not write the the core powershell code that's in here, I simply adapated...
    something I found on the internet, and turned it into a function.


    Version 0.1  
  	#>
    Param
	    (
   	    [Parameter(Mandatory=$true)]
   	    [string]$DatabaseServer,
	    [Parameter(Mandatory=$true)]
	    [string]$DatabaseName,
        [Parameter(Mandatory=$true)]
	    [string]$SQLQuery = $null,
	    [Parameter(Mandatory=$false)]
	    [string]$SQLUserID = $null,
	    [Parameter(Mandatory=$false)]
	    [string]$SQLUserPassword = $null,
        [Parameter(Mandatory=$false)]
	    [int]$Timeout = 30
	    )
    
    #Creating the SQL connection object
    $SQLConnection = New-Object System.Data.SqlClient.SqlConnection

    #Determine if we're using SQL auth or Windows auth.  By default, windows auth is used.  if a SQL username is specified, we'll use SQL auth.
    If ($SQLUserID -ne $null)
        {
        $SQLConnection.ConnectionString = "Data Source=""$DatabaseServer""; Initial Catalog=""$DatabaseName""; Integrated Security=True"
        }
    Else
        {
        $SQLConnection.ConnectionString = "Data Source=""$DatabaseServer""; Initial Catalog=""$DatabaseName""; User ID=""$SQLUserID""; Password=""$SQLUserPassword"""
        }


    #Create command object
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand

    #Set the command object
    $SqlCmd.CommandText = $SQLQuery
    $SqlCmd.Connection = $SqlConnection
    $SqlCmd.CommandTimeout = $Timeout

    #Create SQL adapter object
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter

    #Set the SQL adapter
    $SqlAdapter.SelectCommand = $SqlCmd

    #Execute the command
    #DataSet = New-Object System.Data.DataSet
    $DataSet = new-object system.data.datatable
    
    #Data will reside the var $dataset
    $SqlAdapter.Fill($DataSet) | Out-Null

    #Close connection to SQL
    $SqlConnection.Close()

    #output results
    $DataSet

    }