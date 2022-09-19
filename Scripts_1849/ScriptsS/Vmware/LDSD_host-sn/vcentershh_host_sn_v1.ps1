# BE-SCC Michael Barmettler
# 14.05.2014
# This script will read host bios information (serial number) from all ESXi hosts in vCenterSHH and
# export the data to \\shhwsr0041\data imports so that ITSM can import the data for ESXi inventory
# service-account svcshhvcldsdro is premitted to "READ ONLY" in vCenterSHH, write to \\shhwsr0041\data imports and run as batch-job on SHHWSR0025 to execute the script.
connect-viserver vcentershh.global.schindler.com
$serialnumbers = Get-Vmhost | Get-View | sort name | select @{Name="FQDN_Hostname";Expression={$_.name}},@{Name="SerialNumber"; Expression={($_.Hardware.SystemInfo.OtherIdentifyingInfo | where {$_.IdentifierType.Key -eq "ServiceTag"}).IdentifierValue}}
$serialnumbers | export-csv  "\\shhwsr0041.global.schindler.com\data imports\vcentershh-host-sn.csv" -NoTypeInformation -delimiter ";"