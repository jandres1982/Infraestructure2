$vm = $args[0]
$rg = $args[1]
$re_email = $args[2]
$PSEmailServer = "smtp.eu.schindler.com"
$phone_AV = "0034691022611@sms.schindler.com"
$phone_NS = "0034699559798@sms.schindler.com"
$phone_DS = ""
$phone_AD = ""
$phone_LJ = ""
$phone_FC = ""
$phone_AM = ""

If ($re_email -eq "antoniovicente.vento@schindler.com")
{
$phone = $phone_AV
}
If ($re_email -eq "nahum.sancho@schindler.com")
{
$phone = $phone_NS
}
If ($re_email -contains "david")
{
$phone = $phone_DS
}
If ($re_email -contains "alberto")
{
$phone = $phone_AD
}
If ($re_email -contains "luis")
{
$phone = $phone_LJ
}
If ($re_email -contains "fernando")
{
$phone = $phone_FC
}
If ($re_email -contains "alfonso")
{
$phone = $phone_AM
}

Write-host "$phone"

#$From = "scc-support-zar.es@schindler.com"
$From = "david.sanchoiguaz@schindler.com"
$To = $phone,"$re_email"
$Subject = "Server $vm was completed with Schindler Devops Script on $rg"
#$Path = "D:\Repository\Working\Antonio\PS_Email\Test_attachments\"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
#$Attachment = "$Path$Filename"
$Body = @"
Server $vm has been provisioned in $rg. 
- Check Backup is Enabled.
- Check SIM local admin group is added.
- Check Updates were Installed.
- Check MMA agent is connected to workspaces.
"@
#Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body