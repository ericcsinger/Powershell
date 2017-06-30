Function Get-ECSESXHostVIBToPCIDevices
    {
    <#
  	.SYNOPSIS
  	This function is used to find which VIB is used for which PCI device in your server.  This will enabled you to check that your current VIB is the most current VIB on the VMware HCL. The basic process is simple.  The matching process is pretty straight forward.  A PCI device matches a module, and a module matches a vib.  So if we get a complete match all the way through, you end up with all the details you need to check the HCL.

    .EXAMPLE
    Get-ECSESXHostVIBToPCIDevices -VMHostName "hostname.Domain.com"

    .NOTES
    Author: Eric C. Singer
    Version: 0.0
    Gotchas: Hate to be a bummer, but this function or technique, only works on ESXi 6 and above.  In 5.5 and below, the VIBs seem to use a different naming scheme.

    .LINK
    http://wp.me/p62gzE-7y

  	#>

    [cmdletbinding()]
     Param 
        (
        [Parameter(Mandatory=$true)] $VMHostName
        #[Parameter(Mandatory=$false)][switch]$verbose
        )
     
     #If we dectect that you wanted verbose output, we'll start echoing each step we're taking.
     if($verbose) 
        {
        $oldverbose = $VerbosePreference
        $VerbosePreference = "continue" 
        }
    
    Try
        {
        $VMHost = Get-VMHost -Name $VMhostName -ErrorAction Stop
        }
    Catch
        {
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
		write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
		Throw "Something is up with getting the host, check the messages above for details"
        }

    #We need an array to store the results and this is it.
    Try
        {
        Write-Verbose -Message "Creating an array to store results"
        $AllResults = New-Object System.Collections.ArrayList
        Write-Verbose "Array created"
        }
    Catch
        {
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
		write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
		Throw "Something bombed creating the array, see above"
        }

    #Getting the ESXCLI for the host.  Note, I'm using v1 ESXCLI.  There is a v2.  Once time allows and enough folks are on newer versions of PowerCLI, I'll adapt this to v2
    
    Try
        {
        $ESXCLI = Get-EsxCli -VMHost $VMhost -ErrorAction Stop
        }
    Catch
        {
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
		write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
		Throw "Something bombed with getting the ESX CLI, see above"
        }

    #Getting a list of all PCI Devices.  We're filtering out PCI devices that have no module or are vmkernel modules.  vmkernel modules are managed by VMware not the vendor TMK.
    Try
        {
        Write-Verbose "Getting all PCI devices"
        $AllPCIDevices = $esxcli.hardware.pci.list() | Where-Object {$_.modulename -ne "none" -and $_.modulename -ne "vmkernel"}
        Write-Verbose "Got all PCI devices"
        Write-Verbose "There are a total of $($AllPCIDevices.count) PCI Devices"
        }
    Catch
        {
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
		write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
		Throw "Something bombed with getting the PCI devices, see above"
        }

    #Getting a list of all modules
    Try
        {
        Write-Verbose "Getting a list of all modules"
        $AllModules = $esxcli.system.module.list()
        Write-Verbose "Got a list of all modules"
        Write-Verbose "There are a total of $($AllModules.count) modules"
        }
    Catch
        {
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
		write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
		Throw "Something bombed with getting the Modules, see above"
        }

    #Getting a list of all VIBs
    Try
        {
        Write-Verbose "Getting a list of all mibs"
        $AllVIBS = $ESXCLI.software.vib.list()
        Write-Verbose "Got a ist of all vibs"
        Write-Verbose "There are a total of $($AllVIBS.count) vibs"
        }
    Catch
        {
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
		write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
		Throw "Something bombed with getting the Modules, see above"
        }

    #Loop through each PCI device that doesn't uses a module and isn't a kernel module
    Write-Verbose "Starting a loop through each PCI device."
    Foreach ($PCIDevice in $AllPCIDevices)
        {
        #Match the module to all known modules, this shouldn't be null but just incase we'll check.
        Write-Verbose "Working on PCI Device $($PCIDevice.DeviceName)"
        $ModuleMatch = $AllModules | Where-Object {$_.name -like $PCIDevice.modulename}
        If ($ModuleMatch -ne $null)
            {
            Write-Verbose "The PCI device $($PCIDevice.DeviceName) has a match for module $($PCIDevice.modulename)"
            
            #Now we'll get the extra details about the module which also tells us the VIB its using
            Write-Verbose "Checking if there are any module details"
            $ModuleDetails = $esxcli.system.module.get($ModuleMatch.Name)

            #Presuming there is module details, we'll try and match it to a VIB
            If ($ModuleDetails -ne $null)
                {
                Write-Verbose "There are module details for $($ModuleMatch.Name), checking if we can find a matching vib"
                $ModuleVib = $AllVIBS | Where-Object {$_.Name -eq $ModuleDetails.ContainingVIB}

                #Finally we'll make sure there is a matching vib for the module
                If ($ModuleVib -ne $null)
                    {
                    Write-Verbose "We found a matching vib for the module above, sweet!"
                    
                    }
                Else
                    {
                    Write-Verbose "Bummer, no matching vib :-("
                    }
                }
            Else
                {
                Write-verbose "Sorry, couldn't find any details for the module ($ModuleMatch.Name)"
                }

            }
        Else
            {
            Write-Verbose "Sorry, couldn't find a matching module for that PCI device"
            }

        #Once we've looped through everything, we should have a complete status of everything.  Data that didn't have matches will show null
        $HWResult = New-Object PSObject -Property @{
	        PCIDeviceName = $($PCIDevice.DeviceName)
            PCIDeviceModuleName = $($PCIDevice.ModuleName)
            PCIDeviceClass = $($PCIDevice.DeviceClassName)
            PCIDeviceVendorName = $($PCIDevice.VendorName)
            PCIDeviceVendorID = $("{0:x}" -f $([convert]::ToInt32($($PCIDevice.VendorID), 10))) #this converts the device vendor id from a string to an int and then converts it to hex
            PCIDeviceDeviceID = $("{0:x}" -f $([convert]::ToInt32($($PCIDevice.DeviceID), 10)))
            PCIDeviceSubVendorID = $("{0:x}" -f $([convert]::ToInt32($($PCIDevice.SubVendorID), 10)))
            ModuleDetailsCOntainingVIB = $($ModuleDetails.ContainingVIB)
            ModuleVibVendor = $($ModuleVib.Vendor)
            ModuleVibVersion = $($ModuleVib.Version)
            }
        $NullResul = $AllResults.Add($HWResult)

        }

    $AllResults

    }





