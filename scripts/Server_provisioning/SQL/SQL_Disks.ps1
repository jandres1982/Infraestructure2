az account set --subscription "$(sub)"

#disk_0
az vm disk attach --resource-group $(rg) --vm-name $(vm) --name $(vm)_datadisk_0  --size-gb $(disk_0) --sku Standard_LRS --caching ReadOnly  --new

#disk_1
az vm disk attach --resource-group $(rg) --vm-name $(vm) --name $(vm)_datadisk_1  --size-gb $(disk_1) --sku Standard_LRS --caching ReadOnly --new

#disk_2
az vm disk attach --resource-group $(rg) --vm-name $(vm) --name $(vm)_datadisk_2  --size-gb $(disk_2) --sku Standard_LRS --caching None --new

#disk_3
az vm disk attach --resource-group $(rg) --vm-name $(vm) --name $(vm)_datadisk_3  --size-gb $(disk_3) --sku Standard_LRS --caching ReadOnly --new