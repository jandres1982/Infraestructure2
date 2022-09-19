#Sync_Shares.ps1

$Kg = "DEU"
$Ssrv = "9001"
$Place = "NUE"
$ShareG = "\data$\groups\"
$ShareP = "\data$\pools\"
$SourceG = '\\' + $Kg + 'WSR' + $Ssrv + $ShareG
$SourceP = '\\' + $Kg + 'WSR' + $Ssrv + $ShareP
$Dsrv = "\\SHHDNA0010\"
$DestinationG = $Dsrv + $Kg + '$\' + $Place + '\data\groups\'
$DestinationP= $Dsrv + $Kg + '$\' + $Place + '\data\pools\'
$LogG = @("D:\Alb\Logs\Copy\Sync_G_$Ssrv.txt")
$LogP = @("D:\Alb\Logs\Copy\Sync_P_$Ssrv.txt")
$EmailServer = "smtp.eu.schindler.com"
$From = "alberto.delgado@schindler.com"
$To = $From,"patrick.schmurr@schindler.com"#,"patrick.schmurr@schindler.com","ernst.hameister@schindler.com","alfonso.marques@schindler.com" ****** for multiple recipients, separate by commas,"patrick.schmurr@schindler.com","ernst.hameister@schindler.com","alfonso.marques@schindler.com","fernando.camps@schindler.com","david.sanchoiguaz@schindler.com","antoniovicente.vento@schindler.com","luis.javier.labodia@schindler.com"
$SubjectPs = "$SourceP Syncronization started"
$SubjectGs = "$SourceG Syncronization started"
$SubjectPf = "$SourceP Syncronization finished"
$SubjectGf = "$SourceG Syncronization finished"
$Body = @"
This mail is being generated automatically by Sync_Shares Script

SCC Server Competence Center - Schindler Support

"@


#Sync Group folder
Send-MailMessage -From $From -To $To -Subject $SubjectGs -Body "$Body" -SmtpServer $EmailServer -Verbose
robocopy  "$SourceG" "$DestinationG" /MIR /ZB /COPYALL /MT:50 /R:1 /W:0 /V /TEE /LOG:$LogG
Send-MailMessage -From $From -To $To -Subject $SubjectGf -Body "$Body" -SmtpServer $EmailServer -Verbose

#Sync Pools folder
Send-MailMessage -From $From -To $To -Subject $SubjectPs -Body "$Body" -SmtpServer $EmailServer -Verbose
robocopy  "$SourceP" "$DestinationP" /MIR /ZB /COPYALL /MT:50 /R:1 /W:0 /V /TEE /LOG:$LogP
Send-MailMessage -From $From -To $To -Subject $SubjectPf -Body "$Body" -SmtpServer $EmailServer -Verbose