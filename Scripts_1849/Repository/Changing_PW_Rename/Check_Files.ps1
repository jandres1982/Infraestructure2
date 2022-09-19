$Servers = gc "D:\Repository\Working\Antonio\Changing_PW_Rename\Server_List_Check.txt"
$destination = "c$\temp\"

Echo "" > "D:\Repository\Working\Antonio\Changing_PW_Rename\Check.txt"

foreach ($Server in $Servers) { 

$result = Invoke-Command -ComputerName $Server -ScriptBlock {Test-Path -Path C:\temp\source.txt}
if (($result)){

Write-host "$Server has the files please delete it"
Echo "$server check" >> "D:\Repository\Working\Antonio\Changing_PW_Rename\Check.txt"

}

else {

write-host "$Server has not the file"

}

}
