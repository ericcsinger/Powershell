Function Get-ECSVMwareVirtualDiskToWindowsLogicalDiskMapping
	{
	<#
  	.SYNOPSIS
  	This function is used to map a VMware virtual disk to a windows logical disk.  It assumes you're VM is name the same as your computer, if not update the function to suite your needs.
    Version 0.0  
  	#>
	Param
	 	(
   		[Parameter(Mandatory=$true)]
   		$ComputerName

		) #end param

    #First we're going to get the windows physical to logical disk mapping
    $WindowsDisks = Get-ECSPhysicalDiskToLogicalDiskMapping -ComputerName $ComputerName

    #Now we need an array to store the VMware disks for the VM
    $VirtualDiskNameandSerial = New-Object System.Collections.ArrayList

    #Get the VM that matches your computer name
    $VM = Get-VM -Name $ComputerName
    
    If ($VM -eq $null)
        {
        Throw "No VM found, please make sure the computer name matches the VMname"
        }

    #Get the view for the VM.  VMware has a ton of good stuff buried in here.
    $VMView = $VM | Get-View

    #Get the hard disk serial number (UUID)
    $VirtualDisks =  $VMView.config.Hardware.Device | Where-Object {$_.backing -like "*flat*"}
    Foreach ($VirtualDisk in $VirtualDisks)
        {
        #Get rid of the hyphens "-"
        $SerialNumber = ($VirtualDisk | Select-Object -ExpandProperty backing).UUID.replace('-','')

        #Create an object to store the results
        $VDandSerial = New-Object PSObject -Property @{
               VDName = $($VirtualDisk.DeviceInfo.label)
               Serial = $($SerialNumber)
            }

        #Now we'll add the results to an array
        $VirtualDiskNameandSerial.Add($VDandSerial) | Out-Null
        }

    #We now have all the virtual disk names and serial numbers which is all we need.  Now we're going to match them to the windows disks.

    #Array to store the final mappings
    $FinalResults = New-Object System.Collections.ArrayList

    #Putting it all together
    Foreach ($VMwareResult in $VirtualDiskNameandSerial)
        {
        Foreach ($WindowsDisk in $WindowsDisks)
            {
            If ($WindowsDisk.PhysicalDiskSerialNumber -eq $VMwareResult.Serial)
                {
                $CompleteMapping = New-Object PSObject -Property @{
                       WindowsLogicalDisk = $($WindowsDisk.LogicalDiskLetter)
                       VMwareVirtualDisk = $($VMwareResult.VDName)
                    }
                $FinalResults.add($CompleteMapping) | Out-Null
            
                }
            
            }
        }

    $FinalResults  

    }