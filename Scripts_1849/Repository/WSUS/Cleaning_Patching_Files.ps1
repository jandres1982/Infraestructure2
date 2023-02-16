clear-host
$Server_List = gc "D:\Repository\Working\Antonio\WSUS\Server_List.txt" 
$Dest_Module = "C$\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate" #(Where to copy in the server)
$Source_Module = "D:\Repository\Working\Antonio\WSUS\PSWindowsUpdate"
$Test_Location ="C$\windows\temp\"
   foreach ($Server in $Server_List) {
             if ((Test-Path -Path \\$server\$Test_Location)) { #Verify if is reachable

             echo "Server $Server is reachable"
             #New-Item -ItemType "directory" -Path "\\$Server\$Dest_Module"
             #Copy-Item $Source_Module -Destination \\$Server\$Dest_Module -Recurse -ErrorAction SilentlyContinue
             #Invoke-Command -ComputerName $Server {Import-module PSWindowsUpdate}

             echo "Server $Server is going to be Cleaned"
             #Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
             #Import-Module PSWindowsUpdate
             #$Script = {ipmo PSWindowsUpdate; Get-WUInstall -AcceptAll -AutoReboot | Out-File C:\temp\WindowsUpdate.log}
             #Invoke-Command -ComputerName $computer -ScriptBlock { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } #Command to allow running scripts (just for the current terminal instance
             #Invoke-WUInstall -ComputerName $Server -Script $Script -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Confirm:$false
             #Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
             echo ""
             echo "------------------------------- Cleaning Module Files -----------------------------------------------------------"
             echo ""

             Remove-Item -Path \\$Server\$Dest_Module -Recurse -Force -ErrorAction SilentlyContinue
             #Invoke-Command -ComputerName $Server {Get-Module -name PSWindowsUpdate}
             Invoke-Command -ComputerName $Server {Remove-Module PSWindowsUpdate} -ErrorAction SilentlyContinue

             Restart-Computer -ComputerName $Server -Wait -For PowerShell -Timeout 300 -Delay 2 -Force

             Invoke-Command -ComputerName $Server {wuauclt /detectnow}
             Invoke-Command -ComputerName $Server {wuauclt /reportnow}

             Write-host "Server $Server has been cleaned and reported to WSUS server"

                          }
              
             else
              
             {
             echo "Server $Server is not reachable or does not exist"
             }
       
       
   }
  
