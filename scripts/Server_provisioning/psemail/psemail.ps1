$vm = $args[0]
$rg = $args[1]
$re_email = $args[2]
$sms = $args[3]

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"


if ($sms -eq "yes" )
{
$phone_AV = "0034691022611@sms.schindler.com"
$phone_NS = "0034699559798@sms.schindler.com"
$phone_DS = "0034613056260@sms.schindler.com"
$phone_AD = "0034669236270@sms.schindler.com"
$phone_LJ = "0034637892033@sms.schindler.com"
$phone_FC = "0034655177690@sms.schindler.com"
$phone_AM = "0034691022611@sms.schindler.com"
$phone_JR = "0034657138014@sms.schindler.com"

If ($re_email -eq "antoniovicente.vento@schindler.com")
    {
    $phone = $phone_AV
    }
If ($re_email -eq "nahum.sancho@schindler.com")
    {
    $phone = $phone_NS
    }
If ($re_email -eq "david.sanchoiguaz@schindler.com")
    {
    $phone = $phone_DS
    }
If ($re_email -eq "alberto.delgado@schindler.com")
    {
    $phone = $phone_AD
    }
If ($re_email -eq "luis.javier.labodia@schindler.com")
    {
    $phone = $phone_LJ
    }
If ($re_email -eq "fernando.camps@schindler.com")
    {
    $phone = $phone_FC
    }
If ($re_email -eq "alfonso.marques@schindler.com")
    {
    $phone = $phone_AM
    }
    If ($re_email -eq "javier.roy@schindler.com")
    {
    $phone = $phone_JR
    }

$To = $phone,$re_email

} else {
    
       $To = $re_email   
       }


#$From = "david.sanchoiguaz@schindler.com"
#$To = $phone,"$re_email"
$Subject = "Server $vm was completed with Schindler Devops Script on $rg"
#$Path = "D:\Repository\Working\Antonio\PS_Email\Test_attachments\"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
#$Attachment = "$Path$Filename"
$Body = @"

Server $vm has been provisioned in $rg

- Check Backup is Enabled.
- Check SIM local admin group is added.
- Check Updates were Installed.
- Check MMA agent is connected to workspaces.

Thanks for using Devops for Schindler Servers!
"@
#Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body