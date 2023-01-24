$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01","s-sis-ch-prod-01","s-sis-ch-nonprod-01")
$Script_Path = "D:\Repository\Working\Antonio\Pe_Links_for_Rsv\"
#test add some lines in D:\Repository\Working\Antonio\Pe_Links_for_Rsv\Subscriptions\s-sis-eu-nonprod-01\rsv-nonprod-euno-lrsbackup-02\pe\pe-backup-nonprod-0001.txt

Function Send_Email
{
$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "antoniovicente.vento@schindler.com"
#$to = "antoniovicente.vento@schindler.com","javier.roy@schindler.com","alfonso.marques@schindler.com","javier.cabezudo@schindler.com"
#$to = "gda_usr_dcff050b-8326-48c9-8bf9-61f8de7e89f0@schindler.com"
$Subject = "Check $pe_name change on $rsv"
$Body = @"
IMPORTANT: Please check $pe_name change on $rsv
Checking our records pe links from a recovery service vault has been updated.
Backup of this rsv will fail if DNS are not getting updated.
To verify the last pe links please check the rsv/pe subscription folder.
Best regards,

Microsoft Recovery Service Vault Private Enpoint Link - Check Script
"@
Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body
}



Function Check_Folder_Sctructure
{
   Foreach ($sub in $Subscription)
   {
   New-Item -ItemType Directory -Path "$Script_Path\Subscriptions" -Name $sub -ErrorAction SilentlyContinue
   }
}


Check_Folder_Sctructure

Foreach ($sub in $Subscription)
{

      Function Ms_Pe_Link_File ($subscription,$VaultPrivateEndpointName,$VaultPrivateEndpointRGName,$DNSRecordListFile)
          {
      
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
          }

      Select-AzSubscription -Subscription $sub
      $Rsv_list = Get-AzRecoveryServicesVault |Where-Object {$_.Name -match "rsv-*"}
      $Rsv_name = $Rsv_list.name
      $Rg_name = $Rsv_list.ResourceGroupName
      
      foreach ($rsv in $Rsv_name) 
          {
              Write-host "Working on $rsv" -ForegroundColor Green
              Move-Item -Path "$Script_Path\Subscriptions\$sub\$rsv\pe\*" -Destination "$Script_Path\Subscriptions\$sub\$rsv\pe_old\" -Force -ErrorAction SilentlyContinue
              New-Item -ItemType Directory -Path "$Script_Path\Subscriptions\$sub\$rsv" -Name "pe" -ErrorAction SilentlyContinue
              New-Item -ItemType Directory -Path "$Script_Path\Subscriptions\$sub\$rsv" -Name "pe_old" -ErrorAction SilentlyContinue
              New-Item -ItemType Directory -Path "$Script_Path\Subscriptions\$sub\$rsv" -Name "logs" -ErrorAction SilentlyContinue
              $rg = $(Get-AzRecoveryServicesVault -Name $rsv).ResourceGroupName
              $pe = Get-AzPrivateEndpointConnection -ResourceGroupName $rg -PrivateLinkResourceType "Microsoft.RecoveryServices/vaults" -ServiceName $rsv
              if($pe)
              {
              $pe_name = $pe.PrivateEndpoint.Id.split("/")[8]
              Write-host "Working on $pe_name" -ForegroundColor Green
              Ms_Pe_Link_File -subscription $Sub -VaultPrivateEndpointName $pe_name -VaultPrivateEndpointRGName $rg -DNSRecordListFile "$Script_Path\Subscriptions\$sub\$rsv\Pe\$pe_name.txt"
              
              #Compare
                If (test-path "$Script_Path\Subscriptions\$sub\$rsv\pe_old\$pe_name.txt")
                {#starting to compare
                $file1 = Get-Content "$Script_Path\Subscriptions\$sub\$rsv\Pe\$pe_name.txt"
                $file2 = Get-Content "$Script_Path\Subscriptions\$sub\$rsv\Pe_Old\$pe_name.txt"
                $result =  Compare-Object -ReferenceObject $file1 -DifferenceObject $file2
                    if ($result)
                      {
                      Send_Email
                      Write-Output "$rsv | $pe_name | CHECK ">> "$Script_Path\logs\RSV_ALERT_Flag.txt"
                      }
                }else
                    {Write-Output "Nothing to compare check on $rsv, $pe_name old link was not found" >> "$Script_Path\logs\rsv_error.txt"}

              }else
                  {
                  Write-Output "$rsv | Not private Endpoint Found" >> "$Script_Path\Subscriptions\$sub\$rsv\logs\logs.txt"}
          }
      
}