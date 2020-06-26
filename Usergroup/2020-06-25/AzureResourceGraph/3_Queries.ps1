#Install dependent module
Install-Module -Name Az.ResourceGraph -Scope CurrentUser 

#Load PowerShell functions
. '.\Invoke-ARGQuery.ps1'

#Connect-AzAccount

#region queries

#####################
## References:
## Starter queries:     https://docs.microsoft.com/en-us/azure/governance/resource-graph/samples/starter?tabs=azure-powershell
## Advanced queries:    https://docs.microsoft.com/en-us/azure/governance/resource-graph/samples/advanced?tabs=azure-powershell
#####################

$query = @"
    ResourceContainers 
    | where type=='microsoft.resources/subscriptions' 
    | project SubName=name, subscriptionId
    | sort by SubName desc
"@

## Gather all resources grouped by resource type for all subscriptions
$query = @"
    Resources 
    | project type, subscriptionId, id 
    | join kind= inner (ResourceContainers 
    | where type=='microsoft.resources/subscriptions' 
    | project SubName=name, subscriptionId) on subscriptionId 
    | summarize count() by SubName, type 
    | sort by SubName desc
"@

## Gathers all snapshots including name, rg, diskState and creation date.
$query = @"
Resources
| where type == "microsoft.compute/snapshots"
| project name, resourceGroup, timeCreated=properties.timeCreated, diskState = properties.diskState 
| sort by name desc
"@

## Gather all VMs that have Azure Hybrid Benefit enabled 
# Reference:  https://github.com/MicrosoftDocs/azure-docs/issues/53811 
# Azure Hybrid Benefit is activated in the cases licenseType equals "Windows_Server"
$query= @"
Resources
| extend licenseType = tostring(properties.['licenseType'])
| extend hardwareProfile = tostring(properties.['hardwareProfile'].['vmSize'])
| extend osType = tostring(properties.['storageProfile'].['osDisk'].['osType'])
| extend sku = tostring(properties.['storageProfile'].['imageReference'].['sku'])
| project name, resourceGroup, location, type, licenseType, hardwareProfile, osType, tags, sku, subscriptionId, id
| where type =~ 'Microsoft.Compute/virtualMachines' and licenseType == "Windows_Server"
| join kind=inner (
    ResourceContainers
    | where type =~ 'microsoft.resources/subscriptions/resourcegroups'
    | project subscriptionId, resourceGroup, costcenter = tags.["Cost Center"], use = tags.["Use"])
on subscriptionId, resourceGroup
| join kind=inner (
	ResourceContainers 
	| where type=='microsoft.resources/subscriptions' | project SubscriptionName=name, subscriptionId) on subscriptionId
| project Name = name, ResourceGroup = resourceGroup, SubscriptionName, Location = location, CostCenter = costcenter, LicenseType = licenseType, HardwareProfile = hardwareProfile, SKU = sku, OSType = osType, Tags = tags, subscriptionId, id
| sort by id asc
"@

## Show first five virtual machines by name and their OS type
$query= @"
Resources
| where type =~ 'Microsoft.Compute/virtualMachines'
| project name, properties.storageProfile.osDisk.osType
| top 5 by name desc
"@

## Count virtual machines by OS type
$query= @"
Resources
| where type =~ 'Microsoft.Compute/virtualMachines'
| summarize count() by tostring(properties.storageProfile.osDisk.osType)
"@

## VM including Storage types
# Joining example
$query= @"
Resources
| where type == "microsoft.compute/disks"
| project StorageType = sku.name, diskID = tolower(tostring(id)) 
| join (
	Resources
	| where type =~ 'Microsoft.Compute/virtualmachines' 
	| extend disk = properties.storageProfile.osDisk.managedDisk
	| project name, properties.hardwareProfile.vmSize, disk.storageAccountType, diskID = tolower(tostring(disk.id)) 	
	)
on diskID
"@


#endregion


#region execution

#Execute query and save to variable
$queryresult = Invoke-ARGQuery -Query $query -ExportCSVPath "C:\Users\david\OneDrive - das Neves\Sessions\PSUGMUC 2020 June\Output\output.csv" | Out-GridView -PassThru

#Visualizing results
$queryresult | Out-GridView

#endregion