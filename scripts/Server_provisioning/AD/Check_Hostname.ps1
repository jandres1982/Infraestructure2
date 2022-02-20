param([string]$vm)
$check = Get-ADComputer -Filter 'Name -like $vm'
if ($check.Name -eq $vm)
{
write-host "$vm exist, cannot be used"
Write-Error "$vm cannot be used"
}else
{write-host "$vm can be used"
}