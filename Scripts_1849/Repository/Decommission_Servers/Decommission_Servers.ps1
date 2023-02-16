clear-host

$Servers = gc "D:\Repository\Working\Antonio\Decommission_Servers\Server_list.txt"


foreach ($server in $Servers)
{
try
{
#Delete AD Object
Get-ADComputer -identity $server | Remove-ADObject -Confirm:$false -Verbose
}
catch
{
Write-host "This $server can't be remove please check permission"
}

}