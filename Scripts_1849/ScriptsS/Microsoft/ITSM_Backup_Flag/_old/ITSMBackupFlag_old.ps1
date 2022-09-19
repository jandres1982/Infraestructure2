#Script Version 1
#Create a Header since it is required for powershell and the ITSM export doesn't come with headers
$Header = "Type","HostName","Function","KG","State","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","FQDN","Vendor","Model","25","OS","27","CPU Model","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","Backup"
#Import only HostName and Backup and save it to a temporary file (we don't want to work with the original)
import-csv \\infda001\Landesk-Exchange\PROD\Full-Server-List.csv -Delimiter ";" -header $header | select "HostName","Backup" | export-csv -Path C:\Temp\ITSMBackupFlag.csv -Force

$data = @()
$attr = "Backup"
#Import the comma separated values
    foreach ($_ in (import-csv C:\Temp\ITSMBackupFlag.csv -Delimiter ",") )
        {
            #Filter out decommissioned servers and the ones we are not responsible for
            if ($_.HostName -notlike "*DECOMMISIONED*" -and ($_.HostName -like "*SHH*" -or $_.HostName -like "*SCH*" -or $_.HostName -like "*ASZ*" -or $_.HostName -like "*INF*" -or $_.HostName -like "*SDB*" -or $_.HostName -like "*MAN*" -or $_.HostName -like "*ATH*" -or $_.HostName -like "*JSG*") ) {
                #Change 0 and 1 to human readable values
                $_.$attr = $_.$attr -replace "0", "NO"
                $_.$attr = $_.$attr -replace "1", "YES"
                #Write-Host "Content1: $_"
                $data += $_
            }

        } 
#Save the data to a CSV File
$data | export-csv C:\Temp\ITSMBackupFlag_replaced.csv -Force
#Send the CSV by mail to DC-SB
#Send-MailMessage -To "patrick.mangold@ch.schindler.com" -Subject "ITSM Backup Flag" -From "shhwsr0025@ch.schindler.com" -SmtpServer "smtp.eu.schindler.com" -Attachments "C:\Temp\ITSMBackupFlag_replaced.csv"
Send-MailMessage -To "inf.dc.op@ch.schindler.com" -Subject "ITSM Backup Flag" -From "shhwsr0025@ch.schindler.com" -SmtpServer "smtp.eu.schindler.com" -Attachments "C:\Temp\ITSMBackupFlag_replaced.csv"
