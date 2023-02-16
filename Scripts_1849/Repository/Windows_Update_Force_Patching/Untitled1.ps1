#Sync_Shares.ps1

$Source = "\\shhdna0003\pdata$"
$Destination = "\\SHHWSR2432\d$\Data"
$date = $(get-date -format yyyy-MM-ddTHH-mm)
$Log = "D:\alb\DNAMigration\LogsDNA\PData_shhdna0003_"+$date+".txt"


#Mail
$EmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$To = "alberto.delgado@schindler.com"
$Subjects = "\Backup_PDATA_shhdna0003 Syncronization started"
$Subjectf = "\Backup_PDATA_shhdna0003 Syncronization finished"

$Body = @"
This mail is being generated automatically by Sync_Shares Script

SCC Server Competence Center - Schindler Support

"@


#Sync Group folder
Send-MailMessage -From $From -To $To -Subject $Subjects -Body "$Body" -SmtpServer $EmailServer -Verbose
robocopy  "$Source" "$Destination" /E /MIR /ZB /COPYALL /MT:32 /R:1 /W:0 /LOG+:$Log
Send-MailMessage -From $From -To $To -Subject $Subjectf -Body "$Body" -SmtpServer $EmailServer -Verbose
