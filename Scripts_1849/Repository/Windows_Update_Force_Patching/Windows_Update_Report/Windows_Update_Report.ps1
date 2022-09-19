Connect-PSWSUSServer -WsusServer "shhwsr1238" -port "8530"
$groups = Get-PSWSUSGroup -Verbose
$Group_name = $groups.name

Function Get_Clients
{
foreach ($Group in $Group_name)
{
Get-PSWSUSClientsInGroup -Name "$Group" 

}
}

Get_Clients | Select-Object FullDomainName,IPAddress,ClientVersion,LastSyncTime,OSDescription | format-table |Out-File C:\clients.txt
$clients = Get_Clients | Select-Object FullDomainName


#Get-PSWSUSUpdate -Update 4534126 |Select-Object -Property *



Function Get_Pending_Updates
{
foreach ($Group in $Group_name)
{

#Get-PSWSUSUpdateSummaryPerGroup -GroupName "$Group" -Verbose
Get-PSWSUSUpdatePerClient -ComputerName "$clients" -UpdateScope (New-PSWSUSUpdateScope -IncludedInstallationStates Failed)

}
}

Get_Pending_Updates

