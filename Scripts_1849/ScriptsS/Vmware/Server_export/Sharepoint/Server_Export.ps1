function Get-VCCredential {
param( )

#initialize variables
$AdminName = $env:USERNAME
$Username = "svcshhvcps"
$Path = "D:\Scripts\Schindler\Vmware\Server_export\Sharepoint\"
$CredsFile = "$Path$AdminName-$Username-VCCreds.txt"

$FileExists = Test-Path $CredsFile

if  ($FileExists -eq $false) {
    $Cred = Get-Credential -Message "VCenterSCS Credentials" -UserName $username
    $Cred.Password | ConvertFrom-SecureString | Out-File $CredsFile
}
else
    {Write-Host 'Using your stored credential file' -ForegroundColor Green
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password}

sleep 2
#$username = $cred.GetNetworkCredential().username
#$password = $cred.GetNetworkCredential().password
Return $cred
}#end function





function Export-VM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )

    "Export of $ComputerName started"
    Export-VApp -VM $ComputerName -Destination $Destination -Format Ovf
    "Export of $ComputerName completed"
}


# ******* MAIN SCIPT 
# Connect to vCenter
Add-PSSnapin -Name VMware*
$VIServer = "vcentershh.global.schindler.com"
#$Credentials = Get-VCCredential
Connect-VIServer -Server $VIServer -Credential $Credentials


$sourceVMName = "Res_Test"
$esxName = "shhvsr0003.global.schindler.com"
$VMHost = Get-VMHost $esxName
$Path = "D:\Scripts\Schindler\Vmware\Server_export\Sharepoint\"
$Source = "C:\Temp\Res_Test_Clone.ova"
#$Destination = "\\shhwsr0142.global.schindler.com\e$\"
$Destination = "Z:\"
$Computerlist = "$Path\sharepoint_server_test.txt"

# Not implemented yet - in development
if ($Computerlist -ne $null){
  $Computername = Get-Content $Computerlist 
}

ForEach ($computer in $Computername) {
  "Export of $Computer started"
   Export-VApp -VM $Computer -Destination $Destination -Format Ovf
  "Export of $Computer completed"
}
