<#
    Written by Patrick Mangold
    Version: 1
    Version Control:
    12.5.2015 initial script creation V0.1
    12.5.2015 changed it to a scheduled task
    
    Requirements:
    -Connection to vCenter
    -PowerCLI cmdlets
#>
#load powercli is not required since it will be started with powercli in the parameters of the scheduled task (see parameter below)
powershell.exe -PSConsoleFile "%ProgramFiles(x86)%\VMware\Infrastructure\vSphere Power CLI\vim.psc1" -File "D:\Scripts\Schindler\Vmware\Dswitch_Backup\Dswitch_Backup.ps1"


#Connect to vCenter
connect-VIServer vcentershh.global.schindler.com

#Select a specific distributed switch and export the configuration to a local zip file
Get-VDSwitch -name 'DS_Data_Center' | Export-VDSwitch -Description "DS_Data_Center complete configuration" -Destination "D:\Scripts\Schindler\Vmware\DSwitch_Backup\Files\DS_Data_Center$(get-date -f dd-MM-yyyy).zip" -force
Get-VDSwitch -name 'DS_Client_Cluster' | Export-VDSwitch -Description "DS_Data_Center complete configuration" -Destination "D:\Scripts\Schindler\Vmware\DSwitch_Backup\Files\DS_Client_Cluster$(get-date -f dd-MM-yyyy).zip" -force
Get-VDSwitch -name 'DS_DMZ_Cluster' | Export-VDSwitch -Description "DS_Data_Center complete configuration" -Destination "D:\Scripts\Schindler\Vmware\DSwitch_Backup\Files\DS_DMZ_Cluster$(get-date -f dd-MM-yyyy).zip" -force


