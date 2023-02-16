#param([string]$vm)
$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
$vm = "zzzwsr0020"
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

$check = Get-ADComputer -Filter 'Name -like $vm'
if ($check.Name -eq $vm)
{
write-host "$vm exist in the AD, cannot be used"
Write-Error "$vm exist in the AD, cannot be used"
break
}else
{write-host "$vm is not in the AD"
}
