$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2019*')
{
#cmd.exe /c "msiexec.exe /i c:\provision\symantec\SEP_14.3.558.0000\Sep64.msi" /qn SYMREBOOT=ReallySuppress
cmd.exe /c "c:\provision\Microsoft\Defender\2019\WindowsDefenderATPOnboardingScript.cmd"
}

$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2016*')
{
cmd.exe /c "c:\Windows\System32\msiexec.exe /i /quiet c:\provision\Microsoft\Defender\2012-2016\WindowsServer_2012_2016\md4ws.msi"
cmd.exe /c "c:\provision\Microsoft\Defender\2012-2016\WindowsServer_2012_2016\WindowsDefenderATPOnboardingScript.cmd"
}

$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2012*')
{
cmd.exe /c "c:\Windows\System32\msiexec.exe /i /quiet c:\provision\Microsoft\Defender\2012-2016\WindowsServer_2012_2016\md4ws.msi"
cmd.exe /c "c:\provision\Microsoft\Defender\2012-2016\WindowsServer_2012_2016\WindowsDefenderATPOnboardingScript.cmd"
}