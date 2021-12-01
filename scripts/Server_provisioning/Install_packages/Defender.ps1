$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2019*')
{
cmd.exe /c "c:\provision\Microsoft\Defender\WindowsDefenderATPOnboardingScript.cmd"
}