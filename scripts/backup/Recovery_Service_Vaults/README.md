# How to use the DNS entry script for private endpoints

This script was created by Microsoft and It will allow us to obtain the new dns entries created for the pe.
With this entries we will have to request the creation of them to identity team on schindler global dns.

Advise: The dns entries of the private endpoint will be created periodicaly.

# The exectution must be in this way

./PrivateIP.ps1 -Subscription "s-sis-eu-prod-01" -VaultPrivateEndpointName "pe-sql-prod-0002" -VaultPrivateEndpointRGName rg-cis-prod-backup-01 -DNSRecordListFile pe-sql-prod-0002.txt


