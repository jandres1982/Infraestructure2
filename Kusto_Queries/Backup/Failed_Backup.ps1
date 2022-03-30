recoveryservicesresources
| where properties['lastBackupStatus'] == "Failed"
| extend friendlyName = properties.friendlyName
| project friendlyName
