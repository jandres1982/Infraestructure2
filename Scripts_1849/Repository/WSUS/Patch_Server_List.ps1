clear-host
$Server_List = gc "D:\Repository\Working\Antonio\WSUS\Server_List.txt" 
$Dest_Module = "C$\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate" #(Where to copy in the server)
$Source_Module = "D:\Repository\Working\Antonio\WSUS\PSWindowsUpdate"
$Test_Location ="C$\windows\temp\"

   foreach ($Server in $Server_List) {
             if ((Test-Path -Path \\$server\$Test_Location)) { #Verify if is reachable

             echo "Server $Server is reachable"
             #New-Item -ItemType "directory" -Path "\\$Server\$Dest_Module"
             Copy-Item $Source_Module -Destination \\$Server\$Dest_Module -Recurse -ErrorAction SilentlyContinue
             Invoke-Command -ComputerName $Server {Import-module PSWindowsUpdate} -ErrorAction Continue

             echo "Server $Server is going to be patched and rebooted, if you have errors please go manually"
             #Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
             Import-Module PSWindowsUpdate
             $Script = {ipmo PSWindowsUpdate; Get-WUInstall -AcceptAll -AutoReboot | Out-File C:\temp\WindowsUpdate.log}
             #Invoke-Command -ComputerName $computer -ScriptBlock { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } #Command to allow running scripts (just for the current terminal instance).
             Invoke-WUInstall -ComputerName $Server -Script $Script -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Confirm:$false
             #Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
             echo ""
             echo "----------- Patching Servers Using WSUS ---------------"
             

             #Remove-Item -Path \\$Server\$Dest_Module -Recurse -Force
             #Invoke-Command -ComputerName $Server {Get-Module -name PSWindowsUpdate}
             #Invoke-Command -ComputerName $Server {Remove-Module PSWindowsUpdate} -ErrorAction SilentlyContinue

                          }
             ########Confirm when the server has been rebooted########
 
    
             else
              
             {
             echo "Server $Server is not reachable or does not exist"
             }
       
       
   }
  
