$tls_min_version = $(get-azstorageAccount devprjtest -ResourceGroupName rg-gis-dev-ssot-01 | Select-Object -Property *).MinimumTlsVersion

