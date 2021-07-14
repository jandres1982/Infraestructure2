# Change CD drive letter and Initialice and format disks


#Functions

#Change CD drive letter
function chkcddrive
{
    $drv = Get-WmiObject win32_volume -filter 'DriveLetter = "E:"'
    $drv.DriveLetter = "Y:"
    $drv.Put() | out-null
}

# Initialice and format disks
function inidisk
{
    Get-Disk | Where-Object PartitionStyle -eq 'RAW'
    Initialize-Disk -Number 2 -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Sysdb" -Confirm:$false
    Initialize-Disk -Number 3 -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Userdb" -Confirm:$false
    Initialize-Disk -Number 4 -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Logdb" -Confirm:$false
    Initialize-Disk -Number 5 -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Tempdb" -Confirm:$false
}

# Main

set-azcontext -subscripction $(subs)
Write-host "Change CD drive letter"
chkcddrive
Write-host "Format Drives"
inidisk
Write-host "Drives ready to use"
