Function Get-ECSLocalGPOUserRightAssignment
    {
    <#
    .SYNOPSIS
    Retrieves all Local Group Policy Object (GPO) user right assignments.
    .DESCRIPTION
    Get-ECSLocalGPOUserRightAssignment will retrieve Local Group Policy Object (GPO) user right assignments.
    This function is useful if you're looking to audit or backup your current user right assignments to a CSV.
    This function utilizes the Windows builtin SecEdit.exe to export the user rights list, and then this function
    parses the exported file. 
    .PARAMETER MergedPolicy
    This parameter merges and exports domain and local policy security settings.
    .EXAMPLE
    This example exports all non-merged user right assignments.
        Get-ECSLocalGPOUserRightAssignment
    .EXAMPLE
    This example exports all MERGED user right assignments.
        Get-ECSLocalGPOUserRightAssignment -MergedPolicy
    #>
    [CmdletBinding()]
    Param
	    (
        [Parameter(Mandatory=$false)]
        [switch]$MergedPolicy
	    )
    
    ##########################################################################################################
    #Dynamic Params

    $TempDirectory = Get-childitem -Path env: | Where-Object {$_.name -eq "temp"} | select-object -ExpandProperty value
    $CurrentDateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $ExportOfSecuritySettingsName = "secedit_userrightassignment_export.tmp"
    $ExportofSecuritySettingsNameAndPath = $TempDirectory + "\" + $CurrentDateTime + "_" + $ExportOfSecuritySettingsName
    $SecEditStdOutPutFullFileName = $TempDirectory + "\" + $CurrentDateTime + "_" + "SeceditStdOutput.txt"
    $SecEditErrOutPutFullFileName = $TempDirectory + "\" + $CurrentDateTime + "_" + "SeceditErrOutput.txt"
    $FunctionRootPath = $PSScriptRoot
    $PowershellModuleRootPath = $($FunctionRootPath).Replace("\Functions","")
    $UserRightMappingsCSV = $PowershellModuleRootPath + "\Dependent Files\UserRightsMapping.csv"
    

    #End Dynamic Parameters
    ##########################################################################################################

    ##########################################################################################################
    #In verbose mode, we'll output the running values

    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Running Values"


    Write-verbose -Message "Export Directory: $($TempDirectory)"
    Write-verbose -Message "TimeStamp Used for export file name: $($CurrentDateTime)"
    Write-verbose -Message "Export of user right assignment file name: $($ExportofSecuritySettingsNameAndPath)"
    Write-verbose -Message "Secedit Standard Output file name: $($SecEditStdOutPutFullFileName)"
    Write-verbose -Message "Secedit Error Output file name: $($SecEditErrOutPutFullFileName)"
    Write-Verbose -Message "Function Root Path = $($FunctionRootPath)"
    Write-Verbose -Message "Powershell Module Root Path: $($PowershellModuleRootPath)"
    Write-Verbose -Message "User Right Mappings CSV Path: $($UserRightMappingsCSV)"

    If ($MergedPolicy -eq $true)
        {
        Write-verbose -Message "Merged Policy Export: True"
        }
    Else
        {
        Write-verbose -Message "Merged Policy Export: False"
        }


    Write-Verbose -Message "END Running Values"
    Write-Verbose -Message "##########################################################################################################"

    #End In verbose mode, we'll output the running values
    ##########################################################################################################

    ##########################################################################################################
    #Importing the User rights mapping CSV

    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Importing the User rights mapping CSV"
    
    Try
        {
        $UserRightsMapings = Import-Csv -Path $UserRightMappingsCSV -ErrorAction Stop
        }
    Catch
        {
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
		write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
        Throw "Failed to import the user rights mapping CSV, see above"
        }


    Write-Verbose -Message "END Importing the User rights mapping CSV"
    Write-Verbose -Message "##########################################################################################################"

    #End Importing the User rights mapping CSV
    ##########################################################################################################
    
    ##########################################################################################################
    #Export user right assignments

    Write-Verbose -Message " "
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Export user right assignments"

    Try
        {
        Write-Verbose -Message "Attempting to export the user right assignments" 
        If ($MergedPolicy -eq $true)
            {
            $ExportLocalSecurity = Start-process -FilePath "secedit.exe" -ArgumentList "/export /mergedpolicy /areas USER_RIGHTS /cfg ""$ExportofSecuritySettingsNameAndPath""" -Wait -NoNewWindow -PassThru -RedirectStandardOutput $SecEditStdOutPutFullFileName -ErrorAction Stop
            }
        Else
            {
            $ExportLocalSecurity = Start-process -FilePath "secedit.exe" -ArgumentList "/export /areas USER_RIGHTS /cfg ""$ExportofSecuritySettingsNameAndPath""" -Wait -NoNewWindow -PassThru -RedirectStandardOutput $SecEditStdOutPutFullFileName -ErrorAction Stop 
            }
        
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
    #Now let's parse the user right assignments

    Write-Verbose -Message " "
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message "Now let's parse the user right assignments"
    Write-Verbose -Message " "

    #Loop through each line
    Write-verbose -message "Let's loop through each line and analyze if it's a user right"

    Foreach ($Line in $SeceditContents)
        {
        If ($Line -like "* = *")
            {
            write-verbose -message "This line $($line) IS a user right, attemptingto parse"
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

            #Matching the user right in our mapping CSV file
            $UserRightMappingMatch = $UserRightsMapings | Where-Object {$_.SecEditName -eq $UserRightSeceditName}

            #Now we need to check if the user right mapping is null, if it is, we'll fill in some temp data
            If ($UserRightMappingMatch -eq $null)
                {
                $UserRightMappingMatch = New-Object PSObject -Property @{
	                FriendlyUserRightName = "No Match found, submit bug report"
                    Description = "No Match found, submit bug report"
                    }
                }

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
                    $Result = New-Object PSObject -Property @{
	                    FriendlyUserRightName = $($UserRightMappingMatch.FriendlyUserRightName)
                        UserRightDescription = "$($UserRightMappingMatch.Description)"
	                    SecEditUserRightName = $($UserRightSeceditName)
	                    SIDWithOutTheAsterix = $($objSID.value)
                        SIDWITHTheAsterix = $($SplitSID)
	                    Identity = $($FriendlyNameToSIDMapping)
                        }
                    $Result

                    }

                }
            Else
                {
                Write-Verbose "there are no SIDs for this right, echoing an empty line just so you know it's empty"
                $Result = New-Object PSObject -Property @{
	                FriendlyUserRightName = $($UserRightMappingMatch.FriendlyUserRightName)
	                UserRightDescription = "$($UserRightMappingMatch.Description)"
                    SecEditUserRightName = $($UserRightSeceditName)
	                SIDWithOutTheAsterix = "no SID found, no assignment"
                    SIDWITHTheAsterix = "no SID found, no assignment"
	                Identity = "no SID found, no assignment"
                    }
                $Result
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
    Write-Verbose -Message "END Now let's parse the user right assignments"
    Write-Verbose -Message "##########################################################################################################"
    Write-Verbose -Message " "

    #END Now let's parse the user right assignments
    ##########################################################################################################
    

    }



