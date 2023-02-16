Get-ADComputer -Filter * -Prop IPv4Address,Name | Where-Object { $_.IPv4Address -like "10.37.*" } | Select -Property Name 

Connect-AzAccount

$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01")

#$subs = "s-sis-eu-nonprod-01"



foreach ($sub in $subs)
{

Set-AzContext -Subscription "$sub"

$tstservers = (get-azvm).name | where-object {$_ -like 'tst*'}

foreach ($tstserver in $tstservers)
{

$rg= (Get-AzVM -Name $tstserver).ResourceGroupName
$if = (Get-AzVM -Name $tstserver).NetworkProfile.NetworkInterfaces
$if = ($if.Id -split '/')[-1]

$nic = Get-AzNetworkInterface -ResourceGroupName $rg -Name $if

$nic.DnsSettings.DnsServers.Add("10.37.48.5")
$nic.DnsSettings.DnsServers.Add("10.37.48.7")
$nic | Set-AzNetworkInterface

}

} 


