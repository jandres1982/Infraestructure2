# check

New-AzureRmAutomationConnection -ResourceGroupName "rg-cis-prod-monitoring-01"-AutomationAccountName "aa-prod-monitoring-01" -Name "spcnx1" -ConnectionTypeName AzureServicePrincipal -ConnectionFieldValues @{"CertificateThumbprint"="TestAzureAuto";"SubscriptionID"="00000000-0000-0000-0000-000000000000";"ApplicationId" = "00000000-0000-0000-0000-000000000000"; "TenantId" = "00000000-0000-0000-0000-000000000000" }





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

