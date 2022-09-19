<#powershell
NOTES
  Version:        2.0
  Author:         Antonio Vicente Vento Maggio
  Creation Date:  23.May.2019
  Purpose/Change: Initial Patching Menu for Windows 2008, 2012, 2016 and 2019
  Revision:       22.Jul.2019
  Purpose/Change: Include another option to check connectivity and do the report and send email.
  
  
.EXAMPLE
  1.- Fill the servers in ServerList.txt without FQDN
  2.- Run the script WindowsUpdate_v2.ps1 and choose the right option (option 2 will always reboot the server).
  3.- Always when finish press option 3 for cleaning files.
  4.- Check the logs Folder
#>
#>
#>
cls
#Remove-Item "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Server_List\ServerList.txt" -Force

#Function ServerList($question) {
#$question = "Server List"
#Write-host "Please include the list of servers you will like to patch or work with, only the hostnames separeted on a different line" -ForegroundColor Green
#
##$question ="Please include the list of servers you will like to patch or work with"
#  read-host $question
#}
#
#ServerList >> "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Server_List\ServerList.txt"


$Title = "Windows Update Script for Patching"
$Source = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Source\WUinstall.exe"
$Install = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Source\Install_Reboot.cmd"
$Check = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Source\Check_Patches.cmd"
$Servers = gc "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Server_List\ServerList.txt"

$Destination = "C$\temp\"


Move-Item "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Logs\\*.*" "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Old_Logs\"

Function showmenu {
    Clear-Host
        

Write-Warning "CLICK Option 6 to fill the list " 
Write-Host "" 
Write-Host "D:...--> Windows_Update_Force_Patching\Server_List\ServerList.txt"
Write-Host "" 
Write-Host "================= $Title ================" 
Write-Host "=                                                                   ="
Write-Host "=           1. Search and Install Patches                           =" 
Write-Host "=           2. Search + Install + Reboot                            ="
Write-Host "=           3. Clean Files                                          ="
Write-Host "=           4. Check Connectivity and Report to WSUS                ="
Write-Host "=           5. Send logs by email                                   ="
Write-Host "=           6. Show current Server List and open Server List        ="
Write-Host "=           7. Exit                                                 =" 
Write-Host "=                                                                   ="
Write-Host "=                                                                   ="
Write-Host "================= by: Antonio V. Vento Maggio =======================" 

Write-host ""

    Write-Host "Logs can be found for each server on: Logs\Windows_Update_Log_<Server_Name>.txt" -ForegroundColor Cyan
    Write-Host "Please fill the Server List with the servers to be patched or checked" -ForegroundColor Green
}

showmenu
Write-host ""


