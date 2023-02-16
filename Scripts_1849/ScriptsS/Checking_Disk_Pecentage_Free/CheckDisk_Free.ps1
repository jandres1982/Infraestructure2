

              
$ServerList = @(gc "D:\Scripts\Schindler\Checking_Disk_Pecentage_Free\ServerList.txt")
$Label = @(gc "D:\Scripts\Schindler\Checking_Disk_Pecentage_Free\Label.txt")

Function Disk_$Volume
{
$disk = Get-WmiObject Win32_LogicalDisk -ComputerName $Server -Filter "DeviceID='$Volume'" |
Select-Object Size,FreeSpace


$Disk_Size = [math]::Round($disk.Size /1GB)
$Disk_Free =[math]::Round($disk.FreeSpace /1GB)
if ($disk_Size -gt 512)
{

#Write-Host "Free Disk $Volume (%) is " 
$free_percentage =[math]::Round($Disk_Free*100/$Disk_Size)
Write-Host "Free Disk $Volume $Free_percentage"
echo "$Server;$Volume;$Free_percentage" >> D:\Scripts\Schindler\Checking_Disk_Pecentage_Free\Result\Result.txt

}
}


$Number=0

while($Number -ne 591 )
     {
       
       #Write-Host $Number

       $Server = $ServerList[$Number] 
       $Volume = $Label[$Number]
       
       echo $Server
       echo $Volume

       Disk_$Volume
       $Number++

     }

