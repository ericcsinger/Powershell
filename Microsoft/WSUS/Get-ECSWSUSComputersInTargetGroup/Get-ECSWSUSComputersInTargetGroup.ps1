Function Get-ECSWSUSComputersInTargetGroup
    {
    [cmdletbinding()]
    Param
	    (
   	    [Parameter(Mandatory=$true)]
   	    [string]$WSUSDataBaseServerName,
	    [Parameter(Mandatory=$true)]
	    [string]$WSUSDataBaseName,
	    [Parameter(Mandatory=$true)]
	    [string]$WSUSComputerTargetGroupName,
        [Parameter(Mandatory=$false)]
	    [string]$SQLQueryTimeoutSeconds = 30
	    )
     
###############################################################################################################################################  
#Defining static and dynamic parameters

    #Dynamic Parameters
    $WSUSComputerTargetGroupName = $WSUSComputerTargetGroupName -replace "\*","%"  #SQL's wildcard is a % symbol, I'm assuming if someone entered a * they really meant %

    #Static Parameters
    $ComputerCounter = 1
    $SQLQueryToGetListOfComputerDetails =  @"
DECLARE @ComputerTargetGroupName nvarchar(255);
SET @ComputerTargetGroupName = '$($WSUSComputerTargetGroupName)';

SELECT [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[ComputerTargetId]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[ParentServerId]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[Name]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[IPAddress]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[LastSyncResult]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[LastSyncTime]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[LastReportedStatusTime]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[LastReportedInventoryTime]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[ClientVersion]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[OSArchitecture]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[Make]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[Model]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[BiosName]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[BiosVersion]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[BiosReleaseDate]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[OSMajorVersion]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[OSMinorVersion]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[OSBuildNumber]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[OSServicePackMajorNumber]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[OSDefaultUILanguage]

	  ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTargetGroup].[Name] as ComputerTargetGroupName
FROM [$($WSUSDataBaseName)].[dbo].[tbTargetInTargetGroup]

--Getting the Computer Target ID
Inner join [$($WSUSDataBaseName)].[dbo].[tbComputerTarget] on [$($WSUSDataBaseName)].[dbo].[tbComputerTarget].[TargetID] = [$($WSUSDataBaseName)].[dbo].[tbTargetInTargetGroup].[TargetID]

--Getting Computer Target Info
Inner join [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget] on [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[ComputerTargetId] = [$($WSUSDataBaseName)].[dbo].[tbComputerTarget].[ComputerID]

--Getting Computer Target Group Name
Inner join [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTargetGroup] on [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTargetGroup].[ComputerTargetGroupId] = [$($WSUSDataBaseName)].[dbo].[tbTargetInTargetGroup].[TargetGroupID]

Where [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTargetGroup].[Name] like @ComputerTargetGroupName
"@ #This will get a list of all computer details, plus give us the computer target ID which we'll need to make all the magic happen

#END Defining static and dynamic parameters
###############################################################################################################################################  

###############################################################################################################################################  
#Anoucing running values

    #In verbose mode we'll anonouce the values of all the parameters
    Write-Verbose "WSUS Database Server Name = $($WSUSDataBaseServerName)"
    Write-Verbose "WSUS Database Name = $($WSUSDataBaseName)"
    Write-Verbose "WSUS Computer Name = $($WSUSComputerTargetGroupName)"
    Write-Verbose "SQL Query Timeout Seconds = $($SQLQueryTimeoutSeconds)"
    Write-Verbose "SQL Query To Get List Of ComputerDetails = $($SQLQueryToGetListOfComputerDetails)"

#END Anoucing running values
###############################################################################################################################################  

###############################################################################################################################################  
#Checking if dependent functon(s) loaded

    #Let's make sure the Invoke-ECSSQLQuery, this function depends on it
    Try
        {
        Write-Verbose -Message "Checking if Invoke-ECSSQLQuery is loaded"
        $TestCommandExists = Get-Command -Name Invoke-ECSSQLQuery -ErrorAction Stop
        Write-Verbose -Message "Invoke-ECSSQLQuery is loaded"
        }
    Catch
        {
        Write-Verbose -Message "Invoke-ECSSQLQuery is NOT loaded, begining exception throw"
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
        write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
        Throw "Please make sure you have the function Invoke-ECSSQLQuery loaded before attempting to run this function"
        }

#END Checking if dependent functon(s) loaded 
###############################################################################################################################################  

###############################################################################################################################################  
#Grabbing all computers that match the name query

    #Getting a list of computers and their details
    Try
        {
        Write-Verbose "Getting a list of computers"
        $ListOfComputerDetails = Invoke-ECSSQLQuery -DatabaseServer $WSUSDataBaseServerName -DatabaseName $WSUSDataBaseName -SQLQuery $SQLQueryToGetListOfComputerDetails -Timeout $SQLQueryTimeoutSeconds -ErrorAction Stop
        Write-Verbose "Query Completed without errors, checking if there are results"
        
        If (($ListOfComputerDetails | Measure-Object | Select-Object -ExpandProperty count) -le 0)
            {
            Write-Verbose "No computers returned in the query, somethings wrong with you string"
            Throw "After executing the query to get a list of computers, we found no results, please check your string and make sure the computer(s) should exist"
            }
        Else
            {
            Write-Verbose "We found at least one computer, outputting results to screen"
            $ListOfComputerDetails
            }
        }
    Catch
        {
        Write-Verbose -Message "Something went wrong getting a list of computers, begining exception throw"
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
        write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
        Throw "Failed to get a list of computers, See above for the failure reason"
        }
    }
#END Grabbing all computers that match the name query
###############################################################################################################################################  