param([string]$Hostname)

$Parameters_Base = "D:\Repository\Working\Antonio\Azure-Remote-Scripting\Parameters_VM\parameters_$hostname.json"
$Template_2019 = "D:\Repository\Working\Antonio\Azure-Remote-Scripting\Parameters_VM\Azure_Parameters\template_2019.json"
$Parameters = ([System.IO.File]::ReadAllText($Parameters_Base))
$Template_2019 = ([System.IO.File]::ReadAllText($Template_2019))


#$bodymsg = @(
#   @{ Message="Prueba the RunBook"}
#   )

   
   $URL = 'https://s2events.azure-automation.net/webhooks?token=Ttib7fuC0zthn0PsuYvPJkhUcFmjUjwAjcfUkhBtcFQ%3d'
   #$body = ConvertTo-Json -InputObject $bodymsg
   #$body = @(
   #@{ Message="$Parameters"+"$Template_2019"}
   #)
   #$body_1 = $Template_2019
   $body = "$Parameters"+"xxxxxxx"+"$Template_2019"
   $header = @{ message = "Send VM Values"}
   #$header_1 = @{ message = "Send Template"}
   $response = Invoke-RestMethod -Method Post -uri $URL -Body $body -Headers $header
 


###################  Create a runbook with this data ##############################
#   param(
#    [Parameter (Mandatory = $false)]
#    [object] $WebhookData
#)
#
#
#if ($WebhookData) {
#    Write-Output "The Webhook Header"
#    Write-Output $WebhookData.RequestHeader.Message
#    Write-Output "The Webhook Name"
#	Write-Output $WebhookData.WebhookName
#	Write-Output "The Webhook Body"
#	Write-Output $WebhookData.RequestBody
#	}
#	else {
#	Write-Output "No Data Received"
#    }
##############Test-Runbook1 (ZZZ-Monitor/Test-Runbook1)