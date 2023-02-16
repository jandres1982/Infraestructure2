clear-host
$computers = gc "D:\Repository\Working\Antonio\SDB-IMP-Rollback_ITSLB_V2.00\Computers.txt" #Variable to define Servers to be added.
$destination = "C$\temp" #(Where to copy in the server)
 #Variable to the source file to be used
$local_file = "D:\Repository\Working\Antonio\SDB-IMP-Rollback_ITSLB_V2.00\Rollback_ITSLB_V2.00.ps1"


   foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
             if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable
             Copy-Item $local_file -Destination \\$computer\$destination -Recurse #Copying the script that will run
             } else {
             "\\$computer\$destination is not reachable or does not exist"
             }
       #Invoke-Command -ComputerName $computer -ScriptBlock { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } #Command to allow running scripts (just for the current terminal instance
       $source = "\\$computer\C$\temp\Rollback_ITSLB_V2.00.ps1"
       $Script_RollBack = Get-Content $source
       Invoke-Command -ComputerName $computer -ScriptBlock {PowerShell.exe -ExecutionPolicy Bypass -File "C:\temp\Rollback_ITSLB_V2.00.ps1" }
       
       #$Script_RollBack 
       #Run the script in the remote server
       echo $computer
       echo 'ITSLB Rollback Successfully Applied'
   }
   foreach ($computer in $computers) { #<For> to clean the script file in all servers.
   Remove-Item "\\$computer\C$\temp\Rollback_ITSLB_V2.00.ps1" -Recurse #cleaning
   echo 'file cleaned'
   }