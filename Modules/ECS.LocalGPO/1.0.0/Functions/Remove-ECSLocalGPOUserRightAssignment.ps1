Function Remove-ECSLocalGPOUserRightAssignment
    {
    <#
    .SYNOPSIS
    Removes an identity from a Local Group Policy Object (GPO) user right assignments.
    .DESCRIPTION
    Remove-ECSLocalGPOUserRightAssignment will remove an identity to a Local Group Policy Object (GPO) user right assignments.
    This function is useful if you're looking to remove a user right assignments from your local GPO.
    This function utilizes the Windows builtin SecEdit.exe to export the user rights list, and then this function
    parses the exported file. 
    .PARAMETER Identity
    This parameter can be an array of identities. Local, Domain and SIDs are all vailed options.
    .EXAMPLE
    This example removes multiple users to the shutdown right. Both sids and local users.
        Remove-ECSLocalGPOUserRightAssignment -Identity @("PCName\LocalGroup","S-1-5-32-555","domain\exampleuser") -SeShutdownPrivilege
    #>
    [CmdletBinding()]
    Param
	    (
        [Parameter (ParameterSetName='SeNetworkLogonRight')]
        [Parameter (ParameterSetName='SeBackupPrivilege')]
        [Parameter (ParameterSetName='SeChangeNotifyPrivilege')]
        [Parameter (ParameterSetName='SeSystemtimePrivilege')]
        [Parameter (ParameterSetName='SeCreatePagefilePrivilege')]
        [Parameter (ParameterSetName='SeDebugPrivilege')]
        [Parameter (ParameterSetName='SeRemoteShutdownPrivilege')]
        [Parameter (ParameterSetName='SeAuditPrivilege')]
        [Parameter (ParameterSetName='SeIncreaseQuotaPrivilege')]
        [Parameter (ParameterSetName='SeIncreaseBasePriorityPrivilege')]
        [Parameter (ParameterSetName='SeLoadDriverPrivilege')]
        [Parameter (ParameterSetName='SeBatchLogonRight')]
        [Parameter (ParameterSetName='SeServiceLogonRight')]
        [Parameter (ParameterSetName='SeInteractiveLogonRight')]
        [Parameter (ParameterSetName='SeSecurityPrivilege')]
        [Parameter (ParameterSetName='SeSystemEnvironmentPrivilege')]
        [Parameter (ParameterSetName='SeProfileSingleProcessPrivilege')]
        [Parameter (ParameterSetName='SeSystemProfilePrivilege')]
        [Parameter (ParameterSetName='SeAssignPrimaryTokenPrivilege')]
        [Parameter (ParameterSetName='SeRestorePrivilege')]
        [Parameter (ParameterSetName='SeShutdownPrivilege')]
        [Parameter (ParameterSetName='SeTakeOwnershipPrivilege')]
        [Parameter (ParameterSetName='SeDenyNetworkLogonRight')]
        [Parameter (ParameterSetName='SeDenyInteractiveLogonRight')]
        [Parameter (ParameterSetName='SeUndockPrivilege')]
        [Parameter (ParameterSetName='SeManageVolumePrivilege')]
        [Parameter (ParameterSetName='SeRemoteInteractiveLogonRight')]
        [Parameter (ParameterSetName='SeImpersonatePrivilege')]
        [Parameter (ParameterSetName='SeCreateGlobalPrivilege')]
        [Parameter (ParameterSetName='SeIncreaseWorkingSetPrivilege')]
        [Parameter (ParameterSetName='SeTimeZonePrivilege')]
        [Parameter (ParameterSetName='SeCreateSymbolicLinkPrivilege')]
        [Parameter (ParameterSetName='SeMachineAccountPrivilege')]
        $Identity,

        [Parameter (ParameterSetName='SeNetworkLogonRight')]
        [switch]$SeNetworkLogonRight,
        [Parameter (ParameterSetName='SeBackupPrivilege')]
        [switch]$SeBackupPrivilege,
        [Parameter (ParameterSetName='SeChangeNotifyPrivilege')]
        [switch]$SeChangeNotifyPrivilege,
        [Parameter (ParameterSetName='SeSystemtimePrivilege')]
        [switch]$SeSystemtimePrivilege,
        [Parameter (ParameterSetName='SeCreatePagefilePrivilege')]
        [switch]$SeCreatePagefilePrivilege,
        [Parameter (ParameterSetName='SeDebugPrivilege')]
        [switch]$SeDebugPrivilege,
        [Parameter (ParameterSetName='SeRemoteShutdownPrivilege')]
        [switch]$SeRemoteShutdownPrivilege,
        [Parameter (ParameterSetName='SeAuditPrivilege')]
        [switch]$SeAuditPrivilege,
        [Parameter (ParameterSetName='SeIncreaseQuotaPrivilege')]
        [switch]$SeIncreaseQuotaPrivilege,
        [Parameter (ParameterSetName='SeIncreaseBasePriorityPrivilege')]
        [switch]$SeIncreaseBasePriorityPrivilege,
        [Parameter (ParameterSetName='SeLoadDriverPrivilege')]
        [switch]$SeLoadDriverPrivilege,
        [Parameter (ParameterSetName='SeBatchLogonRight')]
        [switch]$SeBatchLogonRight,
        [Parameter (ParameterSetName='SeServiceLogonRight')]
        [switch]$SeServiceLogonRight,
        [Parameter (ParameterSetName='SeInteractiveLogonRight')]
        [switch]$SeInteractiveLogonRight,
        [Parameter (ParameterSetName='SeSecurityPrivilege')]
        [switch]$SeSecurityPrivilege,
        [Parameter (ParameterSetName='SeSystemEnvironmentPrivilege')]
        [switch]$SeSystemEnvironmentPrivilege,
        [Parameter (ParameterSetName='SeProfileSingleProcessPrivilege')]
        [switch]$SeProfileSingleProcessPrivilege,
        [Parameter (ParameterSetName='SeSystemProfilePrivilege')]
        [switch]$SeSystemProfilePrivilege,
        [Parameter (ParameterSetName='SeAssignPrimaryTokenPrivilege')]
        [switch]$SeAssignPrimaryTokenPrivilege,
        [Parameter (ParameterSetName='SeRestorePrivilege')]
        [switch]$SeRestorePrivilege,
        [Parameter (ParameterSetName='SeShutdownPrivilege')]
        [switch]$SeShutdownPrivilege,
        [Parameter (ParameterSetName='SeTakeOwnershipPrivilege')]
        [switch]$SeTakeOwnershipPrivilege,
        [Parameter (ParameterSetName='SeDenyNetworkLogonRight')]
        [switch]$SeDenyNetworkLogonRight,
        [Parameter (ParameterSetName='SeDenyInteractiveLogonRight')]
        [switch]$SeDenyInteractiveLogonRight,
        [Parameter (ParameterSetName='SeUndockPrivilege')]
        [switch]$SeUndockPrivilege,
        [Parameter (ParameterSetName='SeManageVolumePrivilege')]
        [switch]$SeManageVolumePrivilege,
        [Parameter (ParameterSetName='SeRemoteInteractiveLogonRight')]
        [switch]$SeRemoteInteractiveLogonRight,
        [Parameter (ParameterSetName='SeImpersonatePrivilege')]
        [switch]$SeImpersonatePrivilege,
        [Parameter (ParameterSetName='SeCreateGlobalPrivilege')]
        [switch]$SeCreateGlobalPrivilege,
        [Parameter (ParameterSetName='SeIncreaseWorkingSetPrivilege')]
        [switch]$SeIncreaseWorkingSetPrivilege,
        [Parameter (ParameterSetName='SeTimeZonePrivilege')]
        [switch]$SeTimeZonePrivilege,
        [Parameter (ParameterSetName='SeCreateSymbolicLinkPrivilege')]
        [switch]$SeCreateSymbolicLinkPrivilege,
        [Parameter (ParameterSetName='SeMachineAccountPrivilege')]
        [switch]$SeMachineAccountPrivilege

	    )

    ##########################################################################################################
    #Dynamic Params

    $TempDirectory = Get-childitem -Path env: | Where-Object {$_.name -eq "temp"} | select-object -ExpandProperty value
    $CurrentDateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $ExportOfSecuritySettingsName = "secedit_userrightassignment_export.tmp"
    $ExportofSecuritySettingsNameAndPath = $TempDirectory + "\" + $CurrentDateTime + "_" + $ExportOfSecuritySettingsName
    $ImportOfSecuritySettingsName = "secedit_userrightassignment_Import.tmp"
    $ImportofSecuritySettingsNameAndPath = $TempDirectory + "\" + $CurrentDateTime + "_" + $ImportOfSecuritySettingsName

    $SecEditStdOutPutFullFileName = $TempDirectory + "\" + $CurrentDateTime + "_" + "SeceditStdOutput.txt"
    $SecEditErrOutPutFullFileName = $TempDirectory + "\" + $CurrentDateTime + "_" + "SeceditErrOutput.txt"
    $FunctionRootPath = $PSScriptRoot
    $PowershellModuleRootPath = $($FunctionRootPath).Replace("\Functions","")
    $UserRightMappingsCSV = $PowershellModuleRootPath + "\Dependent Files\UserRightsMapping.csv"

    $SIDRegexPattern = "S-\d-\d-\d+"
    

    #End Dynamic Parameters
    ##########################################################################################################

    ##########################################################################################################
    #Arrays to store results

    $AllIdentitiesdResults = New-Object System.Collections.ArrayList
    $FinalIdentites = New-Object System.Collections.ArrayList

    #End Arrays to store results
    ##########################################################################################################

    

    ##########################################################################################################
    #Determine which user right selected

    If ($SeNetworkLogonRight -eq $true)
        {
        $UserRightAssignment = "SeNetworkLogonRight"
        }

    If ($SeBackupPrivilege -eq $true)
        {
        $UserRightAssignment = "SeBackupPrivilege"
        }

    If ($SeChangeNotifyPrivilege -eq $true)
        {
        $UserRightAssignment = "SeChangeNotifyPrivilege"
        }

    If ($SeSystemtimePrivilege -eq $true)
        {
        $UserRightAssignment = "SeSystemtimePrivilege"
        }

    If ($SeCreatePagefilePrivilege -eq $true)
        {
        $UserRightAssignment = "SeCreatePagefilePrivilege"
        }

    If ($SeDebugPrivilege -eq $true)
        {
        $UserRightAssignment = "SeDebugPrivilege"
        }

    If ($SeRemoteShutdownPrivilege -eq $true)
        {
        $UserRightAssignment = "SeRemoteShutdownPrivilege"
        }

    If ($SeAuditPrivilege -eq $true)
        {
        $UserRightAssignment = "SeAuditPrivilege"
        }

    If ($SeIncreaseQuotaPrivilege -eq $true)
        {
        $UserRightAssignment = "SeIncreaseQuotaPrivilege"
        }

    If ($SeIncreaseBasePriorityPrivilege -eq $true)
        {
        $UserRightAssignment = "SeIncreaseBasePriorityPrivilege"
        }

    If ($SeLoadDriverPrivilege -eq $true)
        {
        $UserRightAssignment = "SeLoadDriverPrivilege"
        }

    If ($SeBatchLogonRight -eq $true)
        {
        $UserRightAssignment = "SeBatchLogonRight"
        }

    If ($SeServiceLogonRight -eq $true)
        {
        $UserRightAssignment = "SeServiceLogonRight"
        }

    If ($SeInteractiveLogonRight -eq $true)
        {
        $UserRightAssignment = "SeInteractiveLogonRight"
        }

    If ($SeSecurityPrivilege -eq $true)
        {
        $UserRightAssignment = "SeSecurityPrivilege"
        }

    If ($SeSystemEnvironmentPrivilege -eq $true)
        {
        $UserRightAssignment = "SeSystemEnvironmentPrivilege"
        }

    If ($SeProfileSingleProcessPrivilege -eq $true)
        {
        $UserRightAssignment = "SeProfileSingleProcessPrivilege"
        }

    If ($SeSystemProfilePrivilege -eq $true)
        {
        $UserRightAssignment = "SeSystemProfilePrivilege"
        }

    If ($SeAssignPrimaryTokenPrivilege -eq $true)
        {
        $UserRightAssignment = "SeAssignPrimaryTokenPrivilege"
        }

    If ($SeRestorePrivilege -eq $true)
        {
        $UserRightAssignment = "SeRestorePrivilege"
        }

    If ($SeShutdownPrivilege -eq $true)
        {
        $UserRightAssignment = "SeShutdownPrivilege"
        }

    If ($SeTakeOwnershipPrivilege -eq $true)
        {
        $UserRightAssignment = "SeTakeOwnershipPrivilege"
        }

    If ($SeDenyNetworkLogonRight -eq $true)
        {
        $UserRightAssignment = "SeDenyNetworkLogonRight"
        }

    If ($SeDenyInteractiveLogonRight -eq $true)
        {
        $UserRightAssignment = "SeDenyInteractiveLogonRight"
        }

    If ($SeUndockPrivilege -eq $true)
        {
        $UserRightAssignment = "SeUndockPrivilege"
        }

    If ($SeManageVolumePrivilege -eq $true)
        {
        $UserRightAssignment = "SeManageVolumePrivilege"
        }

    If ($SeRemoteInteractiveLogonRight -eq $true)
        {
        $UserRightAssignment = "SeRemoteInteractiveLogonRight"
        }

    If ($SeImpersonatePrivilege -eq $true)
        {
        $UserRightAssignment = "SeImpersonatePrivilege"
        }

    If ($SeCreateGlobalPrivilege -eq $true)
        {
        $UserRightAssignment = "SeCreateGlobalPrivilege"
        }

    If ($SeIncreaseWorkingSetPrivilege -eq $true)
        {
        $UserRightAssignment = "SeIncreaseWorkingSetPrivilege"
        }

    If ($SeTimeZonePrivilege -eq $true)
        {
        $UserRightAssignment = "SeTimeZonePrivilege"
        }

    If ($SeCreateSymbolicLinkPrivilege -eq $true)
        {
        $UserRightAssignment = "SeCreateSymbolicLinkPrivilege"
        }

    If ($SeMachineAccountPrivilege -eq $true)
        {
        $UserRightAssignment = "SeMachineAccountPrivilege"
        }


    #END Determine which user right selected
    ##########################################################################################################
    
    ##########################################################################################################
    #In verbose mode, we'll output the running values

    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Running Values"


    Write-verbose -Message "Export / Import Directory: $($TempDirectory)"
    Write-verbose -Message "TimeStamp Used for export file name: $($CurrentDateTime)"
    Write-verbose -Message "Export of user right assignment file name: $($ExportofSecuritySettingsNameAndPath)"
    Write-verbose -Message "Import of user right assignment file name: $($ImportofSecuritySettingsNameAndPath)"
    Write-verbose -Message "Secedit Standard Output file name: $($SecEditStdOutPutFullFileName)"
    Write-verbose -Message "Secedit Error Output file name: $($SecEditErrOutPutFullFileName)"
    Write-Verbose -Message "Function Root Path = $($FunctionRootPath)"
    Write-Verbose -Message "Powershell Module Root Path: $($PowershellModuleRootPath)"
    Write-Verbose -Message "User Right Mappings CSV Path: $($UserRightMappingsCSV)"
    Write-Verbose -Message "User Right Assignment Selected: $($UserRightAssignment)"
    

    Write-Verbose -Message "END Running Values"
    Write-Verbose -Message "##########################################################################################################"

    #End In verbose mode, we'll output the running values
    ##########################################################################################################

    
    ##########################################################################################################
    #Export user right assignments

    Write-Verbose -Message " "
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Export user right assignments"

    Try
        {
        Write-Verbose -Message "Attempting to export the user right assignments" 

        $ExportLocalSecurity = Start-process -FilePath "secedit.exe" -ArgumentList "/export /areas USER_RIGHTS /cfg ""$ExportofSecuritySettingsNameAndPath""" -Wait -NoNewWindow -PassThru -RedirectStandardOutput $SecEditStdOutPutFullFileName -ErrorAction Stop 

        
        if ($ExportLocalSecurity.ExitCode -ne 0)
            {
            Write-Error -Message "User rights assignment were NOT exported becasue the secedit.exe exit code was not 0"
            Write-Error -Message "The exit code for secedit was $($ExportLocalSecurity.ExitCode)"
            Throw "Exit code $($ExportLocalSecurity.ExitCode) was not 0"
            }
        Else
            {
            Write-Verbose -Message "User rights assignment were exported to $($ExportofSecuritySettingsNameAndPath)"
            }
        }
    Catch
        {
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
		write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
		Throw "Failed to export via secedit, see above"
        }

    Write-Verbose -Message "END Export user right assignments"
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message " "
    #End Export user right assignments
    ##########################################################################################################

    ##########################################################################################################
    #Now let's import the user right assignments

    Write-Verbose -Message " "
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Now let's import the user right assignments"

    Try
        {
        Write-Verbose -Message "Attempting to import our secedit contents into an array"
        $SeceditContents = Get-Content -Path $ExportofSecuritySettingsNameAndPath -ErrorAction Stop
        Write-Verbose -Message "Imported our secedit contents into an array"

        #Let's output the raw contents for you
        Write-verbose -message "Showing you the raw contents"
        Write-verbose -message " "
        Foreach ($Line in $SeceditContents)
            {
            Write-verbose -Message $($Line)
            }
        
        }
    Catch
        {
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
		write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
		Throw "Failed to import the contents of our secedit, see above"
        }

    Write-Verbose -Message "END Now let's import the user right assignments"
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message " "

    #End Now let's import the user right assignments
    ##########################################################################################################

    ##########################################################################################################
    #Now let's parse the existing user right assignments

    Write-Verbose -Message " "
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Now let's parse the existing user right assignments"
    Write-Verbose -Message " "

    #Loop through each line
    Write-verbose -message "Let's loop through each line and analyze if it's a user right"

    Foreach ($Line in $SeceditContents)
        {
        If ($Line -like "*$($UserRightAssignment)*")
            {
            write-verbose -message "This line $($line) IS a user right, we want to parse"
            Write-Verbose -Message " "
            Write-Verbose -Message "################"
            Write-Verbose -Message "Parsing $($line)"
            Write-Verbose -Message " "

            #Defining the regex patterns to find the SIDs + find the user right name
            $UserRightSeceditSIDRegexPattern = "( = )(.\S*)"
            $userRightSeceditNameRegexPattern = "(\S*)( = )"

            #Grabbing the string of SIDS
            $UserRightSeceditSIDs = $Line | Select-String -Pattern $UserRightSeceditSIDRegexPattern | Select-Object -ExpandProperty matches | Select-Object -ExpandProperty groups | Where-Object {$_.value -notlike "*=*"} | Select-Object -ExpandProperty value
            Write-Verbose "SIDs are $UserRightSeceditSIDs"

            #Grabbing the secedit user rights name
            $UserRightSeceditName = $Line | Select-String -Pattern $userRightSeceditNameRegexPattern | Select-Object -ExpandProperty matches | Select-Object -ExpandProperty groups | Where-Object {$_.value -notlike "*=*"} | Select-Object -ExpandProperty value
            Write-Verbose "User right secedit name is $UserRightSeceditName"

            #Now let's see if the user right is null so we don't waist time parsing a right that's empty
            If ($UserRightSeceditSIDs -ne $null)
                {
                
                #Splitting the SIDs
                $SIDsSplit = $UserRightSeceditSIDs.Split(",")

                #Looping through each SID
                Foreach ($SplitSID in $SIDsSplit)
                    {
                    Write-Verbose "working on SID $($SplitSID)"

                    #let's get rid of the *"
                    $SIDWithOutTheAsterix = $SplitSID.Replace("*","")
                    
                    #Looking up the SIDs friendly name
                    Try
                        {
                        $objSID = New-Object System.Security.Principal.SecurityIdentifier ($SIDWithOutTheAsterix) 
                        $FriendlyNameToSIDMapping = $objSID.Translate( [System.Security.Principal.NTAccount]) | Select-Object -ExpandProperty value
                        Write-Verbose "found the name, $($FriendlyNameToSIDMapping)"
                        }
                    Catch
                        {
                        $FriendlyNameToSIDMapping = "Lookup Failed, might be orphaned"
                        Write-Verbose "couldn't find the name"
                        }

                    #Create a custom object and echo it
                    $ExistingResult = New-Object PSObject -Property @{
	                    SecEditUserRightName = $($UserRightSeceditName)
	                    SIDWithOutTheAsterix = $($objSID.value)
                        SIDWITHTheAsterix = $($SplitSID)
	                    Identity = $($FriendlyNameToSIDMapping)
                        ExistingID = $true
                        }
                    $Shhh = $AllIdentitiesdResults.Add($ExistingResult)

                    }

                }
            Else
                {
                Write-Verbose "there are no existing SIDs for this user right"
                }

            Write-Verbose -Message " "
            Write-Verbose -Message "END Parsing $($line)"
            Write-Verbose -Message "################"
            Write-Verbose -Message " "
            }
        Else
            {
            write-verbose -message "This line $($line) is NOT a user right, ignoring"
            }
        }
    
    Write-Verbose -Message " "
    Write-Verbose -Message "END Now let's parse the existing user right assignments"
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message " "

    #END Now let's parse the existing user right assignments
    ##########################################################################################################
    
    ##########################################################################################################
    #Now let's parse the additional user right assignments

    Write-Verbose -Message " "
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Now let's parse the additional user right assignments"
    Write-Verbose -Message " "

    Foreach ($ID in $Identity)
        {
        Write-Verbose -Message " "
        Write-Verbose -Message "################"
        Write-Verbose -Message "Working on ID $($ID)"
        Write-Verbose -Message " "

        Write-Verbose "Determining if this is a SID or friendly account name"
        If ($ID -match $SIDRegexPattern)
            {
            Write-verbose "ID $($ID) is a SID"

            #Formatting the SID so it will be ready for the secedit import
            $SIDWITHTheAsterix = "*" + $ID

            #Looking up the SIDs friendly name
            Try
                {
                $objSID = New-Object System.Security.Principal.SecurityIdentifier ($ID) 
                $FriendlyNameToSIDMapping = $objSID.Translate( [System.Security.Principal.NTAccount]) | Select-Object -ExpandProperty value
                Write-Verbose "found the name, $($FriendlyNameToSIDMapping)"
                }
            Catch
                {
                $FriendlyNameToSIDMapping = "Lookup Failed, might be orphaned"
                Write-Verbose "couldn't find the name"
                }

            $NewIdentitiesResult = New-Object PSObject -Property @{
	            SecEditUserRightName = $($UserRightSeceditName)
	            SIDWithOutTheAsterix = $($ID)
                SIDWITHTheAsterix = $($SIDWITHTheAsterix)
	            Identity = $($FriendlyNameToSIDMapping)
                ExistingID = $false
                }
            $Shhh = $AllIdentitiesdResults.Add($NewIdentitiesResult)
            }
        Else
            {
            Write-verbose "ID $($ID) is NOT a SID"

            #Let's try converting it to a SID
            Try
                {
                $objUser = New-Object System.Security.Principal.NTAccount($ID) 
                $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier]) | Select-Object -ExpandProperty value
                }
            Catch
                {
                Throw "This ID $($ID) has no SID that I can find, it might be spelled incorrectly"
                }

            #Formatting the SID so it will be ready for the secedit import
            $SIDWITHTheAsterix = "*" + $strSID

            #Formatting the user name for consistency
            $objSID = New-Object System.Security.Principal.SecurityIdentifier ($strSID) 
            $FriendlyNameToSIDMapping = $objSID.Translate( [System.Security.Principal.NTAccount]) | Select-Object -ExpandProperty value
            
            $NewIdentitiesResult = New-Object PSObject -Property @{
	            SecEditUserRightName = $($UserRightSeceditName)
	            SIDWithOutTheAsterix = $($strSID)
                SIDWITHTheAsterix = $($SIDWITHTheAsterix)
	            Identity = $($FriendlyNameToSIDMapping)
                ExistingID = $false
                }
            $Shhh = $AllIdentitiesdResults.Add($NewIdentitiesResult)
            
            }

        Write-Verbose -Message " "
        Write-Verbose -Message "END Working on ID $($ID)"
        Write-Verbose -Message "################"
        Write-Verbose -Message " "
        }
    
    Write-Verbose -Message " "
    Write-Verbose -Message "END Now let's parse the additional user right assignments"
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message " "

    #END Now let's parse the additional user right assignments
    ##########################################################################################################
    
    ##########################################################################################################
    #Compare the current and removal ID's to check for things like duplicates

    Write-Verbose -Message " "
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Compare the current and removal ID's to check for things like duplicates"

    #Grouping so we can see if there are duplicates
    $MergedResults = $AllIdentitiesdResults | Group-Object -Property SIDWithOutTheAsterix

    #Preparing duplicates anoucment
    $DuplicateEntries = $MergedResults | Where-Object {$_.count -gt 1} 
    $NonDuplicateEntries = $MergedResults | Where-Object {$_.count -eq 1} 

    #Echo'ing dupes
    If ($DuplicateEntries-ne $null)
        {
        Write-Verbose " "
        Write-Verbose "#####################"
        Write-Verbose "#Duplicate SIDS"
        Write-Verbose " "
        
        Foreach ($Duplicate in $DuplicateEntries)
            {
            Write-Verbose ($Duplicate| Select-Object -ExpandProperty name)
            Write-Verbose "we will remove the duplicate sid"
            }

        
        Write-Verbose " "
        Write-Verbose "#END Duplicate SIDS"
        Write-Verbose "#####################"
        Write-Verbose " "
        }

    

    Write-Verbose -Message "END Compare the current and removal ID's to check for things like duplicates"
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message " "

    #End Compare the current and removeal ID's to check for things like duplicates
    ##########################################################################################################
    
    ##########################################################################################################
    #Creating a formal list of SIDS to import

    Write-Verbose -Message " "
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Creating a formal list of SIDS to import"

    Write-Verbose -Message " "
    Write-Verbose -Message "#####################"
    Write-Verbose -Message "Merging non-dupes"
    Write-Verbose -Message " "

    Foreach ($NonDuplicateEntrie in $NonDuplicateEntries)
        {
        $ExpandNonDupe = $NonDuplicateEntrie| Select-Object -ExpandProperty Group
         
        $IdentitiesResult = New-Object PSObject -Property @{
	        SecEditUserRightName = $($ExpandNonDupe.SecEditUserRightName)
	        SIDWithOutTheAsterix = $($ExpandNonDupe.SIDWithOutTheAsterix)
            SIDWITHTheAsterix = $($ExpandNonDupe.SIDWITHTheAsterix)
	        Identity = $($ExpandNonDupe.Identity)
            ExistingID = $ExpandNonDupe.ExistingID
            Duplicate = $false
            }
        $FinalIdentites.Add($IdentitiesResult) | Out-Null
        }


    Write-Verbose -Message " "
    Write-Verbose -Message "END Merging non-dupes"
    Write-Verbose -Message "#####################"
    Write-Verbose -Message " "

    Write-Verbose -Message "END Creating a formal list of SIDS to import"
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message " "

    #End Creating a formal list of SIDS to import
    ##########################################################################################################
    
    
    
    
    ##########################################################################################################
    #Formatting the string of SIDS to add

    Write-Verbose -Message " "
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Formatting the string of SIDS to add"


    Write-Verbose -Message "we will be importing the following SIDS"
    Foreach ($FinalIdentity in $FinalIdentites)
        {
        Write-Verbose "$($FinalIdentity.SIDWithOutTheAsterix)"
        }

    
    $FinalIdentitesCount = $FinalIdentites | Measure-Object | Select-Object -ExpandProperty count
    $FinalIdentitesCounter = 1
    $FinalIdentitesSIDsString = $null
    
    Foreach ($FinalIdentity in $FinalIdentites)
        {
        If ($FinalIdentitesCount -eq $FinalIdentitesCounter)
            {
            $FinalIdentitesSIDsString += $($FinalIdentity.SIDWITHTheAsterix)
            
            }
        Else
            {
            $FormattedSidString = $($FinalIdentity.SIDWITHTheAsterix) + ","
            $FinalIdentitesSIDsString += $FormattedSidString
            }
        $FinalIdentitesCounter++
        }

    Write-Verbose "The SID string we'll be importing is as follows: $($FinalIdentitesSIDsString)"

    Write-Verbose -Message "END Formatting the string of SIDS to add"
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message " "

    #END Formatting the string of SIDS to add
    ##########################################################################################################
    
    
    ##########################################################################################################
    #Formatting the secedit file to import

    Write-Verbose -Message " "
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Formatting the secedit file to import"


   $SeceditFile= @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
