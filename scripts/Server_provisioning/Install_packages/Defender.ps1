$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2019*')
{
cmd.exe /c "c:\provision\Microsoft\Defender\2019\WindowsDefenderATPOnboardingScript.cmd"
}

$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2016*')
{
#cmd.exe /c "c:\provision\Microsoft\Defender\2012-2016\WindowsDefenderATPOnboardingScript.cmd"
}

$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2012*')
{
#cmd.exe /c "c:\provision\Microsoft\Defender\2012-2016\WindowsDefenderATPOnboardingScript.cmd"
}