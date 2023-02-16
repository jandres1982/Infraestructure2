
param([string]$vm)
############################### Account with no access to create the object #########################
Write-Output "Please, check on your side the YOU HAVE CREATED THE GROUP, we are not able to create DMZ2 AD GROUP at the moment"
##################################################################################################

########## Check Azure Hostname #####################

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
Write-Output "Please, check on your side the SERVER IS NOT IN THE AD, we are not able to check DMZ2 AD at the moment"
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

