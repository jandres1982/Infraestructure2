if not exist C:\Temp\ mkdir C:\Temp\
netsh advfirewall firewall add rule name="Zabbix Agent" dir=in action=allow protocol=TCP localport=10050
cd\
cd "Program Files"
cd Zabbix
cd bin
if exist "c:\Program Files\Zabbix\bin\zabbix_agentd.exe" (
zabbix_agentd.exe --stop
zabbix_agentd.exe --uninstall
) else (
cd win64
zabbix_agentd.exe --stop
zabbix_agentd.exe --uninstall
)
cd\
rd /Q /S "c:\Program Files\Zabbix"
cd "Program Files"
mkdir Zabbix
ping SHHWSR0012 -n 1 | find /i "TTL=">1
if errorlevel 1 (
echo Server not reachable from this domain
) else (
xcopy /E /I "\\SHHWSR0012.global.schindler.com\d$\temp\Zabbix\zabbix_agents-4.0.0-win-i386" "C:\Program Files\Zabbix" /Y
)
ping TSTSHHWSR0012 -n 1 | find /i "TTL=">1
if errorlevel 1 (
echo Server not reachable from this domain
) else (
xcopy /E /I "\\TSTSHHWSR0012.tstglobal.schindler.com\d$\temp\Zabbix\zabbix_agents-4.0.0-win-i386" "C:\Program Files\Zabbix" /Y
)
ping SHHWSR0743 -n 1 | find /i "TTL=">1
if errorlevel 1 (
echo Server not reachable from this domain
) else (
xcopy /E /I "\\SHHWSR0743.dmz2.schindler.com\d$\temp\Zabbix\zabbix_agents-4.0.0-win-i386" "C:\Program Files\Zabbix" /Y
)
cd Zabbix
cd bin
zabbix_agentd.exe -c "C:\Program Files\Zabbix\conf\zabbix_agentd.win.conf" -i
zabbix_agentd.exe --start