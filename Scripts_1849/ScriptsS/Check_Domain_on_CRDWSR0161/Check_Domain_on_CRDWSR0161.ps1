if (Test-WSMan -ComputerName crdwsr0161 -Authentication Kerberos -ErrorAction SilentlyContinue)
 {Write-host "Keep Working"}
    else{
    $PSEmailServer = "smtp.eu.schindler.com"
    $From = "scc-support-zar.es@schindler.com"
    $to = "antoniovicente.vento@schindler.com","thomas.halama@schindler.com","gda_usr_dcff050b-8326-48c9-8bf9-61f8de7e89f0@schindler.com"
    $Subject = "CRDWSR0161 DOMAIN FAIL CHECK"
    #$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
    $Body = @"
    CRDWSR0161 IS OUT OF DOMAIN :: CHECK
"@

    Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body
}