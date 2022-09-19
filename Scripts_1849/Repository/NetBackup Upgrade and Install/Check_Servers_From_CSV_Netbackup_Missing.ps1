$destination = "C$\temp\"
$date = get-date -UFormat "%HH_%MM"

$Missing_NetBackup = Import-Csv "D:\Repository\Working\Antonio\NetBackup Upgrade and Install\Netbackup_Missing.csv"
Write-Output $Missing_NetBackup


Foreach ($Server in $Missing_NetBackup."Device Name")
{

       Write-host ""
       Write-host "--------------- Running on Server $Server --------------------"
       Write-host ""


    if ((Test-Path -Path \\$Server\$destination)) 
       {#Verify if is reachable
       write-host "$destination folder is reachable $Server" -ForegroundColor Green


       }
       else
       {
       Write-host "$destination can't be reached" -ForegroundColor Red
       }

}