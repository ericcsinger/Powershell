Function Get-ECSWSUSComputer
    {
    [cmdletbinding()]
    Param
	    (
   	    [Parameter(Mandatory=$true)]
   	    [string]$WSUSDataBaseServerName,
	    [Parameter(Mandatory=$true)]
	    [string]$WSUSDataBaseName,
	    [Parameter(Mandatory=$true)]
	    [string]$WSUSComputerName,
        [Parameter(Mandatory=$false)]
	    [string]$SQLQueryTimeoutSeconds = 30
	    )
     
###############################################################################################################################################  
#Defining static and dynamic parameters

    #Dynamic Parameters
    $WSUSComputerName = $WSUSComputerName -replace "\*","%"  #SQL's wildcard is a % symbol, I'm assuming if someone entered a * they really meant %

    #Static Parameters
    $ComputerCounter = 1
    $SQLQueryToGetListOfComputerDetails =  @"
DECLARE @Name nvarchar(255);
SET @Name = '$($WSUSComputerName)';

SELECT [ComputerTargetId]
      ,[ParentServerId]
      ,[Name]
      ,[IPAddress]
      ,[LastSyncResult]
      ,[LastSyncTime]
      ,[LastReportedStatusTime]
      ,[LastReportedInventoryTime]
      ,[ClientVersion]
      ,[OSArchitecture]
      ,[Make]
      ,[Model]
      ,[BiosName]
      ,[BiosVersion]
      ,[BiosReleaseDate]
      ,[OSMajorVersion]
      ,[OSMinorVersion]
      ,[OSBuildNumber]
      ,[OSServicePackMajorNumber]
      ,[OSDefaultUILanguage]
  FROM [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget]
  where Name like @Name
"@ #This will get a list of all computer details, plus give us the computer target ID which we'll need to make all the magic happen

#END Defining static and dynamic parameters
###############################################################################################################################################  

###############################################################################################################################################  
#Anoucing running values

    #In verbose mode we'll anonouce the values of all the parameters
    Write-Verbose "WSUS Database Server Name = $($WSUSDataBaseServerName)"
    Write-Verbose "WSUS Database Name = $($WSUSDataBaseName)"
    Write-Verbose "WSUS Computer Name = $($WSUSComputerName)"
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
