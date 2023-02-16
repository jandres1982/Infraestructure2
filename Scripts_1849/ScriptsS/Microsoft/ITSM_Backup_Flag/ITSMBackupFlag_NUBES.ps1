#Original Script by Patrick Mangold. Modified for NUBES my Michael Barmettler
#V1 This skript takes the ITSM Export and filters it for the backup flags for Servers that are migrated to Swisscom Wankdorf or Zollikofen. Then it sends them as a report to the Backup Team


#Create a Header since it is required for powershell and the ITSM export doesn't come with headers
$Header = "Type","HostName","Function","KG","State","6","7","8","9","10","City","12","13","14","15","16","17","18","19","20","21","FQDN","Vendor","Model","25","OS","27","CPU Model","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","Backup"
#Import only HostName and Backup and save it to a temporary file (we don't want to work with the original)
import-csv \\infda001\Landesk-Exchange\PROD\Full-Server-List.csv -Delimiter ";" -header $header | select "HostName","Backup","City" | export-csv -Path C:\Temp\ITSMBackupFlagNubes.csv -Force

$datayes = @()
$datano = @()
$data = @()
$dataunknown = @()
$attr = "Backup"
#Import the comma separated values
    foreach ($_ in (import-csv C:\Temp\ITSMBackupFlagNubes.csv -Delimiter ",") )
        {
            #Filter out decommissioned servers and the ones we are not responsible for
            if ($_.HostName -notlike "*_D*" -and ($_.City -like "Wankdorf" -or $_.City -like "Zollikofen")) {
                #Change 0 and 1 to human readable values
                $_.$attr = $_.$attr -replace "0", "NO"
                $_.$attr = $_.$attr -replace "1", "YES"
                #Write-Host "Content1: $_"
                
                $data = $_
                
                switch ($_.$attr)
                {
                'YES' { $datayes += $data.HostName ; break}
                'NO' { $datano += $data.HostName ; break}
                default { $dataunknown += $data.HostName }
                }
            }

        } 
#Adjust string because if it is only one element in it will choose the lenght as output instead of the content
$datayes = $datayes | Select-Object @{Name='HostBackupYES';Expression={$_}}
$datano = $datano | Select-Object @{Name='HostBackupNo';Expression={$_}}
$dataunknown = $dataunknown | Select-Object @{Name='HostBackupUnknown';Expression={$_}}

#Save the data to a CSV File
$datayes | export-csv C:\Temp\ITSMBackupFlag_yes_replaced_NUBES.csv -Force
$datano | export-csv C:\Temp\ITSMBackupFlag_no_replaced_NUBES.csv -Force
$dataunknown | export-csv C:\Temp\ITSMBackupFlag_unknown_replaced_NUBES.csv -Force
#Send the CSV by mail to DC-SB
Send-MailMessage -To "michael.barmettler@ch.schindler.com" -Subject "NUBES - Servers in Zollikofen / Wankdorf" -From "shhwsr0025@ch.schindler.com" -SmtpServer "smtp.eu.schindler.com" -Attachments "C:\Temp\ITSMBackupFlag_yes_replaced_NUBES.csv", "C:\Temp\ITSMBackupFlag_no_replaced_NUBES.csv", "C:\Temp\ITSMBackupFlag_unknown_replaced_NUBES.csv"
#Send-MailMessage -To "sdb.dc.bkp@ch.schindler.com" -Subject "NUBES - Servers in Zollikofen / Wankdorf" -From "shhwsr0025@ch.schindler.com" -SmtpServer "smtp.eu.schindler.com" -Attachments "C:\Temp\ITSMBackupFlag_yes_replaced_NUBES.csv", "C:\Temp\ITSMBackupFlag_no_replaced_NUBES.csv", "C:\Temp\ITSMBackupFlag_unknown_replaced_NUBES.csv"

