param (
    [Parameter(Mandatory = $false)]
    [string]$user,
    [Parameter(Mandatory = $false)]
    [string]$pw,
    [Parameter(Mandatory = $false)]
    [string]$server
)

$secureString = ConvertTo-SecureString -AsPlainText -Force -String $pw
$credential = New-Object `
	-TypeName System.Management.Automation.PSCredential `
	-ArgumentList "$user",$secureString
Import-Module PSZabbix
$s = New-ZbxApiSession "https://zabbix.global.schindler.com/zabbix/api_jsonrpc.php" $credential
Write-Host "Working on Server $Server" -ForegroundColor Yellow
Function Remove_Zabbix
{
$Remove_Zabbix = Get-ZbxHost $server | Remove-ZbxHost
if ($Remove_Zabbix)
    {Write-Output "$Server Zabbix Host Removed"}
    else
        {Write-host "Zabbix host for $server cannot be found" -ForegroundColor Gray
        }
}
Write-Output "---- Zabbix -----"
Remove_Zabbix