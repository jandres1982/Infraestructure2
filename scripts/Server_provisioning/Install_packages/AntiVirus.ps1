$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2019*')
{
cmd.exe /c "msiexec.exe /i c:\provision\symantec\SEP_14.3.558.0000\Sep64.msi" /qn SYMREBOOT=ReallySuppress
}

$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2016*')
{
cmd.exe /c "msiexec.exe /i c:\provision\symantec\SEP_14.3.558.0000\Sep64.msi" /qn SYMREBOOT=ReallySuppress
}

$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2012*')
{
cmd.exe /c "msiexec.exe /i c:\provision\symantec\SEP_14.3.558.0000\Sep64.msi" /qn SYMREBOOT=ReallySuppress
}