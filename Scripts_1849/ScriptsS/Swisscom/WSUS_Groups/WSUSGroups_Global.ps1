import-module activedirectory


#Get all relevant AD Groups
$fri8pm = Get-ADGroupMember SHH_RES_GP_SRV_WSUS-CLIENT-SCHEDULE-FRIDAY-8PM -Recursive | select name
$fri9pm = Get-ADGroupMember SHH_RES_GP_SRV_WSUS-CLIENT-SCHEDULE-FRIDAY-9PM -Recursive | select name
$su6am = Get-ADGroupMember SHH_RES_GP_SRV_WSUS-CLIENT-SCHEDULE-SUNDAY-6AM -Recursive | select name
$su7am = Get-ADGroupMember SHH_RES_GP_SRV_WSUS-CLIENT-SCHEDULE-SUNDAY-7AM -Recursive | select name
$su9am = Get-ADGroupMember SHH_RES_GP_SRV_WSUS-CLIENT-SCHEDULE-SUNDAY-9AM -Recursive | select name
$su10am = Get-ADGroupMember SHH_RES_GP_SRV_WSUS-CLIENT-SCHEDULE-SUNDAY-10AM -Recursive | select name
$su11am = Get-ADGroupMember SHH_RES_GP_SRV_WSUS-CLIENT-SCHEDULE-SUNDAY-DHCP-SERVER -Recursive | select name
$serversallnodc = Get-ADGroupMember SHH_RES_GP_SRV_WSUS-CLIENT-TARGETING-SERVERS-PROD -Recursive | select name
$serverstest = Get-ADGroupMember SHH_RES_GP_SRV_WSUS-CLIENT-TARGETING-SERVERS-TEST -Recursive | select name
$serversmanual = Get-ADGroupMember SHH_RES_GP_SRV_WSUS-CLIENT-TARGETING-SERVERS-MANUAL -Recursive | select name
$domaincontrollers = Get-ADGroupMember "Domain Controllers" -Recursive | select name
$serversall = $serversallnodc + $domaincontrollers

#Get Sunday 8am Servers (default)
$allexcept8am = $fri8pm + $fri9pm + $su6am + $su7am + $su9am + $su10am + $su11am + $serversmanual
$su8am = Compare-Object -ReferenceObject $serversall.name -DifferenceObject $allexcept8am.name | Where-Object {$_.SideIndicator -eq "<="} | sort-object InputObject

#Get all Prod Servers
$allexceptprod = $serverstest + $serversmanual
$serversprod = Compare-Object -ReferenceObject $serversall.name -DifferenceObject $allexceptprod.name | Where-Object {$_.SideIndicator -eq "<="}

#################################
#Global Patch Groups

$ServersPRODFri8pm = (Compare-Object -ReferenceObject $fri8pm.name -DifferenceObject $allexceptprod.name | Where-Object {$_.SideIndicator -eq "<="}).InputObject
$ServersPRODFri9pm = (Compare-Object -ReferenceObject $fri9pm.name -DifferenceObject $allexceptprod.name | Where-Object {$_.SideIndicator -eq "<="}).InputObject
$ServersPRODSu6am = (Compare-Object -ReferenceObject $su6am.name -DifferenceObject $allexceptprod.name | Where-Object {$_.SideIndicator -eq "<="}).InputObject
$ServersPRODSu7am = (Compare-Object -ReferenceObject $su7am.name -DifferenceObject $allexceptprod.name | Where-Object {$_.SideIndicator -eq "<="}).InputObject
$ServersPRODSu8am = (Compare-Object -ReferenceObject $su8am.InputObject -DifferenceObject $allexceptprod.name | Where-Object {$_.SideIndicator -eq "<="}).InputObject
$ServersPRODSu9am = (Compare-Object -ReferenceObject $su9am.name -DifferenceObject $allexceptprod.name | Where-Object {$_.SideIndicator -eq "<="}).InputObject
$ServersPRODSu10am = (Compare-Object -ReferenceObject $su10am.name -DifferenceObject $allexceptprod.name | Where-Object {$_.SideIndicator -eq "<="}).InputObject
$ServersPRODSu11am = (Compare-Object -ReferenceObject $su11am.name -DifferenceObject $allexceptprod.name | Where-Object {$_.SideIndicator -eq "<="}).InputObject


$ServersTESTFri8pm = (Compare-Object -ReferenceObject $serverstest.name -DifferenceObject $fri8pm.Name -ExcludeDifferent -IncludeEqual).InputObject
$ServersTESTFri9pm = (Compare-Object -ReferenceObject $serverstest.name -DifferenceObject $fri9pm.Name -ExcludeDifferent -IncludeEqual).InputObject
$ServersTESTSu6am = (Compare-Object -ReferenceObject $serverstest.name -DifferenceObject $su6am.Name -ExcludeDifferent -IncludeEqual).InputObject
$ServersTESTSu7am = (Compare-Object -ReferenceObject $serverstest.name -DifferenceObject $su7am.Name -ExcludeDifferent -IncludeEqual).InputObject
$ServersTESTSu8am = (Compare-Object -ReferenceObject $serverstest.name -DifferenceObject $su8am.InputObject -ExcludeDifferent -IncludeEqual).InputObject
$ServersTESTSu9am = (Compare-Object -ReferenceObject $serverstest.name -DifferenceObject $su9am.Name -ExcludeDifferent -IncludeEqual).InputObject
$ServersTESTSu10am = (Compare-Object -ReferenceObject $serverstest.name -DifferenceObject $su10am.Name -ExcludeDifferent -IncludeEqual).InputObject
$ServersTESTSu11am = (Compare-Object -ReferenceObject $serverstest.name -DifferenceObject $su11am.Name -ExcludeDifferent -IncludeEqual).InputObject


$ServersPRODFri8pm | Out-File D:\Scripts\Swisscom\WSUS_Groups\ServersProdFri8pm.txt
$ServersPRODFri9pm |  Out-File D:\Scripts\Swisscom\WSUS_Groups\ServersProdFri9pm.txt
$ServersPRODSu6am | Out-File D:\Scripts\Swisscom\WSUS_Groups\ServersProdSu6am.txt
$ServersPRODSu7am | Out-File D:\Scripts\Swisscom\WSUS_Groups\ServersProdSu7am.txt
$ServersPRODSu8am | Out-File D:\Scripts\Swisscom\WSUS_Groups\ServersProdSu8am.txt
$ServersPRODSu9am | Out-File D:\Scripts\Swisscom\WSUS_Groups\ServersProdSu9am.txt
$ServersPRODSu10am | Out-File D:\Scripts\Swisscom\WSUS_Groups\ServersProdSu10am.txt
$ServersPRODSu11am | Out-File D:\Scripts\Swisscom\WSUS_Groups\ServersProdSu11am.txt











