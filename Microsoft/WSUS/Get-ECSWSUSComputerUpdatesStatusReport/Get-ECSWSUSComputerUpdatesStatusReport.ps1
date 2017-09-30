Function Get-ECSWSUSComputerUpdatesStatusReport
    {
    [cmdletbinding()]
    Param
	    (
   	    [Parameter(Mandatory=$true)]
   	    [string]$WSUSDataBaseServerName,
	    [Parameter(Mandatory=$true)]
	    [string]$WSUSDataBaseName,
	    [Parameter(Mandatory=$true)]
	    $WSUSComputerObject, #This should be the FULL object from Get-ECSWSUSComputersInTargetGroup or Get-ECSWSUSComputer
        [Parameter(Mandatory=$false)]
	    [string]$SQLQueryTimeoutSeconds = 30
	    )
     
###############################################################################################################################################  
#Defining static and dynamic parameters

    #Static Parameters
    $SQLQueryToGetComputerUpdateStatusDetails = @"
DECLARE @ComputerTargetId nvarchar(255);
SET @ComputerTargetId = '$($WSUSComputerObject.ComputerTargetId)';

use [$($WSUSDataBaseName)]
SELECT [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateInstallationInfo].[UpdateId]
      ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateInstallationInfo].[State]

	  ,sv.Name as FriendlyState

	  ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateEffectiveApprovalPerComputer].[UpdateApprovalId]

	  ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateApproval].[Action]

	  ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdate].[DefaultDescription]
	  ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdate].[DefaultTitle]
	  ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdate].[KnowledgebaseArticle]
	  ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdate].[RevisionNumber]
	  ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdate].[UpdateType]
	  ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdate].[IsDeclined]
	
	  ,[$($WSUSDataBaseName)].[dbo].[tbTargetGroup].[Name] as TargetGroupName

	  ,[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vClassification].[DefaultTitle] as ClassifacationTitle
	  
  FROM [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateInstallationInfo]

