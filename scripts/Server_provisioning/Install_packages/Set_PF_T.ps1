#### Check T:\ volume already exist write-error ""##########################
If (Get-Volume -DriveLetter T -ErrorAction SilentlyContinue)
{Write-Error "T letter is already being used, please do it manually"
Break}
#############################################################################

$Temp_Disk = Get-volume | Where-Object -Property FileSystemLabel -eq -Value "Temporary Storage"
if ($Temp_Disk)
{
$Letter = $Temp_Disk.DriveLetter
Get-Partition -DriveLetter $Letter | Set-Partition -NewDriveLetter T
Set-Itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -value 'T:\pagefile.sys 0 0'
restart-computer -force
}else
{Write-Output "Temporary Storage Found"
}