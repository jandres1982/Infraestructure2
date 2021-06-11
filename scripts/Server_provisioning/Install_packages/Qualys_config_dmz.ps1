#netsh winhttp import proxy source=ie
#cd "C:\Program Files\Qualys\QualysAgent"
#.\QualysProxy.exe /h
#Restart-Service -Name QualysAgent -Force

$Get_proxy = [System.Net.WebProxy]::GetDefaultProxy()
$Proxy = $Get_proxy.Address.Authority
cd "C:\Program Files\Qualys\QualysAgent"
.\QualysProxy.exe /u $Proxy