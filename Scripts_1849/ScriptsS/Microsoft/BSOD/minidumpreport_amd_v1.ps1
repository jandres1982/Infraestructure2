<#
This script checks all servers listed in the "minidump-servers.txt" file for new dump files 
written to the directory c:\windows\minidump\ within the last 24h. The output is appended to the
\\infda001\infosrv\Admintools\Minidumps\minidumps.csv file
#>
Get-Content D:\Scripts\Schindler\Microsoft\BSOD\minidump-servers_AMD.txt | ForEach-Object {Get-ChildItem \\$_\c$\windows\Minidump\*.dmp | where-object {$_.lastwritetime -gt (get-date).addDays(-56)}} | select fullname, lastwritetime >>\\infda001\infosrv\Admintools\Minidumps\minidumps_amd.csv