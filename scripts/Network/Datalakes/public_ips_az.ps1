az network list-service-tags -l NorthEurope --query "values[?id == 'LogicApps.NorthEurope'].properties.addressPrefixes[]" --output tsv | FindStr "\."

az network list-service-tags -l SwitzerlandNorth --query "values[?id == 'DataFactory.NorthEurope'].properties.addressPrefixes[]" --output tsv | FindStr "\."


az network list-service-tags -l SwitzerlandNorth --query "values[?id == 'LogicApp.NorthEurope'].properties.addressPrefixes[]" --output tsv | FindStr "\."