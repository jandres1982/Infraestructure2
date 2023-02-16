If ($PsVersiontable.PSVersion.Major -ge "5" -and $PsVersiontable.Psversion.Minor -ge "1")
{
Write-host "Ok"
}else
     {Write-host "Upgrade is needed"

     wusa "C:\Program Files (x86)\LANDesk\LDClient\sdmcache\ldsource$\Packages_V2\Microsoft\WMF5.1_ALL\Win8.1AndW2K12R2-KB3191564-x64.msu\Win8.1AndW2K12R2-KB3191564-x64.msu" /quiet /norestart

     }
 