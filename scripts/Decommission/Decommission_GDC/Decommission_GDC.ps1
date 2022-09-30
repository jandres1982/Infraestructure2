$s = New-ZbxApiSession "https://zabbix.global.schindler.com/zabbix/api_jsonrpc.php" (Get-Credential admventoa1)
#GDC Decommission Script
$SHH_WSUS = "shhwsr1238"
$SHH_WSUS_KG = "shhwsr1242"
#$servers = gc "D:\Repository\Working\Antonio\Decommission_GDC\Servers.txt"

Foreach ($Server in $Servers)
{

Function Remove_WSUS
{
Import-Module -Name PoshWSUS
#
#Write-host "Checking the Patching group for Server $Server in the WSUS"
Connect-PSWSUSServer -WsusServer $SHH_WSUS -port 8530 >> $null
$Result_1 = Get-PSWSUSClient -Computername $Server | Select FullDomainName,ComputerGroup,RequestedTargetGroupName,OSDescription,LastSyncTime,IPAddress
Connect-PSWSUSServer -WsusServer $SHH_WSUS_KG -port 8530 >> $null
$Result_2 = Get-PSWSUSClient -Computername $Server | Select FullDomainName,ComputerGroup,RequestedTargetGroupName,OSDescription,LastSyncTime,IPAddress

If ($Result_1 -eq $null -and $Result_2 -eq $null)
    {write-host "$server, cannot be found on $SHH_WSUS or $SHH_WSUS_KG" -ForegroundColor Gray
    }else
        {
         Write-Output "Checking Connection to $SHH_WSUS"
         Connect-PSWSUSServer -WsusServer $SHH_WSUS -port 8530 >> $null
         Remove-PSWSUSClient -Computername $Server -WarningAction SilentlyContinue
         Write-Output "Checking Connection to $SHH_WSUS_KG"
         Connect-PSWSUSServer -WsusServer $SHH_WSUS_KG -port 8530 >> $null
         Remove-PSWSUSClient -Computername $Server -WarningAction SilentlyContinue
         }

}

Function Remove_Zabbix
{
Import-Module PSZabbix
$Remove_Zabbix = Get-ZbxHost $server | Remove-ZbxHost
if ($Remove_Zabbix)
    {Write-Output "$Server Zabbix Host Removed"}
    else
        {Write-host "Zabbix host for $server cannot be found" -ForegroundColor Gray
        }

}

Write-Host "---------"
Write-Host "Working on Server $Server" -ForegroundColor Yellow
Write-Output "----- WSUS -----" -InformationAction Continue
Remove_WSUS
Write-Output "---- Zabbix -----" -InformationAction Continue
Remove_Zabbix

#"OU=RES,OU=Groups,OU=Admin_Global,OU=NBI12,DC=global,DC=schindler,DC=com" 
#(Get-ADGroup -filter * -searchbase "OU=Groups,OU=NBI12,DC=global,DC=schindler,DC=com" | Where-Object {$_.SamAccountName -like "*RES_SY_"+$server+"_ADMIN"}).SamAccountName
}
