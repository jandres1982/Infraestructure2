Get-NetTCPConnection -State Listen | Select-Object -Property LocalAddress, LocalPort, State | Sort-Object LocalPort |ft