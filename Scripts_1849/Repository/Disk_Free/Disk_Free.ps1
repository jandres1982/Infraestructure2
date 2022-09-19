$ServerList = gc "D:\Repository\Working\Antonio\Disk_Free\ServerList.txt"
$Label = gc "D:\Repository\Working\Antonio\Disk_Free\Label.txt"

Function Disk_$Volume
{
$disk = Get-WmiObject Win32_LogicalDisk -ComputerName $Server -Filter "DeviceID='$Volume'" |
Select-Object Size,FreeSpace


$Disk_Size = [math]::Round($disk.Size /1GB)
$Disk_Free =[math]::Round($disk.FreeSpace /1GB)
#if ($disk_Size -gt 512)
#{

Write-Host "Free Disk $Volume (%) is " 
$free_percentage =[math]::Round($Disk_Free*100/$Disk_Size)
Write-Host "Free Disk $Volume $Free_percentage"
echo "$Server;$Volume;$Free_percentage" >> D:\Repository\Working\Antonio\Disk_Free\Result.txt

#}
}



foreach ($Server in $ServerList) {

$Server

foreach ($Volume in $Label)
{

Disk_$Volume

}

}

#Label.txt C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:

