clear-host
$computers = gc "D:\Repository\Working\Antonio\SNMP_Restart\Computers.txt" #Variable to define Servers to be added.
$destination = "C$\temp\" #(Where to copy in the server)
   foreach ($computer in $computers) {#For each Server Selected in the Computers.txt file

             if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable 
             
             $SrvName = Read-Host -Prompt 'Input your service name, for example SNMP'
             Write-host " "
             #Test-Boolean {Get-Service -Name $SrvName}
             Write-Host "Current Status:" 
             Get-Service -Name $SrvName -ComputerName $computer         
             Get-Service -Name $SrvName -ComputerName $computer | Restart-Service
             Write-host "Please wait 2 seconds"
             sleep 1
             Write-host "Please wait 1 second"
             sleep 1
             Write-host "Done!"
             Write-host " "
             Write-Host "After Restart Status:" 
             Get-service -Name $SrvName -ComputerName $computer

            }
            else {
            Write-host "Host not recheable"
            }
            }