
param([string]$vm)
############################### Account with no access to create the object #########################
$KG = $vm.Substring(0,3)
$head = "_RES_SY_"
$Admin_Tail="_ADMIN"
$Admin_Group = "$KG"+"$head"+"$vm"+"$Admin_Tail"
#New-ADGroup -Name $Admin_Group -GroupCategory Security -GroupScope Universal -DisplayName "$hostname Administrators" -Path "OU=RES,OU=Groups,OU=Admin_Global,OU=NBI12,DC=global,DC=schindler,DC=com" -Description "$Hostname Administrators

$check = Get-ADGroup -Identity $Admin_Group
if ($check.Name -ne $Admin_Group)
{
write-host "$vm Admin group doesn't exist, please create the admin group before deploying"
Write-Error "$vm Admin group doesn't exist, please create the admin group before deploying"
break
}else
{write-host "$VM Admin Group is $admin_group, ok passed"
}

##################################################################################################

########## Check Azure Hostname #####################

$response = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&client_id=2f9eefbb-eb19-486e-9bda-60c11cae3c08&resource=https://management.azure.com/' -Method GET -Headers @{Metadata="true"}
$content = $response.Content | ConvertFrom-Json
$ArmToken = $content.access_token
#LogWrite "$Current_time : $response"
$Login = Connect-AzAccount -AccessToken $ArmToken -Subscription $sub -AccountId $content.client_id

$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
Write-host "$vm"
foreach ($sub in $subs)
{
Select-AzSubscription -Subscription "$sub"
$Az_check = get-azvm -Name $vm
if ($Az_check -eq $null)
{
#write-host "$vm is not in Azure $sub"
}else
{
write-host "$vm exist in Azure, cannot be used"
Write-Error "$vm exist in Azure, cannot be used"
break
}
}


########## Check AD Hostname #####################


$check = Get-ADComputer -Filter 'Name -like $vm'
if ($check.Name -eq $vm)
{
write-host "$vm exist in the AD, cannot be used"
Write-Error "$vm exist in the AD, cannot be used"
break
}else
{write-host "$vm is not in the AD"
}


########## Check Ping Hostname #####################


if (test-connection -ComputerName $vm -Count 1 -Quiet)
{
Write-error "$vm, ping works on global domain"
break

}
else
{
    $vm_dmz2 = $vm + ".dmz2.schindler.com"
    if (test-connection -ComputerName $vm_dmz2 -Count 1 -Quiet)
    {
    Write-error "$vm_dmz2, ping works on dmz2 domain"
    break
    }
      else
      {
      $vm_tstglobal = $vm + ".tstglobal.schindler.com"
      if (test-connection -ComputerName $vm_tstglobal -Count 1 -Quiet)
      {
      Write-error "$vm_tstglobal, ping works on tstglobal domain"
      break
      } 

                  else {
                        
                        Write-host "$vm, is not pingable" -ForegroundColor green
                        
                        }
               }
      }

