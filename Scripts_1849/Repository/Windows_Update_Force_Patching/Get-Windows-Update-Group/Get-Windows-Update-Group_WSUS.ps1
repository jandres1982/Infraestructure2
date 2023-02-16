Start-Process notepad++ "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Get-Windows-Update-Group\Server_list.txt" -Wait
$Servers = gc "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Get-Windows-Update-Group\Server_list.txt"
$SHH_WSUS_KG = "shhwsr1242"
$SHH_WSUS = "shhwsr1238"


Foreach ($Server in $Servers)
{

#Write-host "-------------------------------$server------------------------------------"

#####ENABLE Windows Update Service
#Write-Host "ENABLE Windows Update Service on server $Server"
#Get-Service -Name wuauserv -ComputerName $server | Select-Object -Property * | findstr /I "StartType"
#Invoke-command -ComputerName $Server -ScriptBlock {Get-Service -Name wuauserv | Set-Service -StartupType Automatic}
#Invoke-command -ComputerName $Server -ScriptBlock {cmd.exe /c "wuauclt.exe /detectnow /reportnow"}
#Invoke-command -ComputerName $Server -ScriptBlock {Get-Service -Name wuauserv | Set-Service -StartupType Disabled}
#Invoke-command -ComputerName $Server -ScriptBlock {cmd.exe /c wuauclt.exe /detectnow; cmd.exe /c wuauclt.exe /reportnow}
#Get-Service -Name wuauserv -ComputerName $server | Select-Object -Property * | findstr /I "StartType"

####Refreshing Kerberos and update policy
#Write-Host "Refreshing Kerberos and update policy on $Server"
#Invoke-command -ComputerName $Server -ScriptBlock {cmd.exe /c klist -lh 0 -li 0x3e7 purge}
#Invoke-command -ComputerName $Server -ScriptBlock {cmd.exe /c gpupdate /force}
#sleep 1
#
#
####Checking Registry Key
Write-Host "Checking Registry Key on server $Server"
Invoke-command -ComputerName $Server -ScriptBlock {Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate | select TargetGroup}
#
#

####Checking current member of groups:
#Get-ADComputer -Identity $server -Properties * | Select-Object Memberof | Ft -autosize | out-string -width 4096



####Checking Patching Hour
#Write-Host "Checking Patching hour of $Server"

#$time = Invoke-command -ComputerName $server -ScriptBlock {Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU} | findstr /I "ScheduledInstallTime"

#Write-host "$server,$time"
##
Import-Module -Name PoshWSUS
#
#Write-host "Checking the Patching group for Server $Server in the WSUS"
Connect-PSWSUSServer -WsusServer $SHH_WSUS -port 8530 >> $null
$Result_1 = Get-PSWSUSClient -Computername $Server | Select FullDomainName,ComputerGroup,RequestedTargetGroupName,OSDescription,LastSyncTime,IPAddress

Connect-PSWSUSServer -WsusServer $SHH_WSUS_KG -port 8530 >> $null
$Result_2 = Get-PSWSUSClient -Computername $Server | Select FullDomainName,ComputerGroup,RequestedTargetGroupName,OSDescription,LastSyncTime,IPAddress

If ($Result_1 -eq $null -and $Result_2 -eq $null)
{write-host "$server, is not reporting to WSUS"
}


#
#Write-host ""
}
##




 
#ICCS servers
#shhwsr0971
#shhwsr0982