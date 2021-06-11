netsh winhttp import proxy source=ie
cd "C:\Program Files\Qualys\QualysAgent"
.\QualysProxy.exe /h
Restart-Service -Name QualysAgent -Force