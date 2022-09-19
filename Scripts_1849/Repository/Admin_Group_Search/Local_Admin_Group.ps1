$servers = Get-Content -Path "D:\Repository\Working\Antonio\Admin_Group_Search\Local_Admin_Group.txt"

Foreach ($server in $servers)
{
$server = $server.ToUpper()
$KG = $server.Substring(0,3)
$head = "_RES_SY_"
$Admin_Tail="_ADMIN"
$Admin_Group = "GLOBAL\"+"$KG"+"$head"+"$server"+"$Admin_Tail"
$Groups = Invoke-Command -ComputerName $server -ScriptBlock {Get-LocalGroupMember -Group administrators}
$Groups | findstr $Admin_Group
}