while(($inp = Read-Host -Prompt "Select an option") -ne "7"){

switch($inp){

        1 {
            Clear-Host
            Write-Host "---------------------------------------------";
            Write-Host "Checking and Installing new Patches";
            
                        foreach ($Server in $Servers) {

            if ((Test-Path -Path \\$Server\$destination)) { #Comprobación de acceso

            Copy-Item $Source -Destination \\$server\$destination -Recurse #Copia del script
            $date_day = date -Format "yyyy_MM_dd"; 
            $date_hour = date -format HH_mm;
            $date = "Day_"+$date_day+"_At_"+$date_hour;
            $filename = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Logs\Windows_Update_Log_Hostname_"+$Server+"_at_"+$date+".txt"
            echo "Log for $Server at $date Checking Patches" | out-file -FilePath $filename -Append
            #Copy-Item $Install -Destination \\$server\$destination -Recurse
            #cd "c:\admin\tools\Sysinternals"
            $cmd = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Source\PsExec64.exe -accepteula \\$server -s cmd /c c:\temp\wuinstall /search /download /install"
            start powershell.exe "cmd.exe /c $cmd | out-file -filepath $filename -Append"
            #echo $cmd | cmd.exe
            #start-process "c:\admin\tools\Sysinternals\PSEXEC64.exe \\$server -s cmd /c c:\temp\wuinstall /reboot"
             
            
            
            #invoke-command -ComputerName $Server -ScriptBlock {C:\Windows\System32\cmd.exe c:\TEMP\Install_Reboot.cmd} |tee "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Logs\Windows_Update_log_$Server.txt"
           
            

            Write-Host "---------------------------------------------";


            }
            else
            {write-host "Server $Server can't be reached this will be in the log to check" -ForegroundColor DarkRed -BackgroundColor White
            $date_day = date -Format "yyyy_MM_dd"; 
            $date_hour = date -format HH_mm;
            $date = "Day_"+$date_day+"_At_"+$date_hour;
            $filename_no = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Logs\Windows_Update_Log_Hostname_"+$Server+"_at_"+$date+"_Check.txt"
            echo "Server $Server with no access to C:\temp, please check it manually" | out-file -filepath $filename_no
            


            }

            }

            pause;
            break
        }
        2 {

                Clear-Host
            Write-Host "------------------------------";
            Write-Host "Checking and Installing + Reboot";
                        foreach ($Server in $Servers) {

            if ((Test-Path -Path \\$Server\$destination)) { #Comprobación de acceso

            Copy-Item $Source -Destination \\$server\$destination -Recurse #Copia del script
            
            $date_day = date -Format "yyyy_MM_dd"; 
            $date_hour = date -format HH_mm;
            $date = "Day_"+$date_day+"_At_"+$date_hour;
            $filename = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Logs\Windows_Update_Log_Hostname_"+$Server+"_at_"+$date+".txt"
            echo "Log for $Server at $date Checking Patches" | out-file -FilePath $filename -Append

            #Copy-Item $Install -Destination \\$server\$destination -Recurse
            #cd "c:\admin\tools\Sysinternals"
            $cmd = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Source\PsExec64.exe -accepteula \\$server -s cmd /c c:\temp\wuinstall /install /reboot"
            start powershell.exe "cmd.exe /c $cmd | out-file -filepath $filename -Append"
            #echo $cmd | cmd.exe
            #start-process "c:\admin\tools\Sysinternals\PSEXEC64.exe \\$server -s cmd /c c:\temp\wuinstall /reboot"
             
            
            
            #invoke-command -ComputerName $Server -ScriptBlock {C:\Windows\System32\cmd.exe c:\TEMP\Install_Reboot.cmd} |tee "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Logs\Windows_Update_log_$Server.txt"
            
            

            Write-Host "------------------------------";


            }
            else
            {
            write-host "Server $Server can't be reached this will be in the log to check" -ForegroundColor DarkRed -BackgroundColor White
            $date_day = date -Format "yyyy_MM_dd"; 
            $date_hour = date -format HH_mm;
            $date = "Day_"+$date_day+"_At_"+$date_hour;
            $filename_no = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Logs\Windows_Update_Log_Hostname_"+$Server+"_at_"+$date+"_Check.txt"
            echo "Server $Server with no access to C:\temp, please check it manually"  | out-file -filepath $filename_no
            }

            }
            pause;
            break
        }


            
        3 {

                   Clear-Host
            Write-Host "------------------------------";
            Write-Host "Cleaning Process";
            
            foreach ($Server in $Servers) {

            if ((Test-Path -Path \\$Server\$destination)) { #Comprobación de acceso

            Remove-item "\\$server\$destination\wuinstall.exe" -ErrorAction SilentlyContinue

            Write-Host "----- Cleaning Complete Server $Server -----";


            }
            else
            {write-host "Server $Server can't be reached" -ForegroundColor Red -BackgroundColor white
            }

            }
            pause;
            break
            }




            4 {

            Clear-Host
            Write-Host "------------------------------";
            Write-Host "Check access and Report to WSUS";
            
            foreach ($Server in $Servers) {

            if ((Test-Path -Path \\$Server\$destination)) { #Comprobación de acceso

            
            Write-Host "-----$Server access ok ->>> Detect and Report Executed -----" -ForegroundColor Black -BackgroundColor White

            #Invoke-command -computername $server -ScriptBlock {Start-Process cmd.exe '/c "wuauclt.exe /detectnow"'}
            #Invoke-command -computername $server -ScriptBlock {Start-Process cmd.exe '/c "wuauclt.exe /reportnow"'}  
            Invoke-Command -ComputerName $Server -ScriptBlock {wuauclt.exe /detectnow}
            Invoke-Command -ComputerName $Server -ScriptBlock {wuauclt.exe /reportnow}
            #Invoke-Command -ComputerName $Server -ScriptBlock {wuauclt.exe /resetauthorization /detectnow /report now}
            $date_day = date -Format "yyyy_MM_dd"; 
            $date_hour = date -format HH_mm;
            $date = "Day_"+$date_day+"_At_"+$date_hour;
            $filename = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Logs\Windows_Update_Log_Hostname_"+$Server+"_at_"+$date+".txt"
            echo "Report completed for $Server at $date, please update WSUS console" | out-file -FilePath $filename -Append


            }
            else
            {
            write-host "Server $Server can't be reached this will be in the log to check" -ForegroundColor DarkRed -BackgroundColor White
            $date_day = date -Format "yyyy_MM_dd"; 
            $date_hour = date -format HH_mm;
            $date = "Day_"+$date_day+"_At_"+$date_hour;
            $filename_no = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Logs\Windows_Update_Log_Hostname_"+$Server+"_at_"+$date+"_Check.txt"
            echo "Server $Server with no access to C:\temp, please check it manually" | out-file -filepath $filename_no



            }

            }
            pause;
            break
            }


            5 {

            Clear-Host
            Write-Host "------------------------------";
            Write-Host "Send Logs By Email";

            $Path = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Logs\"
            $Log_Files = Get-ChildItem $Path -Name "Windows_Update*"
            $PSEmailServer = "smtp.eu.schindler.com"
            $date = Get-Date -format d;

            if (($Log_Files -eq $null))
            {write-host "There are no Logs at the moment"
            }
            else
            {
            $User = Read-Host "Please include your Username"
            $Subject = "Windows Update Report $Date for $User"
            

            Compress-Archive -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Logs\*" -DestinationPath "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\Windows_Update_$date_Day-$date_hour.zip"
            
            $Attachment = "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\Windows_Update_*"

            $Body = @"
This mail is being generated automatically by the Windows Updates Script
In case you find any problems, please contact the Server Team.

SCC Server Competence Center - Schindler Support

"@

if (($user -ne "marquea8" -and $user -ne "admmarquea8" -and $user -ne "ventoa1" -and $user -ne "admventoa1" -and $user -ne "campsfe" -and $user -ne "admcampsfe" -and $user -ne "labodilu" -and $user -ne "admlabodilu" -and $user -ne "sanchod1" -and $user -ne "admsanchod1" -and $user -ne "delgada1" -and $user -ne "admdelgada1" -and $user -ne "sanchona" -and $user -ne "admsanchona"))
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
            Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"

            }
            
                          if (($user -eq "campsfe" -or $user -eq "admcampsfe"))
            {
            $From = "fernando.camps@schindler.com"
            $To = "fernando.camps@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment
            Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"
            }
            
                       if (($user -eq "sanchod1" -or $user -eq "admsanchod1"))
            {
             $From = "david.sanchoiguaz@schindler.com"
            $To = "david.sanchoiguaz@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment
            Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"
            }
            
                           if (($user -eq "labodilu" -or $user -eq "admlabodilu"))
            {
            $From = "luis.javier.labodia@schindler.com"
            $To = "luis.javier.labodia@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment
            Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"
            }

                             if (($user -eq "ventoa1" -or $user -eq "admventoa1"))
            {
            $From = "antoniovicente.vento@schindler.com"
            $To = "antoniovicente.vento@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment -Verbose
            Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"
            }


                                         if (($user -eq "delgada1" -or $user -eq "admdelgada1"))
            {
            $From = "alberto.delgado@schindler.com"
            $To = "alberto.delgado@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment -Verbose
            Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"
            }

            
                                         if (($user -eq "sanchona" -or $user -eq "admsanchona"))
            {
            $From = "nahum.sancho@schindler.com"
            $To = "nahum.sancho@schindler.com"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment -Verbose
            Remove-Item -Path "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Compress_Folder\*"
            }





           
}
           



            }

            
            pause;
            break
            }


            6 {

            Clear-Host
            Write-Host "------------------------------";
            Write-Host "Showing Current Server List";
            $Server_list = gc "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Server_List\ServerList.txt"
            Write-Output $Server_list
            cmd /c notepad.exe "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Server_List\ServerList.txt"
            $Servers = $Server_list
            pause;
            break
            }










        7 {"exit"; break}
        default {Write-Host -ForegroundColor red -BackgroundColor white "Invalid option. Please select another option";pause}
       
    }

showmenu
}


















#
#