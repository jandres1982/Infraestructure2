
$Temp_folder = "C$\temp\"
$date = get-date -UFormat "%HH_%MM"

#$Server_list = Get-ADComputer -Filter * -SearchBase "OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" | select name -ExpandProperty Name |  Where-Object {$_.Name -like '*SHHWSR*' -or $_.Name -like '*CRDWSR*' -or $_.Name -like '*TRDWSR*' -or $_.Name -like '*SCHWSR*' -or $_.Name -like '*MANWSR*' -or $_.Name -like '*BRUWSR*' -or $_.Name -like '*ASZWSR*' -or $_.Name -like '*INVWSR*' -or $_.Name -like '*SDBWSR*' -or $_.Name -like '*JSGWSR*'} | sort
$Server_list = Get-ADComputer -Filter * -SearchBase "OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" | select name -ExpandProperty Name |  Where-Object {$_.Name -like '*WSR*'}| sort
$Server_list > "D:\Repository\Working\Antonio\Get_Local_Admins\Servers_List.txt"
$Server_list = gc "D:\Repository\Working\Antonio\Get_Local_Admins\Servers_List.txt"

Remove-Item "D:\Repository\Working\Antonio\Get_Local_Admins\Report_Local_Admin.csv" -ErrorAction SilentlyContinue
Remove-Item "D:\Repository\Working\Antonio\Get_Local_Admins\Unreachable_no_access.txt" -ErrorAction SilentlyContinue
Remove-Item "D:\Repository\Working\Antonio\Get_Local_Admins\WinRM_no_access.txt" -ErrorAction SilentlyContinue
Remove-Item "D:\Repository\Working\Antonio\Get_Local_Admins\PSVersion_no_access.txt" -ErrorAction SilentlyContinue

Foreach ($Server in $Server_List)
{

       Write-host ""
       Write-host "--------------- Running on Server $Server --------------------"
       Write-host ""

       if ((Test-Connection -ComputerName $Server -Count 1 -ErrorAction SilentlyContinue))
       {
          write-host "$server is pingable" -ForegroundColor Green

            if ((Test-WSMan -ComputerName $Server -Authentication Kerberos -ErrorAction SilentlyContinue))
            {#Verify the server can reached by PowerShell
            write-host "$server accept PS connections" -ForegroundColor Green
 
                     $Validation = Invoke-command -computername $Server -Scriptblock {$PSVersionTable.PSVersion.Major}
                     

                        If ($validation -gt 4)
                        {
                        $Local_Members = Invoke-command -computername $Server -Scriptblock {Get-LocalGroupMember -Group Administrators} | select PSComputerName,ObjectClass,Name
                        $Local_Members | Export-CSV -Append -Path "D:\Repository\Working\Antonio\Get_Local_Admins\Report_Local_Admin.csv"
                        }
                        else
                        {
                        
                        Write-Host "$Server PS version is too low" -ForegroundColor Magenta
                        Write-Output "$Server, PS version too low" >> "D:\Repository\Working\Antonio\Get_Local_Admins\PSVersion_no_access.txt"
                        }
            
            }
            else
            {
            Write-Host "$Server has not access with PS" -ForegroundColor Magenta
            Write-Output "$Server, WinRM is not accesible" >> "D:\Repository\Working\Antonio\Get_Local_Admins\WinRM_no_access.txt"
            }
        }
        else
        {
        Write-Host "$Server is not pingable" -ForegroundColor Magenta
        Write-Output "$Server, Ping is not accesible" >> "D:\Repository\Working\Antonio\Get_Local_Admins\Unreachable_no_access.txt"


        }

        }





#Measure-Object
#
#Export-CSV "C:\global_Servers_clean.csv" -NoTypeInformation -Encoding UTF8
#
#Export-CSV "D:\Repository\Working\Antonio\Get_Local_Admins\Servers_SHH.txt" -NoTypeInformation -Encoding UTF8
#Export-CSV "D:\Repository\Working\Antonio\Get_Local_Admins\Servers_CRD.txt" -NoTypeInformation -Encoding UTF8
#