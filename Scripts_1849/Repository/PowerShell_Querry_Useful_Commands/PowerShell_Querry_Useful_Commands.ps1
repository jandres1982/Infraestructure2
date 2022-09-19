get-service |where status -Contains Running
get-service |where {$_.Name -eq 'wuauserv' -and $_.Status -eq 'Running'} | Stop-Service -WhatIf
############### WSMAN #########################################
#Ports: 5985(Http)
#Ports: 5986 (Https)
#Use Kerberos
#Encrypted
#WinRM Running
#Better to use GPO to enable PowerShell Remoting
Get-NetFirewallRule *winrm* | Select Name,Enabled,Profile,Direction,Action | format-table #Get FW for WinRM
Disable-NetFirewallRule Winrm-http-in-TCP* #Deshabilitar las reglas de FW para determinados servicios.
Stop-Service -Name WinRM
Set-Service -ComputerName shhwsr0958 -Name Winrm -StartupType Disabled
Get-Service WinRM -ComputerName Shhwsr1848,shhwsr0958,shhwsr0930 | select machinename,name,status,starttype
#Command:
Enable-PSRemoting #Enable PowerShell Remoting (Configure: Default Listeners, Firewalls, EndPoints)
Test-WSMan -Computername Shhwsr0958 -port 5985 #Verify that remote computer is ready fo remote connections
Test-WSMan -ComputerName shhwsr1848 -Credential global\admventoa1 -Authentication Default #Test with credentials
Enter-PSSession -ComputerName shhwsr0958 -Credential (Get-Credential) #Test the login to the server
$Result = Invoke-Command -ComputerName shhwsr0958,shhwsr1848 -ScriptBlock {Get-Process -includeusername}
$Result | Where-Object {$_.Username -eq 'global\admventoa1'}
$Result | Where-Object {$_.ProcessName -clike "zabbix*"} #Acepta WildCards
get-process -name svchost | where-object {$True}
Get-ADUser $env:USERNAME -Properties memberof,displayname
#
#
#


