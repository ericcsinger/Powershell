$AllPowerShellFunctions = Get-ChildItem -Path "$PSScriptRoot\Functions"

Foreach ($Function in $AllPowerShellFunctions)
    {
    . $Function.FullName
    }

