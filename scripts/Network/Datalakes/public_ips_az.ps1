az network list-service-tags -l NorthEurope --query "values[?id == 'DataFactory.NorthEurope'].properties.addressPrefixes[]" --output tsv | FindStr "\."