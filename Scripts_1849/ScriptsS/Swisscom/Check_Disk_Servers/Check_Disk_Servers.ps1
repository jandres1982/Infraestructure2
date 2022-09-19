clear-host
$computers = gc "D:\Scripts\Swisscom\Check_Disk_Servers\Computers.txt" #Variable to define Servers to be added.


   foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file


   $drive= Invoke-Command -ComputerName $computer -ScriptBlock {Get-PSDrive -PSProvider FileSystem | where { $_.Root -ne "C:\" -and $_.Root -ne "Y:\" -and $_.Root -ne "A:\" }}
            
             if ($drive | measure | where {$_.Count -gt 0})
             {
             write-host $computer
             #echo $computer >> D:\Scripts\Swisscom\Check_Disk_Servers\servers_list.txt

             echo $drive >> D:\Scripts\Swisscom\Check_Disk_Servers\servers_list.txt
             echo $computer >> D:\Scripts\Swisscom\Check_Disk_Servers\server_hostnames.txt
             echo "---------------------------------------------------------------" >> D:\Scripts\Swisscom\Check_Disk_Servers\servers_list.txt   
             }
   }