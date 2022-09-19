      #Import-Module PSWindowsUpdate
      Import-Module -Name PoshWSUS
      #Get-command -module PoshWSUS



Remove-Item -Path "D:\Repository\Working\Antonio\WSUS\Migration_Report\SHHWSR0239_NO_FQDN.txt" -ErrorAction SilentlyContinue

 try
  {
$Old_WSUS = "shhwsr0239"
$Result_path = "D:\Repository\Working\Antonio\WSUS\Migration_Report\SHHWSR0239_NO_FQDN.txt" 


Write-host "Checking the old WSUS server for the Server $Server"
Connect-PSWSUSServer -WsusServer $Old_WSUS -port 8530 #Connecting to WSUS Server
$Server_list = Get-PSWSUSClient | Select-Object FullDomainName > "D:\Repository\Working\Antonio\WSUS\Migration_Report\SHHWSR0239_With_FQDN.txt" #List with FQDN
$ServerList = gc "D:\Repository\Working\Antonio\WSUS\Migration_Report\SHHWSR0239_with_FQDN.txt" #Get content from the previous list

   
Foreach ($server in $Serverlist) 
{
$Split = $Server.Split('.')
$Hostname = $Split[0] >> "D:\Repository\Working\Antonio\WSUS\Migration_Report\SHHWSR0239_NO_FQDN.txt" #Get only the Hostname and write down in the file.
}

#(Get-Content $Result_path | Select-Object -Skip 2) | Set-Content $Result_path #Taking out the first two lines of the file with the hostnames

   Disconnect-PSWSUSServer  
   
 }



 catch
 {
   Write-Warning "Connection to $Old_WSUS Old WSUS server was not possible or the object doesn't exist"
 }


#try
# {
$New_WSUS = "shhwsr1238"
#   Write-host "Checking the Schinlder WSUS server for the Server $Server"
Connect-PSWSUSServer -WsusServer $New_WSUS -port 8530
$Server_check = gc "D:\Repository\Working\Antonio\WSUS\Migration_Report\SHHWSR0239_NO_FQDN.txt"

Remove-Item -Path "D:\Repository\Working\Antonio\WSUS\Migration_Report\Compare_list.txt" -ErrorAction SilentlyContinue

Foreach ($Hostname in $Server_check)
{



echo "************************************************************" >> "D:\Repository\Working\Antonio\WSUS\Migration_Report\Compare_list.txt"
echo "$Hostname" >> "D:\Repository\Working\Antonio\WSUS\Migration_Report\Compare_list.txt"
Get-PSWSUSClient -Computername $Hostname | Select-Object ComputerGroup >> "D:\Repository\Working\Antonio\WSUS\Migration_Report\Compare_list.txt"
echo "************************************************************" >> "D:\Repository\Working\Antonio\WSUS\Migration_Report\Compare_list.txt"

#}
#catch
#{
#Write-host "$Server not found in WSUS SHHWSR1238" >> "D:\Repository\Working\Antonio\WSUS\Migration_Report\Check_list.txt"
#}
#

}

Disconnect-PSWSUSServer





#   Get-PSWSUSClient > "D:\Repository\Working\Antonio\WSUS\List_SHHWSR1238.txt"
#   Disconnect-PSWSUSServer  
#   Write-host "$Server is in the $new_WSUS WSUS Server"
# }
# catch
# {
#   Write-Warning "Connection to $new_WSUS Schindler WSUS server was not possible or the object doesn't exist"
# }