clear-host
$computers = gc "D:\Scripts\Schindler\Zabbix_Agent_Install\ServerList.txt" #Variable to define Servers to be added.
$source = "D:\Scripts\Schindler\Zabbix_Agent_Install\Source\Install.cmd" #Variable to the source file to be used (restarting SNMP service script)
$destination = "C$\temp\" #(Where to copy in the server)
  
   foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
             if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable
             Copy-Item $source -Destination \\$computer\$destination -Recurse #Copying the script that will run
             
             #Invoke-Command -ComputerName $computer -ScriptBlock {cmd.exe /c "c:\temp\install.cmd"}
             invoke-command -ComputerName $computer -ScriptBlock {Start-Process -FilePath C:\temp\install.cmd} 
             Write-host "Working on $Computer"
             Sleep 5
             
               #Run the script in the remote server
  #Invoke-Command -ComputerName $computer -ScriptBlock {rm "C:\Admin\Staging\SDBJobFile.txt"} -ErrorAction SilentlyContinue
             } else {
             "\\$computer\$destination is not reachable or does not exist"
             }
  #Invoke-Command -ComputerName $computer -ScriptBlock { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } #Command to allow running scripts (just for the current terminal instance
    
  }
