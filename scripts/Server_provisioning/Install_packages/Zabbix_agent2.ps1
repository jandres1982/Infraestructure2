# Unistall Zabbix agent 1

cmd.exe /c "C:\Program Files\Zabbix\bin>zabbix_agentd.exe -c "C:\Program Files\Zabbix\conf\zabbix_agentd.win.conf" -d"
start-sleep 60

# Install Zabbix agent 2

cmd.exe /c "C:\provision\Schindler\Zabbix_agent2\zabbix_agent2.exe --install"

# Start Zabbix agent 2

cmd.exe /c "C:\provision\Schindler\Zabbix_agent2\zabbix_agent2.exe --start"