function Get-VCCredential {
param( )

#initialize variables
$AdminName = $env:USERNAME
$Username = "SA-PF01-vCSchiRO@itoper.local"
$Path = "D:\Scripts\Swisscom\SetResPoolLimit\"
$CredsFile = "$Path$AdminName-VCCreds.txt"

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
}
