#Sync_Shares.ps1

$Kg = "DEU"
$Ssrv = "8002"
$Place = "GAR"
$ShareC = "\consData$\"
$ShareD = "\data2$\"
$SourceC = '\\' + $Kg + 'WSR' + $Ssrv + $ShareC
$SourceD = '\\' + $Kg + 'WSR' + $Ssrv + $ShareD
$Dsrv = "\\SHHDNA0010\"
$DestinationC = $Dsrv + $Kg + '$\' + $Place + '\consData\'
$DestinationD= $Dsrv + $Kg + '$\' + $Place + '\data2\'
$LogC = @("D:\Alb\Logs\Copy\Sync_C_$Ssrv.txt")
$LogD = @("D:\Alb\Logs\Copy\Sync_D_$Ssrv.txt")
$EmailServer = "smtp.eu.schindler.com"
$From = "alberto.delgado@schindler.com"
$To = $From,"patrick.schmurr@schindler.com" #,"ernst.hameister@schindler.com","alfonso.marques@schindler.com" ****** for multiple recipients, separate by commas,"patrick.schmurr@schindler.com","ernst.hameister@schindler.com","alfonso.marques@schindler.com","fernando.camps@schindler.com","david.sanchoiguaz@schindler.com","antoniovicente.vento@schindler.com","luis.javier.labodia@schindler.com"
$SubjectCs = "$SourceC Syncronization started"
$SubjectDs = "$SourceD Syncronization started"
$SubjectCf = "$SourceP Syncronization finished"
$SubjectDf = "$SourceG Syncronization finished"
$Body = @"
This mail is being generated automatically by Sync_Shares Script

SCC Server Competence Center - Schindler Support

"@


#Sync Group folder
Send-MailMessage -From $From -To $To -Subject $SubjectCs -Body "$Body" -SmtpServer $EmailServer -Verbose
robocopy  "$SourceC" "$DestinationC" /MIR /ZB /COPYALL /MT:50 /R:1 /W:0 /V /TEE /LOG:$LogC
Send-MailMessage -From $From -To $To -Subject $SubjectCf -Body "$Body" -SmtpServer $EmailServer -Verbose

#Sync Pools folder
Send-MailMessage -From $From -To $To -Subject $SubjectDs -Body "$Body" -SmtpServer $EmailServer -Verbose
robocopy  "$SourceD" "$DestinationD" /MIR /ZB /COPYALL /MT:50 /R:1 /W:0 /V /TEE /LOG:$LogD
Send-MailMessage -From $From -To $To -Subject $SubjectDf -Body "$Body" -SmtpServer $EmailServer -Verbose