$($UserRightAssignment) = $($FinalIdentitesSIDsString)
"@

    Write-Verbose "The secedit file we'll be importing will looks like this"
    Write-Verbose " "
    Write-Verbose -Message $SeceditFile

    Write-Verbose -Message "END Formatting the secedit file to import"
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message " "

    #END Formatting the secedit file to import
    ##########################################################################################################
    
    ##########################################################################################################
    #Importing your secedit changes

    Write-Verbose -Message " "
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Importing your secedit changes"

    #Export new file
    $SeceditFile | Set-Content -Path $ImportofSecuritySettingsNameAndPath -Encoding Unicode -Force

    #Finally we'll attempt to import the setting
    $ImportLocalSecurity = Start-process -FilePath "secedit.exe" -ArgumentList "/configure /db ""secedit.sdb"" /cfg ""$ImportofSecuritySettingsNameAndPath"" /areas USER_RIGHTS " -Wait -NoNewWindow -PassThru -RedirectStandardOutput $($SecEditStdOutPutFullFileName) -RedirectStandardError $($SecEditErrOutPutFullFileName)  -ErrorAction Stop
    if ($ImportLocalSecurity.ExitCode -ne 0)
        {
        Throw "Exit code $($ImportLocalSecurity.ExitCode) was not 0"
        }
    

    Write-Verbose "All ID's imported"
    $FinalIdentites 
    
    Write-Verbose -Message "END Importing your secedit changes"
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message " "

    #END Importing your secedit changes
    ##########################################################################################################
    
    
    


    
    }



