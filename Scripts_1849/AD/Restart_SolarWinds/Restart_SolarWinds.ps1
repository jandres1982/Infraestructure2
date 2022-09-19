$servers = Get-Content "D:\alb\Restart_SolarWinds\Server_List.txt"
$log = "D:\alb\Restart_SolarWinds\Log.txt"
foreach ($server in $servers)
{
    $service = Get-Service -Name 'SolarWinds Agent'-ComputerName $server
    echo "Initial-  Server: $server Service status: $service" | out-file -FilePath $log -Append
    stop-Service -InputObject $service -Verbose
    $service.Refresh()
    echo "Process-  Server: $server Service status: $service" | out-file -FilePath $log -Append
    start-Service -InputObject $service -Verbose
    $service.Refresh()
    echo "Final-  Server: $server Service status: $service" | out-file -FilePath $log -Append
}
