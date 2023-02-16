clear-host

$computers = gc "D:\Repository\Working\Antonio\WindowsFeature\Computers.txt" #Variable to define Servers to be added.

$destination = "C$\temp\" #(Where to copy in the server)

foreach ($computer in $computers) {#For each Server Selected in the Computers.txt file

             if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable 
             


             Write-Host "Removing Windows Feature"
             
             Write-host " "
             
             Write-Host "$Computer"
                    
             $WF = (Get-WindowsFeature -ComputerName $computer -Name PowerShell-V2).Installed
             
             If ($WF -eq $true)
             {

             get-service -Name TrustedInstaller -ComputerName $computer | Set-Service -StartupType Manual

             Remove-WindowsFeature -ComputerName $computer PowerShell-V2
             
             }
             
             else{
             
             write-host "PowerShell-V2 is already disable in server $computer"

             }
             
             
             
             sleep 1
             
             

             
            }
            else {
            Write-host "$Computer  ----> Host not recheable"

            
    }


    Write-host "########################  Next Server #################################"
}