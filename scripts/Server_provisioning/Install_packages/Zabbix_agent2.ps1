# Unistall Zabbix agent 1

#cmd.exe /c "C:\Program Files\Zabbix\bin>zabbix_agentd.exe -c "C:\Program Files\Zabbix\conf\zabbix_agentd.win.conf" -d"
#start-sleep 60

# Install Zabbix agent 2

cmd.exe /c "C:\tmp\Zabbix_agent2\bin\zabbix_agent2.exe --install"
start-sleep 30

# Set Hostname

#(Get-Content -Path 'C:\tmp\Zabbix_agent2\bin\zabbix_agent2.win.conf') -replace 'vm',$vm | Set-Content -Path C:\tmp\Zabbix_agent2\bin\zabbix_agent2.win.conf

# Start Zabbix agent 2

cmd.exe /c "C:\tmp\Zabbix_agent2\bin\zabbix_agent2.exe --start"