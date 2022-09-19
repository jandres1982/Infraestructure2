$Servers = gc "D:\Repository\Working\Antonio\Rm_KSM_Reg_Global\server_list.txt"
#TrendMicro
$Destination = "c$\temp"
echo "" > "D:\Repository\Working\Antonio\Rm_KSM_Reg_Global\KMS.log"


#function Test-RegistryValue($path, $name)
#{
#    $key = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
#    $key -and $null -ne $key.GetValue($name, $null)
#}
#


foreach ($Server in $Servers) {  #<For> each Server Selected in the Server_list.txt file



Write-host ""
Write-host "############################# Server: $Server #########################################" 
Write-host ""

if ((Test-Path -Path "\\$Server\$destination")) { 


Copy-Item -path "\\shhwsr1123\d$\LDSource\Packages_V2\Schindler\RmRegKMS\rmregkms.cmd" -Destination "\\$Server\$destination\"

invoke-command -ComputerName $Server -ScriptBlock {Start-Process "c:\temp\rmregkms.cmd"}

#Enter-PSSession $Server

echo "############################# Server: $Server #########################################" >> "D:\Repository\Working\Antonio\Rm_KSM_Reg_Global\KMS.log"

WinRS -r:$server "c:\temp\rmregkms.cmd"

WinRS -r:$server "cscript.exe C:\Windows\System32\slmgr.vbs /dli" |select-string "DNS" >> "D:\Repository\Working\Antonio\Rm_KSM_Reg_Global\KMS.log"
write-host "$server ok"

Start-Sleep 5



Remove-Item "\\$server\$Destination\rmregkms.cmd"



}else

{write-host "This $Server cannot be reached"
echo "$server fail" >> "D:\Repository\Working\Antonio\Rm_KSM_Reg_Global\KMS.log"

}

}

