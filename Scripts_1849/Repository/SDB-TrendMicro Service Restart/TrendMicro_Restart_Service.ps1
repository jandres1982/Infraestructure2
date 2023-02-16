clear-host
$Servers = gc "D:\Repository\Working\Antonio\SDB-TrendMicro Service Restart\Servers.txt" #Variable to define Servers to be added.
$destination = "C$\temp\" #(Where to copy in the server)
  
   foreach ($computer in $Servers) {  #<For> each Server Selected in the Computers.txt file
            
             if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable

                   Invoke-Command -Computername $computer -ScriptBlock {
                   Get-Service -Name ds_agent -ErrorAction SilentlyContinue |
                   Restart-Service
                   sleep 5
                   }

                   Invoke-Command -Computername $computer -ScriptBlock {
                   Get-Service -Name ds_monitor -ErrorAction SilentlyContinue |
                   Restart-Service
                   sleep 5
                   }

                   Invoke-Command -Computername $computer -ScriptBlock {
                   Get-Service -Name amsp -ErrorAction SilentlyContinue |
                   Restart-Service
                   sleep 5
                   }

                   Invoke-Command -Computername $computer -ScriptBlock {
                   Get-Service -Name ds_notifier -ErrorAction SilentlyContinue |
                   Restart-Service
                   sleep 5
                   }

             } else {
            Write-host "\\$computer\$destination is not reachable or does not exist"
             }
 
      echo "Server on this task: $computer"

    }

