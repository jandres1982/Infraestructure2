# -----------------------------------------------------------------------
# Copyright (c) Microsoft Corporation.  All rights reserved.
# -----------------------------------------------------------------------
#./PrivateIP.ps1 -Subscription "<VaultPrivateEndpointSubscriptionId>" -VaultPrivateEndpointName "<vaultPrivateEndpointName>" -VaultPrivateEndpointRGName <vaultPrivateEndpointRGName> -DNSRecordListFile dnsentries.txt

Param(

    [parameter(position=0,Mandatory=$true)]
    $Subscription,

    [parameter(position=1,Mandatory=$true)]
    $VaultPrivateEndpointName,

    [parameter(position=2,Mandatory=$true)]
    $VaultPrivateEndpointRGName,
    
    [parameter(position=3,Mandatory=$true)]
    $DNSRecordListFile      
)

function TracePrivateIPMapping([string] $message, [string] $color="Yellow")
{
    Write-Host  "$message" -ForegroundColor $color
    $message | Out-File -FilePath $DNSRecordListFile -Append -Confirm:$false
}

#Connect-AzAccount
Set-AzContext -SubscriptionId $Subscription

# Get Private endpoint named using vault PE
$pelist = Get-AzPrivateEndpoint -ResourceGroupName "$VaultPrivateEndpointRGName"

$blobDNSZone = "privatelink.blob.core.windows.net"
$queueDNSZone = "privatelink.queue.core.windows.net"

# Print DNS record details
foreach( $pe in $pelist)
{
    if($pe.Name.StartsWith("$VaultPrivateEndpointName"))
    {
        $networkInterface = Get-AzResource `
            -ResourceId $pe.NetworkInterfaces[0].Id `
            -ApiVersion "2019-04-01"

        foreach ($ipconfig in $networkInterface.properties.ipConfigurations)
        {
            foreach ($fqdn in $ipconfig.properties.privateLinkConnectionProperties.fqdns)
            {
                $recordName = $fqdn.split('.',2)[0]
                $dnsZone = "privatelink." + $fqdn.split('.',2)[1]

                # override the dns zone for blob and queue
                if ( $pe.ManualPrivateLinkServiceConnections[0].GroupIds -eq "blob")
                {
                    $dnsZone = $blobDNSZone
                }

                if ( $pe.ManualPrivateLinkServiceConnections[0].GroupIds -eq "queue")
                {
                    $dnsZone = $queueDNSZone
                }                

                $privateIP = "$($ipconfig.properties.privateIPAddress)"

                TracePrivateIPMapping "$recordName `t $dnsZone `t $privateIp"
            }
        }
    }
}