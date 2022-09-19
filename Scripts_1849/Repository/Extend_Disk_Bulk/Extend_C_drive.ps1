$Servers = gc "D:\Repository\Working\Antonio\Extend_Disk_Bulk\Server_list.txt"

foreach ($Server in $Servers) {  #<For> each Server Selected in the Computers.txt file
 
 

 
 Write-Host "##############################  $Server ###############################################"           
 Write-Host ""
 Write-Host ""
            if (test-connection -ComputerName $Server -Count 1 -Quiet) 
            {
            Write-Host "$computer ping is good!" -ForegroundColor Green
            Write-host "You have choosen to resize the disk to the max possible size"
            Invoke-Command -ComputerName $Server -ScriptBlock{      
$command = @"
rescan
select disk 0
select volume 2
extend
"@
$command | diskpart}

            #$Letter = "C:"
            #$MaxSize = (Get-PartitionSupportedSize -DriveLetter $Letter).sizeMax 
            #Resize-Partition -DriveLetter $Letter -Size $MaxSize}

            }
            else
            {Write-host "I can't reach this host $server"
            }
}