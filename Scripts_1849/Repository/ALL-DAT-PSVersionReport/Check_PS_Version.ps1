#Author: Antonio Vento
clear-host
$computers = gc "D:\Repository\Scripts\SDB-DAT-PSVersionReport\Computers.txt" #Variable to define Servers to be added.
   foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file          
 #   Invoke-Command -ComputerName $computer -ScriptBlock { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } #Command to allow running scripts (just for the current terminal instance
    Invoke-Command -ComputerName $computer {$PSVersionTable.PSVersion}   #Run the script in the remote server
      
      echo 'PowerShell Version' 
      echo '       '
   }


