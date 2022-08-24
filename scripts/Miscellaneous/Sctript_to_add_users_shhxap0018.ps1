
#Use server shhwsrcx0089
#Connect to vCenter or ESXi
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$viserver= "shhxap0018.global.schindler.com"
Connect-VIServer -Server $viserver  -WA 0    #Connect-VIServer
$principal = "GLOBAL\svcshhvcctx"
$roleName = 'Admin'
$role = Get-VIRole -Name $roleName
$DATA = Get-datacenter |Where-Object {$_.name -eq "SHH"}
New-VIPermission -Entity $DATA -Principal $principal -Role $role #-Confirm:$false