--Getting a list of update installation state for all updates that are not applicable
INNER JOIN [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget] ON 
	(
	[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateInstallationInfo].[ComputerTargetId] = [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[ComputerTargetId]
	)

--This gives us the friendly name for the state of the installation
Inner Join PUBLIC_VIEWS.fnUpdateInstallationStateMap() as sv on [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateInstallationInfo].[State] = sv.Id

--Getting the update approval IDs
Full Outer JOIN [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateEffectiveApprovalPerComputer] ON
	(
	[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateEffectiveApprovalPerComputer].[ComputerTargetId] = [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateInstallationInfo].[ComputerTargetId] 
	and	
	[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateEffectiveApprovalPerComputer].[UpdateId] = [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateInstallationInfo].[UpdateId]

	)

--Getting the update approval action
Full Outer JOIN [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateApproval] ON 
	(
	[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateApproval].[UpdateApprovalId] = [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateEffectiveApprovalPerComputer].UpdateApprovalId 
	)

--Getting update details
Full Outer JOIN [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdate] ON 
	(
	[$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdate].[UpdateId] = [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateInstallationInfo].[UpdateId]
	)

--This gives us the computer target group mapping for each update approval
Full Outer JOIN [$($WSUSDataBaseName)].[dbo].[tbTargetGroup] ON [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdateApproval].[ComputerTargetGroupId]=[$($WSUSDataBaseName)].[dbo].[tbTargetGroup].[TargetGroupID]

Inner Join [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vClassification] on [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vUpdate].[ClassificationId] = [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vClassification].[ClassificationId]

Where [$($WSUSDataBaseName)].[PUBLIC_VIEWS].[vComputerTarget].[ComputerTargetId] = @ComputerTargetId and state != 1
"@ 

#END Defining static and dynamic parameters
###############################################################################################################################################  

###############################################################################################################################################  
#Announce Parameters

    Write-verbose "WSUSDataBaseServerName = $($WSUSDataBaseServerName)"
    Write-verbose "WSUSDataBaseName = $($WSUSDataBaseName)"
    Write-Verbose "Computer Name = $($WSUSComputerObject.name)"
    Write-verbose "SQLQueryTimeoutSeconds  = $($SQLQueryTimeoutSeconds )"
    Write-verbose "SQLQueryToGetComputerUpdateStatusDetails = $($SQLQueryToGetComputerUpdateStatusDetails)"
    
#END Announce Parameters
###############################################################################################################################################  

###############################################################################################################################################  
#Grabbing the status of all updates

    #Now let's execute the query
    Try
        {
        Write-Verbose "Executing query for $($WSUSComputerObject.name),"
        $UpdateStatusDetails = Invoke-ECSSQLQuery -DatabaseServer $WSUSDataBaseServerName -DatabaseName $WSUSDataBaseName -SQLQuery $SQLQueryToGetComputerUpdateStatusDetails -Timeout $SQLQueryTimeoutSeconds | Select-Object UpdateId,State,FriendlyState,UpdateApprovalId,Action,DefaultTitle,DefaultDescription,KnowledgebaseArticle,RevisionNumber,UpdateType,IsDeclined,TargetGroupName,ClassifacationTitle
        $UpdateStatusDetailsCount = $UpdateStatusDetails | Measure-Object | Select-Object -ExpandProperty count
        Write-Verbose "Query completed, checking that we have at least one result"
        If (($UpdateStatusDetailsCount | Measure-Object | Select-Object -ExpandProperty Count) -le 0)
            {
            Write-Verbose "No update results found after executing query"
            Throw "No updates returned, something isn't right, and I have no idea offhand"
            }
        Else
            {
            Write-Verbose "We have valid results moving on"
            }
        }
    Catch
        {
        Write-Verbose -Message "Something went wrong getting the update details for the computer"
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
        write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
        Throw "Failed to get a list of updates for the computer $($WSUSComputerObject.name), See above for the failure reason"
        }
    

#END Grabbing the status of all updates
###############################################################################################################################################  

###############################################################################################################################################  
#Doing some calculations and what not to provide summary details

    #Now we'll group the updates based on thier friendly state
    Write-Verbose "Grouping Update friendly state"
    $GroupedFriendlyState = $UpdateStatusDetails | Group-Object FriendlyState
    Write-Verbose "Generating summary data"

    #Array to Store update status summary
    $UpdateStatusCount = New-Object System.Collections.ArrayList

    #Unkown status
    If (($GroupedFriendlyState | Where-Object {$_.name -eq "Unknown"}) -eq $null)
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "Unknown"
            StatusCount = 0
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
            
        }
    Else
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "Unknown"
            StatusCount = $GroupedFriendlyState | Where-Object {$_.name -eq "Unknown"} | Select-Object -ExpandProperty Count
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
        }

    #NotInstalled status
    If (($GroupedFriendlyState | Where-Object {$_.name -eq "NotInstalled"}) -eq $null)
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "NotInstalled"
            StatusCount = 0
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
        }
    Else
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "NotInstalled"
            StatusCount = $GroupedFriendlyState | Where-Object {$_.name -eq "NotInstalled"} | Select-Object -ExpandProperty Count
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
        }

    #Downloaded status
    If (($GroupedFriendlyState | Where-Object {$_.name -eq "Downloaded"}) -eq $null)
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "Downloaded"
            StatusCount = 0
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
        }
    Else
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "Downloaded"
            StatusCount = $GroupedFriendlyState | Where-Object {$_.name -eq "Downloaded"} | Select-Object -ExpandProperty Count
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
        }
        
    #Installed status
    If (($GroupedFriendlyState | Where-Object {$_.name -eq "Installed"}) -eq $null)
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "Installed"
            StatusCount = 0
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
        }
    Else
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "Installed"
            StatusCount = $GroupedFriendlyState | Where-Object {$_.name -eq "Installed"} | Select-Object -ExpandProperty Count
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
        }

    #Failed status
    If (($GroupedFriendlyState | Where-Object {$_.name -eq "Failed"}) -eq $null)
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "Failed"
            StatusCount = 0
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
        }
    Else
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "Failed"
            StatusCount = $GroupedFriendlyState | Where-Object {$_.name -eq "Failed"} | Select-Object -ExpandProperty Count
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
        }

    #InstalledPendingReboot status
    If (($GroupedFriendlyState | Where-Object {$_.name -eq "InstalledPendingReboot"}) -eq $null)
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "InstalledPendingReboot"
            StatusCount = 0
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
        }
    Else
        {
        $UpdateStatus  = New-Object PSObject -Property @{
            StatusType = "InstalledPendingReboot"
            StatusCount = $GroupedFriendlyState | Where-Object {$_.name -eq "InstalledPendingReboot"} | Select-Object -ExpandProperty Count
            }
        $NullUpdateStatus = $UpdateStatusCount.Add($UpdateStatus)
        }

    #Generating an overall status
    $AllPossiableUpdatesNotInstalledCount = $UpdateStatusDetails | Where-Object {$_.FriendlyState -ne "Installed"} | Measure-Object | Select-Object -ExpandProperty Count

    If ($AllPossiableUpdatesNotInstalledCount -eq 0)
        {
        $AllPossiableUpdatesInstalled = $true
        }
    Else
        {
        $AllPossiableUpdatesInstalled = $false
        }
    
    #This targets updates that we've approved.  if this equals zero we're good
    $AllApprovedUpdatesNotInstalledCount = $UpdateStatusDetails | Where-Object {$_.Action -eq "Install" -and $_.FriendlyState -ne "Installed"} | Measure-Object | Select-Object -ExpandProperty Count

    If ($AllApprovedUpdatesNotInstalledCount  -eq 0)
        {
        $AllApprovedUpdatesInstalled = $true
        }
    Else
        {
        $AllApprovedUpdatesInstalled = $false
        }


