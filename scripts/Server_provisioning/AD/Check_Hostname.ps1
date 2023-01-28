
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


$ApplicationId = "70eacc9c-bde8-4b40-9e16-02620fc4e65b"
$plainPassword = "4fL8Q~d5LzFVuC.g~KGC7Z1EVJU8O0c9GPx4La2E"
$securedPassword = $plainPassword | ConvertTo-SecureString -AsPlainText -Force
$TenantId = "aa06dce7-99d7-403b-8a08-0c5f50471e64"
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecuredPassword 
Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential

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

