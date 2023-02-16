$source = "D:\Repository\Working\Antonio\Check_Zabbix\Servers.txt"
$service = 'Zabbix*'
$Servers = gc $source

foreach ($Server in $Servers)
{

    $servicio = Get-Service -Name $service -ComputerName $Server
    if ($servicio.Status -eq "Running")
    {
        #Stop
        Stop-Service -InputObject $servicio -Verbose
        $servicio.Refresh()
        $servicio
        
        #Start
        Start-Service -InputObject $servicio -Verbose
        $servicio.Refresh()
        $servicio
    }else
    {
       #Start
    Write-Output "Server will be started for $Server"
    Start-Service -InputObject $servicio -Verbose
    $servicio.Refresh()
    }
       
}
