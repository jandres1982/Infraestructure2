clear-host
$computers = gc "D:\Repository\Working\Antonio\WCC_Final_Check_List_Script\Computers.txt" #Variable to define Servers to be added.
$source = "D:\Repository\Working\Antonio\WCC_Final_Check_List_Script\Add_Account_To_LogonAsService.ps1" #Variable to the source file to be used (restarting SNMP service script)
$destination = "C$\temp\" #(Where to copy in the server)
  
   foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
             if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable
             Copy-Item $source -Destination \\$computer\$destination -Recurse #Copying the script that will run
             Invoke-Command -ComputerName $computer -FilePath \\$computer\C$\temp\Add_Account_To_LogonAsService.ps1 -Args "NT SERVICE\ALL SERVICES"  #Run the script in the remote server
  #Invoke-Command -ComputerName $computer -ScriptBlock {rm "C:\Admin\Staging\SDBJobFile.txt"} -ErrorAction SilentlyContinue
             Invoke-Command -ComputerName $computer -ScriptBlock {Start-ScheduledTask -TaskName SCS-ITSLB-Reporting} 
             Invoke-Command -ComputerName $computer -ScriptBlock {SCHTASKS /Run /TN SCS-ITSLB-Reporting; SCHTASKS /Query /FO list /v /TN SCS-ITSLB-Reporting | findstr /b 'Last Run Time'} #-OutVariable $LastRun -ErrorAction SilentlyContinue}
             } else {
             "\\$computer\$destination is not reachable or does not exist"
             }
  #Invoke-Command -ComputerName $computer -ScriptBlock { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } #Command to allow running scripts (just for the current terminal instance
    
      echo '******************************************************'
      echo ''
      echo 'NT SERVICE\ALL SERVICES added to log on as a service'
      echo ''
#      echo 'Job file deleted'
      echo ''
      echo "Server on this task: $computer"
      echo ''
      echo ''
      echo 'Starting Next Server:'


$sharePathname = "\\$computer\c$\temp"

    #create share and set permissions
    New-Item -ItemType Directory $sharePathname -ErrorAction SilentlyContinue

    $acl = Get-Acl $sharePathname

    $inherit = [system.security.accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $propagation = [system.security.accesscontrol.PropagationFlags]"None"
   
    $permission = 'NETWORK SERVICE',"FullControl", $inherit, $propagation, "Allow"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
    $acl.SetAccessRule($accessRule)
       
    
    $acl | Set-Acl $sharePathname



   }

   foreach ($computer in $computers) { #<For> to clean the script file in all servers.
   Remove-Item "\\$computer\C$\temp\Add_Account_To_LogonAsService.ps1" -Recurse #cleaning
   echo ""
   echo ""
   echo "Files Successfully Cleaned"
   }


