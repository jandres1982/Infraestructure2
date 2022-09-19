clear-host
$computers = gc "D:\Repository\Working\Antonio\Zabbix_Provisioning_check\server_list.txt" #Variable to define Servers to be added.
$destination = "C$\temp\" #(Where to copy in the server)
 foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
 
 
 
 Write-Host "##############################  $Computer ###############################################"           
 Write-Host ""
 Write-Host ""
            if (test-connection -ComputerName $computer -Count 1 -Quiet) 
            {
            Write-Host "$computer ping is good!" -ForegroundColor Green
            }
            else
            {
            Write-Host "$computer is not pingable" -ForegroundColor Yellow
            }

            if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable
            write-host "$destination folder is reachable $Computer" -ForegroundColor Green

            } else {
            Write-host "$destination folder is not reachable" -ForegroundColor Yellow
            }

            $Get_Service = Get-service -ComputerName $Computer -name "Zabbix Agent" -ErrorAction SilentlyContinue
            $Service_Zabbix = $Get_Service.Name

            if ($Service_Zabbix -eq "Zabbix Agent"){

             Write-host "$Computer, has Zabbix Service" -ForegroundColor Green

             }else
             {

             Write-Host "No Zabbix Agent found in $computer" -ForegroundColor Yellow
             }


             $Get_SEP = Get-service -ComputerName $computer -name "SepMasterService" -ErrorAction SilentlyContinue
             $Service_SEP = $Get_SEP.Name

             if ($Service_SEP -eq "SepMasterService") { #Comprobación de acceso
             Write-Host "Server $computer have SEP Installed" -ForegroundColor Green
             }
             else
             {
             Write-host "$computer has not SEP Installed, please check" -ForegroundColor Yellow
             }


             #$Rdp = New-Object System.Net.Sockets.TCPClient -ArgumentList $computer,3389
             #$Rdp_Ok = $Rdp.Connected

             if(New-Object System.Net.Sockets.TCPClient -ArgumentList $computer,3389)
             {
             Write-Host "$Computer RDP OK" -ForegroundColor Green
             }
             else
             {Write-Host "RDP Not OK" -ForegroundColor Yellow
             }

             If ($?)
{
    "Please check if there are any warnings (yellow color)"
}
Else
{
    "Please check some erros have been found on server $computer"
}


 Write-Host ""
 Write-Host ""
   }
   


