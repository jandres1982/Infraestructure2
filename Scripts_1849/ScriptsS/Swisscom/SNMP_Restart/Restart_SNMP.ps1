clear-host
$computers = gc "D:\Scripts\Swisscom\SNMP_Restart\Computers.txt" #Variable to define Servers to be added.
$source = "D:\Scripts\Swisscom\SNMP_Restart\srt.ps1" #Variable to the source file to be used (restarting SNMP service script)
$destination = "C$\temp\" #(Where to copy in the server)
   foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
             if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable
             Copy-Item $source -Destination \\$computer\$destination -Recurse #Copying the script that will run
             } else {
             "\\$computer\$destination is not reachable or does not exist"
             }
       Invoke-Command -ComputerName $computer -ScriptBlock { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } #Command to allow running scripts (just for the current terminal instance
       Invoke-Command -ComputerName $computer -FilePath \\$computer\C$\temp\srt.ps1 #Run the script in the remote server
       echo $computer
       echo 'SNMP service has been restarted'
   }
   foreach ($computer in $computers) { #<For> to clean the script file in all servers.
   Remove-Item "\\$computer\C$\temp\srt.ps1" -Recurse #cleaning
   }
