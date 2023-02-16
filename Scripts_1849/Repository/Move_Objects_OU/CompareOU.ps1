
$Target_OU1 = "OU=SHH,OU=0009,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"
$Target_OU2 = "OU=SHH,OU=0009,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"

$OU1 = (Get-GPInheritance -Target $Target_OU1).gpolinks | select DisplayName


$OU2 = (Get-GPInheritance -Target $Target_OU2).gpolinks | select DisplayName

If($OU1 -eq $null)
{$OU1 = "ALERT: Doesn't have any linked GPO --> $Target_OU1"
}
If($OU2 -eq $null)
{$OU2 = "ALERT: Doesn't have any linked GPO --> $Target_OU2"
}

$CompareOU = compare $OU1 $OU2


echo $CompareOU


echo ""
echo ""
echo ""
echo ""

echo "------------------------------------------------------"
If($CompareOU.SideIndicator -eq "=>")
{
echo "$Target_OU1 doesn't have this GPO:" $CompareOU.Get(0)
}
else
{
echo "$Target_OU2 doesn't have this GPO:" $CompareOU.Get(0)
}