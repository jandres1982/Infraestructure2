#This script can be used to start/stop/restart services on multiple servers.
#Modify on your needs....

#Get the server list 
$server_list = Get-Content "D:\Scripts\Schindler\SEP_Service_Stop\Servers.txt"

$creds = Get-Credential
 
Foreach ($server in $server_list){
    #if(Get-Service -ComputerName $server -Name "amsp" -ErrorAction SilentlyContinue){
        #Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/X{851A3FC2-BEF1-47F0-882A-A4BE5E0133EC} /qn REBOOT=REALLYSUPPRESS" -Wait
        #Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/X{EF0664BA-D655-493C-A55D-024917145FB1} /qn REBOOT=REALLYSUPPRESS" -Wait
     #   if(Get-Service -ComputerName $server -Name "SepMasterService" -ErrorAction SilentlyContinue){
      #      write-host "$Server with TM and SEP"
      #  }
    #}else{
    #    write-host "$Server with no AV"
    #}
    
    #}else{
        Invoke-Command -credential $creds -computer $server -ScriptBlock {
        #Start-Process -FilePath "\\shhwsr1123\e$\Agents\SEP_14.0.3876.1100\setup.exe" -Wait -Credential $creds
        #& '\\shhwsr1123\e$\Agents\SEP_14.0.3876.1100\setup.exe'
        & 'C:\PROGRAM FILES (X86)\SYMANTEC\Symantec Endpoint Protection\smc.exe' -start
        #write-host "$Server with SEP pending reboot"
        }
    #}
}