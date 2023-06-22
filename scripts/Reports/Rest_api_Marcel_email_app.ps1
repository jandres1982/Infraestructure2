# Replace these values with your own information
$clientId = "YOUR_CLIENT_ID"
$clientSecret = "YOUR_CLIENT_SECRET"
$tenantId = "YOUR_TENANT_ID"
$accessTokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$graphApiUrl = "https://graph.microsoft.com/v1.0" # Set up the authentication header
$authHeader = @{
    "Content-Type" = "application/x-www-form-urlencoded"
}
$body = @{
    client_id = $clientId
    scope = "https://graph.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type = "client_credentials"
}
$accessTokenResponse = Invoke-RestMethod -Method POST -Uri $accessTokenUrl -Headers $authHeader -Body $body
$accessToken = $accessTokenResponse.access_token
$authValue = "Bearer $accessToken"
$headers = @{
    "Authorization" = $authValue
} # Set up the email properties
$recipientEmailAddress = "recipient@example.com"
$subject = "Test email"
$bodyContent = "This is a test email sent using Graph API and PowerShell."
$body = @{
    content = $bodyContent
    contentType = "HTML"
}
$toRecipient = @{
    emailAddress = @{
        address = $recipientEmailAddress
    }
}
$emailMessage = @{
    subject = $subject
    body = $body
    toRecipients = @($toRecipient)
} # Send the email
$sendEmailUrl = "$graphApiUrl/users/<sender-email-address>/sendMail"
Invoke-RestMethod -Method POST -Uri $sendEmailUrl -Headers $headers -Body ($emailMessage | ConvertTo-Json)