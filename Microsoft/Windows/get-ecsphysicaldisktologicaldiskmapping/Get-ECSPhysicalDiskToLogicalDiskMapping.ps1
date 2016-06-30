Function Get-ECSPhysicalDiskToLogicalDiskMapping
	{
	<#
  	.SYNOPSIS
  	This function is used to map a physical disk to a partition.
    Version 0.1  
  	#>
	Param
	 	(
   		[Parameter(Mandatory=$false)]
   		$ComputerName = "Localhost"

		) #end param

    #Array to store the results of our disks to partitions as we loop through each disk and each partition.
    $DiskToPartitionMappings = New-Object System.Collections.ArrayList

    #To start off, we need to get a list of all physical disks
    $AllPhysicalDisks = Get-WmiObject -Class WIN32_DiskDrive -ComputerName $ComputerName

    #Loop through each physical disk
    Foreach ($Disk in $AllPhysicalDisks)
        {
        #FOrmat the disk id so we can use it below.  The physical disk id in other WMI objects is formatted a litle differently.
        $PhysicalDiskID = $Disk.DeviceID.replace('\','\\')
        #Compare it against a table of phyical disk to partition mappings
        $PhysicalDiskToPartition = Get-WmiObject Win32_DiskDriveToDiskPartition -ComputerName $ComputerName | Where-Object {$_.Antecedent -like "*$($PhysicalDiskID)*"} 

        #Loop through each disk to partition mapping and...
        Foreach ($PDtoPart in $PhysicalDiskToPartition)
            {
            #Match a logical disk (C: drive for example) to partition)
            $LogicalDisktoPartition = Get-WmiObject Win32_LogicalDiskToPartition -ComputerName $ComputerName | Where-Object {$_.Antecedent-eq $PDtoPart.Dependent}

            #Loop through each partition and logical drive mapping and find the logical drive
            foreach ($LDtoPart in $LogicalDisktoPartition)
                {
                $LogicalDisk = Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName | Where-Object {$_.__PATH -eq $LDtoPart.Dependent}
            
                #Create an object and store it in an array
                $Mapping = New-Object PSObject -Property @{
                                ComputerName = $($Disk.PSComputerName)
                                PhysicalDiskNumber = $($Disk.Index)
                                PhysicalDiskController = $($Disk.SCSIPort)
                                PhysicalDiskControllerPort = $($Disk.SCSITargetId)
                                PhysicalDiskSerialNumber = $($Disk.SerialNumber)
                                PhysicalDiskSize = $($Disk.Size)
                                PhysicalDiskModel = $($Disk.Model)
                                LogicalDiskLetter = $($LogicalDisk.DeviceID)
                                LogicalDiskSize = $($LogicalDisk.Size)
                                LogicalDiskFreeSpace = $($LogicalDisk.FreeSpace)
                    }

                #Add the object to our array
                $DiskToPartitionMappings.Add($Mapping) | Out-Null
                }
            }
        }

    #Echo the results
    $DiskToPartitionMappings

    }