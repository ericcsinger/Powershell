#powershell_microsoft_windows_get-physicaldisktologicaldisk
A simple function that is used to map the relationship between physical disks and logicaldisks (drive letters) in windows.  

This function relies on WMI, so for it to work, WMI must be properly open in your environment.  It has one parameter as of now, which is the "computername" parameter.  As the name implies, this parameter is used to define a computer.  By default, it will query localy if a parameter is not used.  If you specify  the computername parameter, just be mindful that this requires admin rights on the remote computer, and the firewall must be open for WMI to work.


