$bodymsg = @(
   @{ Message="Prueba the RunBook"}
   )

   
   $URL = 'https://s2events.azure-automation.net/webhooks?token=Ttib7fuC0zthn0PsuYvPJkhUcFmjUjwAjcfUkhBtcFQ%3d'
   $body = ConvertTo-Json -InputObject $bodymsg
   $header = @{ message = "Job de Antonio"}
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