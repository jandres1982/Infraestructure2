#netsh winhttp import proxy source=ie
#cd "C:\Program Files\Qualys\QualysAgent"
#.\QualysProxy.exe /h
#Restart-Service -Name QualysAgent -Force

$Proxy = "http://shhnwg1000.global.schindler.com:3128"
$registryPath = "HKLM:\Software\qualys\Proxy"
$Name = "URL"
$value = $Proxy
New-Item -Path $registryPath -Force
New-ItemProperty -Path $registryPath -Name $name -Value $value -Force
Restart-Service -Name QualysAgent -Force

#netsh winhttp reset proxy

#netsh winhttp show proxy

