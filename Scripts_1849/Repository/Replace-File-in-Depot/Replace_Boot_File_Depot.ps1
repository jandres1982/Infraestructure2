$depot_list = gc "D:\Repository\Working\Antonio\Replace-File-in-Depot\Depot_Servers.txt"
$Location = "C$\Program Files (x86)\LANDesk\PXE\System\images\Boot"
$File = "D:\Repository\Working\Antonio\Replace-File-in-Depot\bcd"

foreach ($depot in $depot_list)
{
   if (Test-WSMan -ComputerName $depot -Authentication Kerberos -ErrorAction SilentlyContinue)
   {
   write-host "$Depot accept powershell" -ForegroundColor Green
         if (Test-Path -Path \\$Depot\$location)
         {
         Write-Host "$Depot is accessible" -ForegroundColor Green
         
             Copy-Item -Path $file -Destination "\\$depot\$location" -Force
             if ($?)
             {
             Write-host "$Depot, file copied!" -ForegroundColor Yellow
             Write-Output "$Depot, file copied" >> "D:\Repository\Working\Antonio\Replace-File-in-Depot\Depots_File_Copied.txt"
             }
             else
             {
             Write-Host "Check $depot" -ForegroundColor DarkRed
             }
         
         }
         else
         {Write-host "$Depot is not accesible" -ForegroundColor Re
         }
    }
    else
    {Write-host "$Depot is not accepting powershell" -ForegroundColor Red
    Write-Output "$Depot, please check manually" >> "D:\Repository\Working\Antonio\Replace-File-in-Depot\Depot_No_access.txt"
    }
   }

