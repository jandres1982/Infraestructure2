cls
Write-host "Please include the Hostname to check:" -ForegroundColor Yellow
[string]$Computer = Read-Host
#$Computer = "tstshhwsr0251" #testing purposes

#Get the Server Function
$OSValues = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer
Write-host "$Computer Function is:" $OSValues.Description -ForegroundColor Cyan

#Get the HW Information
#Get-CimInstance Win32_OperatingSystem -ComputerName $Computer | Select-Object  Caption | ForEach{ $_.Caption }
$GetCPU = Get-WmiObject Win32_Processor -ComputerName $Computer -ErrorAction SilentlyContinue | findstr "DeviceID" | measure | findstr "Count" 
Write-Host "CPU $GetCPU" -ForegroundColor Green
$PhysicalMemory = Get-WmiObject CIM_PhysicalMemory -ComputerName $Computer | Measure-Object -Property capacity -Sum | % { [Math]::Round(($_.sum / 1GB), 2) }
Write-Host "Memory (GB)  : $PhysicalMemory" -ForegroundColor Cyan


#Get-OperativeSystem
$OSInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer
$OSversion = $OSInfo.caption
Write-host "OS version   : $OSversion" -ForegroundColor Green


#Get-TimeZone
#$TimeZone = Get-WmiObject -Class Win32_Timezone -ComputerName $Computer | findstr "0"
$TimeZone = Invoke-Command -ComputerName $Computer -ScriptBlock {tzutil /g}
Write-host "TimeZone     : $TimeZone" -ForegroundColor Cyan

#Get-LogicalDrives
$LogicalDisk = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $Computer | Select "DeviceID", @{Name="GB"; Expression={[math]::round($_.size/1GB, 2)}}
Echo $LogicalDisk
Echo ""
#GetSoftware_Installed
Write-host " "
Get-WmiObject -Class Win32_Product -ComputerName $Computer | Select "Caption", "Version" | Findstr "NetBackup Trend Tools" | findstr "NetBackup Trend VMware"
#Get-WmiObject -Class Win32_Product -ComputerName $Computer | Select "Caption", "Version" | Findstr "Trend"
#Get-WmiObject -Class Win32_Product -ComputerName $Computer | Select "Caption", "Version" | Findstr "VMware"

#Check_Last_Run_Task
Write-host " "

$ITSLBLast = Invoke-Command -ComputerName $Computer -ScriptBlock {schtasks /query /FO LIST /V /TN SCS-ITSLB-Reporting}
Write-Host "ITSLB"; Echo $ITSLBLast | findstr "Last" | findstr "Run"