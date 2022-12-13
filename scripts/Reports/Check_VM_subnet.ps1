$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
#$subs = Get-AzSubscription -SubscriptionName "s-sis-eu-nonprod-01"
$date = $(get-date -format yyyy-MM-ddTHH-mm)
foreach ($sub in $subs)
{
Select-AzSubscription -Subscription $sub
$vms = Get-AzVM
$tgtSubnet = "sub-remediation-iaas-01"
foreach($vm in $vms)
{
    [string]$VmProfile = $vm.name
    Write-Output "Working on $VmProfile"
    $networkInterface = Get-AzNetworkInterface -Name ($vm.NetworkProfile.NetworkInterfaces[0].Id.Split('/')[-1])
    $subnetName = $networkInterface.IpConfigurations[0].Subnet.Id.split('/')[-1]
    if($subnetName -eq $tgtSubnet)
    {
    [string]$VmName = $vm.Name
    [string]$VmLocation = $vm.Location
    [string]$VmRg = $vm.ResourceGroupName
    [string]$VmSub = $Sub.Name
    [string]$VmNetworkInterface = $networkInterface.name
    [string]$VmSubnet = $subnetName
    [string]$VmIP = $networkInterface.IpConfigurations.PrivateIpAddress
    [string]$VmMAC = $networkInterface.MacAddress

    Write-Output "$VmName;$VmLocation;$VmRg;$VmSub;$VmNetworkInterface;$VmSubnet;$VmIP;$VmMAC" >> "D:\Repository\Working\Antonio\Report_VM_Subnet\sub-remediation_report_$date.txt"
    }
}
}