#END Doing some calculations and what not to provide summary details
###############################################################################################################################################    

###############################################################################################################################################  
#Putting everything together

    #Now let's create a custom object to store the results:
    Write-Verbose "Creating an object to organize the results"
    $FinalResult = New-Object PSObject -Property @{
        Name = $WSUSComputerObject.Name
        AllPossiableUpdatesInstalled = $AllPossiableUpdatesInstalled
        AllApprovedUpdatesInstalled = $AllApprovedUpdatesInstalled
        AllPossiableUpdatesNotInstalledCount = $AllPossiableUpdatesNotInstalledCount
        AllApprovedUpdatesNotInstalledCount = $AllApprovedUpdatesNotInstalledCount
        LastSyncResult = [String]$WSUSComputerObject.LastSyncResult
        LastSyncTime = [String]$WSUSComputerObject.LastSyncTime
        LastReportedStatusTime = [String]$WSUSComputerObject.LastReportedStatusTime
        LastReportedInventoryTime = [String]$WSUSComputerObject.LastReportedInventoryTime
        UpdateStatusSummary = $UpdateStatusCount 
        UpdateStatusDetailed = $UpdateStatusDetails
        ClientVersion = [String]$WSUSComputerObject.ClientVersion
        ComputerTargetId = [String]$WSUSComputerObject.ComputerTargetId
        SystemInformation = New-Object PSObject -Property @{
            IPAddress = [String]$WSUSComputerObject.IPAddress
            OSArchitecture = [String]$WSUSComputerObject.OSArchitecture
            Make = [String]$WSUSComputerObject.Make
            Model = [String]$WSUSComputerObject.Model
            BiosName = [String]$WSUSComputerObject.BiosName
            BiosVersion = [String]$WSUSComputerObject.BiosVersion
            BiosReleaseDate = [String]$WSUSComputerObject.BiosReleaseDate
            OSMajorVersion = [String]$WSUSComputerObject.OSMajorVersion
            OSMinorVersion = [String]$WSUSComputerObject.OSMinorVersion
            OSBuildNumber = [String]$WSUSComputerObject.OSBuildNumber
            OSServicePackMajorNumber = [String]$WSUSComputerObject.OSServicePackMajorNumber
            OSDefaultUILanguage = [String]$WSUSComputerObject.OSDefaultUILanguage
            }
        
        }
        
    $FinalResult | Select-Object Name,AllPossiableUpdatesInstalled,AllApprovedUpdatesInstalled,AllPossiableUpdatesNotInstalledCount,AllApprovedUpdatesNotInstalledCount,LastSyncResult,LastSyncTime,LastReportedStatusTime,LastReportedInventoryTime,UpdateStatusSummary,UpdateStatusDetailed,ClientVersion,ComputerTargetId,SystemInformation

    Write-Verbose "Report DONE!"
    }
#END Putting everything together
###############################################################################################################################################      