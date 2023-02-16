clear-host
$computers = gc "D:\Repository\Working\Antonio\ALL-IMP-Get_and_Install_Peding_Updates_No_Reboot\Computers.txt" #Variable to define Servers to be added.
$destination = "c$\temp" #(Where to copy in the server)
$Script_name = "Get-Install_WSUS-Updates_No_Reboot.ps1"
 #Variable to the source file to be used
$local_file = "D:\Repository\Working\Antonio\ALL-IMP-Get_and_Install_Peding_Updates_No_Reboot\Get-Install_WSUS-Updates_No_Reboot.ps1"

   foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
             if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable
             Copy-Item $local_file -Destination \\$computer\$destination -Recurse #Copying the script that will run
             } else {
             echo "Server is not reachable"
             }
       #Invoke-Command -ComputerName $computer -ScriptBlock { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } #Command to allow running scripts (just for the current terminal instance
        Invoke-Command -ComputerName $computer -FilePath $local_file


       #$Script_RollBack 
       #Run the script in the remote server
       echo $computer
       echo 'Patches Installed Please Check if a reboot is needed'
   }
   #foreach ($computer in $computers) { #<For> to clean the script file in all servers.
   #Remove-Item "\\$computer\C$\temp\Get-Install_WSUS-Updates_No_Reboot.ps1" -Recurse #cleaning
   #echo 'file cleaned'
   # }