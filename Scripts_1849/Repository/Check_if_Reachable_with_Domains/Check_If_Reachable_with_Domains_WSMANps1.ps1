clear-host

$proc = cmd.exe /c "C:\Program Files\Notepad++\notepad++.exe" "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Server_List.txt"
#$ID = (Get-Process notepad++).id
#Wait-Process -id $ID -ErrorAction SilentlyContinue

Remove-Item -Path "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report.txt"

$computers = gc "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Server_List.txt" #Variable to define Servers to be added.
$destination = "C$\temp\" #(Where to copy in the server)

 foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
 

            if (Test-WSMan -ComputerName $computer -Authentication Kerberos -ErrorAction SilentlyContinue)
                {
                Write-Host "$computer, ping is good!" -ForegroundColor Green
                Write-Output "$computer, ping OK" >> "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report.txt"

                }
                else
                {
                    $computer_dmz2 = $computer + ".dmz2.schindler.com"
                    if (Test-WSMan -ComputerName $computer_dmz2 -Authentication Kerberos -ErrorAction SilentlyContinue)
                    {
                    Write-Host "$computer_dmz2 ping is good!" -ForegroundColor Green
                    Write-Output "$computer_dmz2, ping OK" >> "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report.txt"
                    }
                      else
                      {
                      $computer_tstglobal = $computer + ".tstglobal.schindler.com"
                      if (Test-WSMan -ComputerName $computer_tstglobal -Authentication Kerberos -ErrorAction SilentlyContinue)
                      {
                      Write-Host "$computer_tstglobal is pingable" -ForegroundColor Green
                      Write-Output "$computer_tstglobal, ping OK" >> "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report.txt"
                      } 
 
                                  else {
                                       
                                        Write-host "$computer, is not pingable" -ForegroundColor yellow
                                        Write-Output "$computer, NO ping" >> "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report.txt"
                                        }
                               }
                      }


                      $domains = @("global","dmz2","tstglobal")
foreach ($domain in $domains)
    {
    $server_fqdn = $computer+"."+$domain+"."+"schindler.com"
    #Write-Host "Checking $server_fqdn"
    #Write-Host "Checking $domain"
        if (Resolve-DnsName $server_fqdn -ErrorAction SilentlyContinue)
        {
        #Write-host "DNS exist check"
        Write-host "$server_fqdn"
        }else
            {#Write-host "DNS doesn't exist"
            }
 }







                      }


 Write-Host ""
 Write-Host ""
   #}
   


