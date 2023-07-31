param([string]$vm)
$subs = Get-AzSubscription | Where-Object { $_.Name -match "s-sis-[aec][upmh]*" }
Write-host "$vm"
[int]$i = "0"
foreach ($sub in $subs) {
  Select-AzSubscription -Subscription "$sub"
 
  $AzVmCheck = get-azvm -Name "*$vm*"
  if ($AzVmCheck.count -eq "1") {
    $VmFound = [string]$AzVmCheck.name
    Write-Host "$vm was found as:$vmFound (check the name is correct)"
  }
  else {
    Write-Host "$vm was not found"
    $i++
    Write-host "$i"
    [int]$subcount = $subs.count
    if ($i -eq $subcount) {
      Write-error "$i Subs checked and server $vm was not found"
      Break
    }
  }
}