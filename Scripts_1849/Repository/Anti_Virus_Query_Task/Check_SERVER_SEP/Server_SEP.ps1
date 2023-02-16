clear-host
$computers = gc "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\server_list.txt" #Variable to define Servers to be added.
$destination = "C$\temp\" #(Where to copy in the server)
Write-Output "" > "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Servers_SEP_Log_No_Ping\Report.log"

#out-file "" > "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Server_SEP_Log.txt"

$date = get-date -UFormat "%HH_%MM"

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Server_SEP_Log\Server_SEP_Log_$date.txt" -append



 foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
 
 

 
 Write-Host "##############################  $Computer ###############################################"           
 Write-Host ""
 Write-Host ""
            if (test-connection -ComputerName $computer -Count 1 -Quiet) 
            {
            Write-Host "$computer ping is good!" -ForegroundColor Green


          $Get_SEP = Get-service -ComputerName $computer -name "SepMasterService" -ErrorAction SilentlyContinue
          $Service_SEP = $Get_SEP.Name

          if ($Service_SEP -eq "SepMasterService") { #Comprobación de acceso
                     
          Write-Host "$computer SepMasterService found" -ForegroundColor Green

#############################################################################################################


                     $Get_version = Invoke-Command -ComputerName $Computer -ScriptBlock{
                     Get-ItemProperty -path "HKLM:\SOFTWARE\Symantec\Symantec Endpoint Protection\CurrentVersion" | Select-Object "Productversion"
                     }
                     Write-host "SEP version"
                     $Get_version.Productversion
                     If ($Get_version.PRODUCTVERSION -eq "14.0.3876.1100")
                          {
                          Write-Warning "SEP needs to be updated check"
                          Write-Output "$Computer,Check" >> "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Servers_SEP_Log_No_Ping\Report.log"
                          }
                          else
                          {
                          if ($Get_version.PRODUCTVERSION -eq "14.2.4814.1101")
                          {
                          Write-host "ALL RIGHT! Version: 14.2.4814.1101"
                          Write-Output "$Computer,ok" >> "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Servers_SEP_Log_No_Ping\Report.log"
                          }
                          else
                          {
                          write-host "Please check the SEP version"
                          Write-Output "$Computer,Check" >> "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Servers_SEP_Log_No_Ping\Report.log"
                          }
                          }
             
             }
             else
             {
             Write-host "Please check $computer SepMasterService not found" -ForegroundColor Yellow
             Write-Output "$Computer,Check" >> "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Servers_SEP_Log_No_Ping\Report.log"
             }



#############################################################################################################

$Get_Pending_Reboot_Sep = Invoke-Command -ComputerName $computer -ErrorAction SilentlyContinue -ScriptBlock{
Get-ItemProperty -path "HKLM:\SOFTWARE\Symantec\Symantec Endpoint Protection\RebootMgr"
}

If ($Get_Pending_Reboot_Sep)
{
Write-Warning "Pending reboot needed, probably waiting to apply the new version"

}


#############################################################################################################


try
{

             $Rdp = New-Object System.Net.Sockets.TCPClient -ArgumentList $computer,3389
             $Rdp_Ok = $Rdp.Connected

             if(New-Object System.Net.Sockets.TCPClient -ArgumentList $computer,3389)
             {
             Write-Host "$Computer RDP OK" -ForegroundColor Green
             }
             else
             {Write-Host "RDP Not OK" -ForegroundColor Yellow
             }
             
             #If ($?)


}

Catch
{
write-Warning "No access using RDP"
}



 Write-Host ""
 Write-Host ""





}

            
            else
            {
            If ((test-connection -ComputerName "$computer.dmz2.schindler.com" -Count 1 -Quiet) -or (test-connection -ComputerName "$computer.tstglobal.schindler.com" -Count 1 -Quiet))
            {
            Write-Host "$computer is a DMZ or TSTGLOBAL Server" -ForegroundColor Yellow
            }
            else
            {
            Write-Host "$computer is not pingable" -ForegroundColor Yellow
            Write-Output "$Computer is not pingable" >> "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Servers_SEP_Log_No_Ping\Not_pingable.txt" 
            Write-Output "$Computer,no ping" >> "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Servers_SEP_Log_No_Ping\Report.log"
            }

          }

 }


# Do some stuff
Stop-Transcript
 


Write-Host ""
Write-Host ""
Write-Host "------------------------------"
#$user = Read-host "Please include your username"


            #New-Item -Path "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\SEP_LOG_NO_Ping.zip" -ItemType File -force
            #New-Item -Path "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\SEP_LOG.zip" -ItemType File -force

            Write-Host ""
            Write-Host "Send Logs By Email"

            $Path = "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Server_SEP_Log\*"
            $Log_Files = Get-ChildItem $Path -Name "Server_SEP_Log*"
            $PSEmailServer = "smtp.eu.schindler.com"
            $date = Get-Date -format d;



            if (($Log_Files -eq $null))
            {write-host "There are no Logs at the moment"
            }
            else
            {
            $User = Read-Host "Please include your Username"
            $Subject = "SEP Report $Date for $User"
            

            Compress-Archive -Path "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Server_SEP_Log\*" -DestinationPath "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\SEP_LOG.zip" -Update
            #Compress-Archive -Path "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\Servers_SEP_Log_No_Ping\*" -DestinationPath "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\SEP_LOG_NO_Ping.zip" -Update
            
            $Attachment = "D:\Repository\Working\Antonio\Anti_Virus_Query_Task\Check_SERVER_SEP\SEP_LOG.zip"
          

            $Body = @"
This mail is being generated automatically by the SEP log Script
In case you find any problems, please contact the Server Team.

SCC Server Competence Center - Schindler Support

"@

if (($user -ne "marquea8" -and $user -ne "admmarquea8" -and $user -ne "ventoa1" -and $user -ne "admventoa1" -and $user -ne "campsfe" -and $user -ne "admcampsfe" -and $user -ne "labodilu" -and $user -ne "admlabodilu" -and $user -ne "sanchod1" -and $user -ne "admsanchod1" -and $user -ne "delgada1" -and $user -ne "admdelgada1"))
{
Write-host "This user is not added to the User DB, please check with the System Administrator" -ForegroundColor red -BackgroundColor white
}


else
{



                        if (($user -eq "marquea8" -or $user -eq "admmarquea8"))
            {
            $From = "alfonso.marques@schindler.com"
            $To = "alfonso.marques@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment
            #Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"

            }
            
                          if (($user -eq "campsfe" -or $user -eq "admcampsfe"))
            {
            $From = "fernando.camps@schindler.com"
            $To = "fernando.camps@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment
            #Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"
            }
            
                       if (($user -eq "sanchod1" -or $user -eq "admsanchod1"))
            {
             $From = "david.sanchoiguaz@schindler.com"
            $To = "david.sanchoiguaz@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment
            #Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"
            }
            
                           if (($user -eq "labodilu" -or $user -eq "admlabodilu"))
            {
            $From = "luis.javier.labodia@schindler.com"
            $To = "luis.javier.labodia@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment
            #Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"
            }

                             if (($user -eq "ventoa1" -or $user -eq "admventoa1"))
            {
            $From = "antoniovicente.vento@schindler.com"
            $To = "antoniovicente.vento@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment  -Verbose
            #Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"
            }


                                         if (($user -eq "delgada1" -or $user -eq "admdelgada1"))
            {
            $From = "alberto.delgado@schindler.com"
            $To = "alberto.delgado@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment -Verbose
            #Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"
            }



  }    
  } 