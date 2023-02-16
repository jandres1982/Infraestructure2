#$Servers = gc "D:\LDSource\Packages_V2\Schindler\PW_admin\Server_List.txt"
$Servers = gc "D:\Repository\Working\Antonio\Changing_PW_Rename\Server_List.txt"
$destination = "c$\temp\"
echo "" > "D:\Repository\Working\Antonio\Changing_PW_Rename\Pw_change.log"



foreach ($Server in $Servers) {  #<For> each Server Selected in the Server_list.txt file



Write-host ""
Write-host "############################# Server: $Server #########################################" 
Write-host ""


$testSession = New-PSSession -Computer $Server -ErrorAction SilentlyContinue
if(-not($testSession))
{
    Write-Warning "$Server inaccessible!"
    echo "$server , please check it manually" >> "D:\Repository\Working\Antonio\Changing_PW_Rename\Pw_change.log"
}



Write-host ""



if ((Test-Path -Path "\\$Server\$destination")) { #Verify if is reachable


$version = invoke-command -ComputerName $server -ScriptBlock {$PSVersionTable.PSVersion.Major}


if ($version -gt 4){

Copy-Item -path "\\shhwsr1123\d$\LDSource\Packages_V2\Schindler\PW_admin\Change_PW_Rename_V2.ps1" -Destination \\$Server\$destination\
Copy-Item -path "\\shhwsr1123\d$\LDSource\Packages_V2\Schindler\PW_admin\Source.txt" -Destination \\$Server\$destination\
#Copy-Item -path "D:\Repository\Working\Antonio\Changing_PW_Rename\Cmd_PW_Rename_V2.cmd" -Destination \\$server\$destination\
#Copy-Item -path "D:\Repository\Working\Antonio\Changing_PW_Rename\PsExec64.exe" -Destination \\$server\$destination\

invoke-command -ComputerName $Server -ScriptBlock {powershell.exe "c:\temp\Change_PW_Rename_V2.ps1"}

Start-Sleep 3

Remove-Item "\\$Server\$destination\Change_PW_Rename_V2.ps1"
Remove-Item "\\$Server\$destination\Source.txt"

}

else {

Write-host "$server bad Powershell version"
echo "$server bad Powershell version" >> "D:\Repository\Working\Antonio\Changing_PW_Rename\Pw_change.log"

}


}else {
Write-host "$server no access"
#echo "$server no access, please check it manually" >> "D:\Repository\Working\Antonio\Changing_PW_Rename\Pw_change.log"

}





Remove-PSSession $testSession



}