function Generate_report
{
cd "C:\Program Files (x86)\RobWare\RVTools\"
cmd.exe /c '"C:\Program Files (x86)\RobWare\RVTools\rvtools.exe" -u "SA-PF01-vCSchiRO@itoper.local" -p "jsN8pnjFcY8c"  -s "vcenterscs"  -c ExportAll2xls -d "D:\Scripts\Schindler\RVTools\Export_PS\Exports"'
}

Generate_report

sleep 10

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$To = "hanspeter.gut@schindler.com","dario.schumacher@schindler.com","Alfonso.marques@schindler.com","antoniovicente.vento@schindler.com"
$Date = Get-Date -format d
$Subject = "SwisscomvCenterReport $Date Daily"
$Path = "D:\Scripts\Schindler\RVTools\Export_PS\Exports\"
$Filename = Get-ChildItem $Path -Name "RVTools_export*" | select -Last 1
$Attachment = "$Path$Filename"
$Body = @"
This mail is being generated automatically by a scheduled task.
Please, do not reply.

In case you find any problems, please contact the server team.

Antonio

"@


Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment