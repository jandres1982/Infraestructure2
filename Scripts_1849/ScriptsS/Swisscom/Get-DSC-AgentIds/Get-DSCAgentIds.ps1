$servers = "shhwsr0600.global.schindler.com"
#$servers = Get-Content .\servers.txt


foreach ($server in $servers){
  if ([bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)){
    Invoke-Command -ComputerName $server -ScriptBlock {
    if ($psversiontable.PSVersion.Major -gt 3) {
            $agentid = (Get-DSCLocalconfigurationmanager).agentid
            if ($agentid) {
            $Output = "$env:COMPUTERNAME; $agentid"
            $Output | Out-File .\output.txt -Append
            }
            else {
            $output = "$env:COMPUTERNAME; No DSC Agent ID"
            $Output | Out-File .\output.txt -Append
            }
            } 
    } 
    }
    else {
    $Output = "$server; COULD NOT CONNECT"
    $Output | Out-File .\output.txt -Append
    }
}


