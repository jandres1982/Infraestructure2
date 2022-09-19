#Sync_Shares.ps1

$Kg = "DEU"
$Ssrv = "1002"
$Place = "CHE"
$ShareG = "\data$\groups\"
$SourceG = '\\' + $Kg + 'WSR' + $Ssrv + $ShareG
$Dsrv = "\\SHHDNA0010\"
$DestinationG = $Dsrv + $Kg + '$\' + $Place + '\data\groups\'
$LogG = @("D:\Alb\Logs\Copy\Sync_G_$Ssrv.txt")
$EmailServer = "smtp.eu.schindler.com"
$From = "alberto.delgado@schindler.com"
$To = $From,"patrick.schmurr@schindler.com" # ****** for multiple recipients, separate by commas
$SubjectG = "$SourceG Syncronization finished"
$Body = @"
This mail is being generated automatically by Sync_Shares Script

SCC Server Competence Center - Schindler Support

"@
$AttachG = "$LogG.zip"

#Sync Group folder
robocopy  "$SourceG" "$DestinationG" /MIR /ZB /COPYALL /MT:100 /R:1 /W:0 /V /TEE /LOG:$LogG
#Compress-Archive -Path $LogG -DestinationPath $AttachG
Send-MailMessage -From $From -To $To -Subject $SubjectG -Body "$Body" -SmtpServer $EmailServer -Verbose


