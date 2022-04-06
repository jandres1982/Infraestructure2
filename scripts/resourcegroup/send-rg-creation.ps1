param([string]$name,[string]$applicationowner,[string]$costcenter,[string]$infrastructureservice,[string]$kg,[string]$serviceowner,[string]$technicalcontact)
$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "nahum.sancho@schindler.com"

$Subject = "New Resource Group $name"
$Body = @"
Dear Eusebio, <br /> <br />

The resource group called $name has been created with the following tags:<br /> <br />
Application Owner: $applicationowner <br />
Cost Center: $costcenter <br />
Infrastructure Service: $infrastructureservice <br />
KG: $kg <br />
Service Owner: $serviceowner <br />
Technical Contact: $technicalcontact <br /> <br />

Best regards. <br /> <br />

Azure Team
"@
Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -BodyAsHtml