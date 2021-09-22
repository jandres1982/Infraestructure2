$Temp_Disk = Get-volume | Where-Object -Property FileSystemLabel  -eq -Value "Temporary Storage"
$Letter = $Temp_Disk.DriveLetter
Get-Partition -DriveLetter $Letter | Set-Partition -NewDriveLetter T
Set-Itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -value 'T:\pagefile.sys 0 0'
restart-computer -force