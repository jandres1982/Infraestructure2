# Unistall Zabbix agent 1
#cmd.exe /c "C:\Program Files\Zabbix\bin>zabbix_agentd.exe -c "C:\Program Files\Zabbix\conf\zabbix_agentd.win.conf" -d"

#start-sleep 60

# Copy Zabbix folder from provision temporary folder to the server

Copy-Item -Path C:\provision\Zabbix_6.0_Agent_v2 -Destination "C:\Program Files" -recurse -force

start-sleep 20

# Set Hostname

$vm = hostname

(Get-Content -Path 'C:\Program Files\Zabbix_6.0_Agent_v2\bin\zabbix_agent2.win.conf') -replace 'vm',$vm | Set-Content -Path "C:\Program Files\Zabbix_6.0_Agent_v2\bin\zabbix_agent2.win.conf"

# Install Zabbix agent 2

cmd.exe /c "C:\Program Files\Zabbix_6.0_Agent_v2\bin\zabbix_agent2.exe --install"

start-sleep 30


# Start Zabbix agent 2

cmd.exe /c "C:\Program Files\Zabbix_6.0_Agent_v2\bin\zabbix_agent2.exe --start"