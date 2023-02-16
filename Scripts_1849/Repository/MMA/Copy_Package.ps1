$server_list = gc "D:\Repository\Working\Antonio\MMA\Server_List.txt"
$destination = "c$\temp" 



Function Check_WinRM
{
if (Test-WSMan -ComputerName $server -Authentication Kerberos -ErrorAction SilentlyContinue)
  {
  #write-host "$server, is reachable"
   }else
   {Write-Output "$server, no WinRM" >> "D:\Repository\Working\Antonio\MMA\Logs\Result.txt"
   Write-host "$Server, is not reachable by PowerShell" -ForegroundColor Yellow}
 }




foreach ($server in $server_list)
{

if (Test-WSMan -ComputerName $server -Authentication Kerberos -ErrorAction SilentlyContinue)
  {
  New-Item -ItemType Directory -path "\\$server\c$\temp\azure" -Force >> $null
  Copy-Item -Path "D:\Repository\Working\Antonio\MMA\InstallDependencyAgent-Windows.exe" -Destination "\\$server\c$\temp\azure\" -force
# Write-host

if (Test-Path -Path \\$Server\$destination){ 
      if (!(Test-Path -Path "\\$server\$destination\azure\MMASetup-AMD64.exe")){
New-Item -ItemType Directory -path "\\$server\c$\temp\azure" -Force >> $null
Copy-Item -Path "D:\Repository\Working\Antonio\MMA\MMASetup-AMD64.exe" -Destination "\\$server\c$\temp\azure\" -force -ErrorAction SilentlyContinue
Write-host "$server is reacheable, MMA package should be copied" -ForegroundColor green
Write-Output "$server, MMA package should be copied" >> "D:\Repository\Working\Antonio\MMA\Logs\Result.txt"

         }else{Write-Output "$server, MMA package should be copied" >> "D:\Repository\Working\Antonio\MMA\Logs\Result.txt"
         Write-host "$server is reacheable, MMA package should be copied" -ForegroundColor green
         }
}


else {
Write-host "$Server, failed to copy the MMA" -ForegroundColor Yellow
Write-Output "$server, failed to copy the MMA or WinRM could be failing" >> "D:\Repository\Working\Antonio\MMA\Logs\Result.txt"
}



}


Check_WinRM

} 
