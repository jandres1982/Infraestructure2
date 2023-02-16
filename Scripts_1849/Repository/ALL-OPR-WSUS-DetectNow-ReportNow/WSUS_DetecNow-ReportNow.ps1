clear-host
$computers = gc "D:\Repository\Working\Antonio\ALL-OPR-WSUS-DetectNow-ReportNow\Computers.txt" #Variable to define Servers to be added.
$destination = "c$\temp" #(Where to copy in the server)
#$Script_name = "Get-Install_WSUS-Updates_No_Reboot.ps1"
#Variable to the source file to be used
#$local_file = "D:\Repository\Working\Antonio\ALL-IMP-Get_and_Install_Peding_Updates_No_Reboot\WUInstall.exe"

   foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
             if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable
             #Copy-Item $local_file -Destination \\$computer\$destination -Recurse #Copying the file that will run
             } else {
             echo "Server is not reachable"
             }
       Invoke-Command -ComputerName $computer {wuauclt /detectnow}
       Invoke-Command -ComputerName $computer {wuauclt /reportnow}
       #Invoke-Command -ComputerName $computer {wuauclt /selfupdateunmanaged}
       
       #Invoke-Command -ComputerName $computer -ScriptBlock { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } #Command to allow running scripts (just for the current terminal instance
       #Invoke-Command -ComputerName $computer -FilePath $local_file
       #Invoke-command -ComputerName $computer -ScriptBlock {powershell.exe "& {c:\temp\WUInstall.exe /Install}"}
       #C:\admin\tools\Sysinternals\PsExec64.exe \\$computer c:\temp\WUInstall.exe -install

       #$Script_RollBack 
       #Run the script in the remote server
       echo $computer
       echo 'Done'
   }
   #foreach ($computer in $computers) { #<For> to clean the script file in all servers.
   #Remove-Item "\\$computer\C$\temp\Get-Install_WSUS-Updates_No_Reboot.ps1" -Recurse #cleaning
   #echo 'file cleaned'
   # }