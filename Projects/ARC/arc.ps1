try {
    # Add the service principal application ID and secret here
    $servicePrincipalClientId="50324b27-4e61-43c7-b7ae-3239a8282588";
    $servicePrincipalSecret="Gu68Q~uHwnTAwu_vM9RVHYegsM73r~J1bbzHIcZT";

    $env:SUBSCRIPTION_ID = "7fa3c3a2-7d0d-4987-a30c-30623e38756c";
    $env:RESOURCE_GROUP = "rg-shh-test-defendersecurity-01";
    $env:TENANT_ID = "aa06dce7-99d7-403b-8a08-0c5f50471e64";
    $env:LOCATION = "northeurope";
    $env:AUTH_TYPE = "principal";
    $env:CORRELATION_ID = "04942d83-dcd3-4b84-8c56-111789037c77";
    $env:CLOUD = "AzureCloud";
    

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;

    # Download the installation package
    Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1" -proxy "http://webgateway-eu.schindler.com:3128";

    # Install the hybrid agent
    & "$env:TEMP\install_windows_azcmagent.ps1" -proxy "http://webgateway-eu.schindler.com:3128";
    if ($LASTEXITCODE -ne 0) { exit 1; }

    # Run connect command
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "$servicePrincipalClientId" --service-principal-secret "$servicePrincipalSecret" --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" --correlation-id "$env:CORRELATION_ID";
}
catch {
    $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";correlationId="$env:CORRELATION_ID";authType="$env:AUTH_TYPE";operation="onboarding";messageType=$_.FullyQualifiedErrorId;message="$_";};
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) -proxy "http://webgateway-eu.schindler.com:3128" | out-null;
    Write-Host  -ForegroundColor red $_.Exception;
}
