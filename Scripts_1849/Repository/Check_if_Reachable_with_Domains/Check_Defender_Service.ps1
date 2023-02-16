$proc = cmd.exe /c "C:\Program Files\Notepad++\notepad++.exe" "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Server_List.txt"
$computers = gc "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Server_List.txt"


foreach ($computer in $computers)
{

if (Get-Service -computername $computer -Name WinDefend)
{


Write-Output "$computer" >> "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report_Windefend.txt"
Get-Service -computername $computer -Name WinDefend | select-object name,status,StartType >> "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report_Windefend.txt"

} else
{

Write-Output "$computer service cannot be checked please go manual" >> "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report_Windefend.txt"
}

}