az network list-service-tags -l NorthEurope --query "values[?id == 'DataFactory.NorthEurope'].properties.addressPrefixes[]" --output tsv | FindStr "\."

az network list-service-tags -l SwitzerlandNorth --query "values[?id == 'DataFactory.NorthEurope'].properties.addressPrefixes[]" --output tsv | FindStr "\."


az network list-service-tags -l SwitzerlandNorth --query "values[?id == 'DataFactory.NorthEurope'].properties.addressPrefixes[]" --output tsv | FindStr "\."