
$List_Servers = gc "D:\Repository\Working\Antonio\Get-Function\Servers.txt"

foreach ($server in $List_servers)
{
$Description = Get-ADComputer -Identity $server -Properties Description
$List_Desc = $Description.Description
Write-Output $List_Desc
}

#shhwsr1924
#shhwsr1667