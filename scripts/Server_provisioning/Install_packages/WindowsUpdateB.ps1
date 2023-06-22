###
$provider = Get-Package -Name Nuget -EA Ignore
if ($provider) {
Write-Output "Nuget is correctly installed"
}
else {
    Install-Package -Name Nuget -Force 
}

$moduleInstalled = Get-Module -Name PSWindowsUpdate -ListAvailable

If ($moduleInstalled)
{
    Write-Output "Windows Update Module is available"
}else
    {
Install-Module PSWindowsUpdate -Force
    }

    Import-Module PSWindowsUpdate
###
$updatesVerify = Get-WindowsUpdate 
    if ($updatesVerify) {
        Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot
        Write-OutPut "Updates has been installed" 
    }
    else {
        Write-OutPut "No updates needed"
    }