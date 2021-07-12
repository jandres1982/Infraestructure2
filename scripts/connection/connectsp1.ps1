# check

New-AzureRmAutomationConnection -ResourceGroupName "rg-cis-prod-monitoring-01"-AutomationAccountName "aa-prod-monitoring-01" -Name "spcnx1" -ConnectionTypeName AzureServicePrincipal -ConnectionFieldValues @{"CertificateThumbprint"="91987337A6EC26A168EF069F62D366DEF6704640";"SubscriptionID"="505ead1a-5a5f-4363-9b72-83eb2234a43d";"ApplicationId" = "9973532f-746d-4249-8eef-aabbeafa4a68";"TenantId" = "aa06dce7-99d7-403b-8a08-0c5f50471e64" }





# Get Azure Run As Connection Name
$connectionName = "AzureRunAsConnection"
# Get the Service Principal connection details for the Connection name
$servicePrincipalConnection = Get-AutomationConnection –Name $connectionName         

# Logging in to Azure AD with Service Principal
"Logging in to Azure AD…"
Connect-AzureAD –TenantId $servicePrincipalConnection.TenantId `
    –ApplicationId $servicePrincipalConnection.ApplicationId `
    –CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint

"List Tenant Org Details:"
Get-AzureADTenantDetail | Select DisplayName, Street, PostalCode, City, CountryLetterCode

"Member Account Synced Count:"
(Get-AzureADUser –All $true –Filter "userType eq 'Member' and accountEnabled eq true" | Where-Object {$_.DirSyncEnabled -eq $true}).Count
"Disabled Users Count:"
(Get-AzureADUser –All $true –Filter 'accountEnabled eq false').Count
"Guest User Count:"
(Get-AzureADUser –All $true –Filter "userType eq 'Guest'").Count
"Cloud Only Account Count:"
(Get-AzureADUser –All $true –Filter "userType eq 'Member'" | Where-Object {$_.userPrincipalName -like "*onmicrosoft.com"}).Count







# notes
$ctx = Get-AzContext
 Select-azSubscription -subscripction $susbs

