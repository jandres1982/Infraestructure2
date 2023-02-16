#Sync_Shares.ps1

$Kg = "DEU"
$Ssrv = "5002"
$Place = "KOR"
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
$To = $From # ****** Other destination mail
$SubjectP = "$SourceP Syncronization finished"
$SubjectG = "$SourceG Syncronization finished"
$Body = @"
This mail is being generated automatically by Sync_Shares Script

SCC Server Competence Center - Schindler Support

"@
$AttachG = @("$LogG.zip")
$AttachP = @("$LogP.zip")

#Sync Group folder
robocopy  "$SourceG" "$DestinationG" /MIR /ZB /COPYALL /MT:100 /R:1 /W:0 /V /TEE /RH:2000-0600 /LOG:$LogG
Compress-Archive -Path $LogG -DestinationPath $AttachG
# Send-MailMessage -From $From -To $To -Subject $SubjectG -Body "$Body" -SmtpServer $EmailServer -Attachments $AttachG -Verbose

#Sync Pools folder
robocopy  "$SourceP" "$DestinationP" /MIR /ZB /COPYALL /MT:100 /R:1 /W:0 /V /TEE /RH:2000-0600 /LOG:$LogP
Compress-Archive -Path $LogP -DestinationPath $AttachP
# Send-MailMessage -From $From -To $To -Subject $SubjectP -Body "$Body" -SmtpServer $EmailServer -Attachments $AttachP -Verbose

Send-MailMessage -From $From -To $To -Subject $SubjectP -Body "$Body" -SmtpServer $EmailServer -Verbose

