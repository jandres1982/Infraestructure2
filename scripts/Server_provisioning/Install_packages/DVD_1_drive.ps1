#Change CD drive letter to be use on Azure template
$drv = Get-WmiObject win32_volume -filter 'DriveLetter = "E:"'
$drv.DriveLetter = "Y:"
$drv.Put() | out-null
Write-host "Format Drives"
#To be use on Azure template
Get-Disk |
Where-Object PartitionStyle -eq 'RAW' |
Initialize-Disk -PartitionStyle GPT -PassThru |
New-Partition -AssignDriveLetter -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false